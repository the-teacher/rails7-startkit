#!/usr/bin/env ruby
# frozen_string_literal: true

# Minimal HTTP API wrapping yt-dlp. Autonomous by design — no gems beyond
# stdlib + webrick, no knowledge of Rails. Writes extracted files to
# OUTPUT_DIR (shared with the Rails container via a Docker volume) and
# returns the filename; the caller reads the bytes off the shared mount.
require "webrick"
require "json"
require "open3"
require "securerandom"
require "fileutils"
require "thread"

OUTPUT_DIR = ENV.fetch("OUTPUT_DIR", "/data")
PORT       = ENV.fetch("PORT", "4567").to_i
FileUtils.mkdir_p(OUTPUT_DIR)

# YouTube's own video id (the stable 11-char [A-Za-z0-9_-] identifier) — used
# as the file/job key instead of a random id, so re-requesting the same video
# hits the same filename and can be served from cache instead of re-downloading.
VIDEO_ID_RE = %r{(?:v=|youtu\.be/|shorts/)([\w-]{11})}

def extract_video_id(url)
  url[VIDEO_ID_RE, 1]
end

# In-memory job registry for the async /jobs API (see below). Ephemeral by
# design — this is a demo tool, not a queue; jobs vanish on restart. A Mutex
# guards it since WEBrick handles requests on multiple threads while a
# background Thread per job writes progress into the same Hash.
JOBS      = {}
JOBS_LOCK = Mutex.new

def job_get(id)
  JOBS_LOCK.synchronize { JOBS[id]&.dup }
end

def job_set(id, **fields)
  JOBS_LOCK.synchronize { (JOBS[id] ||= {}).merge!(fields) }
end

# Parses yt-dlp's own `--newline` progress output, e.g.:
#   [download]  45.2% of ~3.14MiB at    1.23MiB/s ETA 00:05
#   [download] 100% of    3.14MiB in 00:04
# This text format has been stable across yt-dlp/youtube-dl for years —
# more reliable to depend on than guessing exact --progress-template field
# names without a live video to test against.
PROGRESS_RE = /\[download\]\s+([\d.]+)%\s+of\s+~?([\d.]+\w+)(?:\s+at\s+([\d.]+\w+\/s|Unknown))?(?:\s+(?:ETA\s+(\S+)|in\s+(\S+)))?/
DESTINATION_RE = /\[(?:download|ExtractAudio|Merger)\]\s+(?:Destination|Merging formats into):?\s+"?([^"\n]+?)"?\s*$/

# Runs yt-dlp in a background thread for job `id`, streaming its stdout so
# progress can be parsed line-by-line instead of waiting for the whole
# process to exit (which is what Open3.capture3 in run_yt_dlp/handle_extract
# below does — fine for /extract's synchronous CLI use, wrong for a page
# that wants to show live progress).
def start_download_job(id, url)
  job_set(id, status: "starting", percent: 0.0, downloaded: nil, total: nil,
              speed: nil, eta: nil, filename: nil, error: nil)

  Thread.new do
    template = File.join(OUTPUT_DIR, "#{id}.%(ext)s")
    args = ["-x", "--audio-format", "mp3", "--audio-quality", "0", "--no-playlist",
            "--newline", "--max-filesize", MAX_FILESIZE, "-o", template, url]

    stderr_lines = []
    begin
      Open3.popen3("yt-dlp", *args) do |_stdin, stdout, stderr, wait_thr|
        job_set(id, status: "downloading")

        err_reader = Thread.new { stderr.each_line { |l| stderr_lines << l } }

        stdout.each_line do |line|
          if (m = line.match(PROGRESS_RE))
            job_set(
              id,
              percent:    m[1].to_f,
              total:      m[2],
              speed:      m[3],
              eta:        m[4] || m[5]
            )
          elsif (m = line.match(DESTINATION_RE))
            job_set(id, filename: File.basename(m[1].strip))
          end
        end

        err_reader.join
        status = wait_thr.value

        if status.success?
          filename = extracted_filename(id)
          size     = File.size(File.join(OUTPUT_DIR, filename))
          job_set(id, status: "done", percent: 100.0, filename: filename, size: size)
        else
          job_set(id, status: "error", error: stderr_lines.join.strip[0, 500])
        end
      end
    rescue StandardError => e
      job_set(id, status: "error", error: e.message)
    end
  end
end

# Only youtube.com/youtu.be — this is a YouTube extractor, not a general
# "download anything from any site" endpoint, even though yt-dlp itself
# supports hundreds of sites.
YOUTUBE_URL_RE = %r{\Ahttps?://(www\.|m\.)?(youtube\.com/(watch\?v=|shorts/)|youtu\.be/)[\w-]+}i

MAX_FILESIZE = ENV.fetch("MAX_FILESIZE", "200M")

def run_yt_dlp(*args)
  out, err, status = Open3.capture3("yt-dlp", *args)
  raise "yt-dlp failed: #{err.to_s.strip[0, 500]}" unless status.success?

  out
end

def extracted_filename(id)
  path = Dir.glob(File.join(OUTPUT_DIR, "#{id}.*")).first
  raise "yt-dlp reported success but produced no output file" unless path

  File.basename(path)
end

def handle_extract(body)
  payload = JSON.parse(body.to_s)
  url  = payload["url"].to_s
  want = (payload["want"] || "audio").to_s

  raise ArgumentError, "url must be a youtube.com/youtu.be link" unless url.match?(YOUTUBE_URL_RE)

  case want
  when "metadata"
    json = run_yt_dlp("--dump-json", "--no-playlist", url)
    { type: "metadata", metadata: JSON.parse(json) }

  when "audio"
    id          = extract_video_id(url) or raise ArgumentError, "could not find an 11-char video id in that url"
    cached_path = File.join(OUTPUT_DIR, "#{id}.mp3")
    was_cached  = File.exist?(cached_path)
    unless was_cached
      template = File.join(OUTPUT_DIR, "#{id}.%(ext)s")
      run_yt_dlp("-x", "--audio-format", "mp3", "--audio-quality", "0",
                 "--no-playlist", "--max-filesize", MAX_FILESIZE, "-o", template, url)
    end
    { type: "audio", filename: extracted_filename(id), cached: was_cached }

  when "video"
    id          = extract_video_id(url) or raise ArgumentError, "could not find an 11-char video id in that url"
    cached_path = File.join(OUTPUT_DIR, "#{id}.mp4")
    was_cached  = File.exist?(cached_path)
    unless was_cached
      template = File.join(OUTPUT_DIR, "#{id}.%(ext)s")
      run_yt_dlp("-f", "mp4", "--no-playlist", "--max-filesize", MAX_FILESIZE, "-o", template, url)
    end
    { type: "video", filename: extracted_filename(id), cached: was_cached }

  else
    raise ArgumentError, "unknown want: #{want.inspect} (expected audio|metadata|video)"
  end
end

server = WEBrick::HTTPServer.new(Port: PORT, BindAddress: "0.0.0.0")

server.mount_proc "/health" do |_req, res|
  res["Content-Type"] = "application/json"
  res.body = { status: "ok" }.to_json
end

server.mount_proc "/jobs" do |req, res|
  res["Content-Type"] = "application/json"
  begin
    case req.request_method
    when "POST"
      payload = JSON.parse(req.body.to_s)
      url = payload["url"].to_s
      raise ArgumentError, "url must be a youtube.com/youtu.be link" unless url.match?(YOUTUBE_URL_RE)

      id = extract_video_id(url)
      raise ArgumentError, "could not find an 11-char video id in that url" unless id

      cached_path = File.join(OUTPUT_DIR, "#{id}.mp3")
      if File.exist?(cached_path)
        job_set(id, status: "done", percent: 100.0, filename: File.basename(cached_path),
                    size: File.size(cached_path), cached: true, error: nil)
      else
        start_download_job(id, url)
      end

      res.status = 202
      res.body = { id: id }.to_json

    when "GET"
      id  = req.path.split("/").last
      job = job_get(id)
      raise ArgumentError, "unknown job id" unless job

      res.body = job.to_json

    else
      res.status = 405
      res.body = { error: "unsupported method" }.to_json
    end
  rescue ArgumentError, JSON::ParserError => e
    res.status = 422
    res.body = { error: e.message }.to_json
  rescue StandardError => e
    res.status = 500
    res.body = { error: e.message }.to_json
  end
end

server.mount_proc "/extract" do |req, res|
  res["Content-Type"] = "application/json"
  begin
    res.body = handle_extract(req.body).to_json
  rescue ArgumentError, JSON::ParserError => e
    res.status = 422
    res.body = { error: e.message }.to_json
  rescue StandardError => e
    res.status = 500
    res.body = { error: e.message }.to_json
  end
end

trap("INT")  { server.shutdown }
trap("TERM") { server.shutdown }

server.start
