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

# Google Drive's file id — appears in several URL shapes:
#   https://drive.google.com/file/d/<ID>/view?usp=sharing
#   https://drive.google.com/open?id=<ID>
#   https://drive.google.com/uc?id=<ID>&export=download
# Length varies (usually ~33 chars, [\w-]) unlike YouTube's fixed 11 — same
# caching-key role as VIDEO_ID_RE, just for a different source.
GOOGLE_DRIVE_ID_RE = %r{drive\.google\.com/(?:file/d/|open\?id=|uc\?id=)([\w-]+)}

# Tries each known source's id pattern in turn. Returns nil if the URL
# matched SUPPORTED_URL_RE but somehow still has no id — shouldn't happen in
# practice since the two regexes are kept in sync, but callers still check.
def extract_source_id(url)
  url[VIDEO_ID_RE, 1] || url[GOOGLE_DRIVE_ID_RE, 1]
end

# Each source (video/file) gets its own subdirectory under OUTPUT_DIR instead
# of a flat pile of files — every download brings a compressed copy, chunks,
# and several transcript files with it, and that adds up fast. Pre-existing
# downloads were migrated by hand into a bare "<id>/" directory; every new
# download gets "<DD_MM_YYYY>_<id>/" (today's date). Re-requesting an id that
# already has EITHER kind of directory reuses it — a fresh dated directory is
# only created the first time a given id is ever seen, so the existing
# "don't re-download the same video" cache still works regardless of naming
# style. Returns an absolute path; File.basename(dir) is the bit callers
# prepend to a relative filename before handing it back to the client.
def media_dir_for(id)
  legacy = File.join(OUTPUT_DIR, id)
  return legacy if File.directory?(legacy)

  dated = Dir.glob(File.join(OUTPUT_DIR, "*_#{id}")).select { |p| File.directory?(p) }.first
  return dated if dated

  dir = File.join(OUTPUT_DIR, "#{Time.now.strftime('%d_%m_%Y')}_#{id}")
  FileUtils.mkdir_p(dir)
  dir
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
    dir      = media_dir_for(id)
    dir_name = File.basename(dir)
    template = File.join(dir, "#{id}.%(ext)s")
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
            job_set(id, filename: File.join(dir_name, File.basename(m[1].strip)))
          end
        end

        err_reader.join
        status = wait_thr.value

        if status.success?
          filename = extracted_filename(id, dir)
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

# youtube.com/youtu.be and drive.google.com — a deliberately short allowlist,
# not a general "download anything from any site" endpoint, even though
# yt-dlp itself supports hundreds of sites (`yt-dlp --list-extractors`, or
# https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md). Extend
# SUPPORTED_URL_RE (and extract_source_id above) if another source is needed.
YOUTUBE_URL_RE      = %r{\Ahttps?://(www\.|m\.)?(youtube\.com/(watch\?v=|shorts/)|youtu\.be/)[\w-]+}i
GOOGLE_DRIVE_URL_RE = %r{\Ahttps?://drive\.google\.com/(file/d/|open\?id=|uc\?id=)[\w-]+}i
SUPPORTED_URL_RE    = Regexp.union(YOUTUBE_URL_RE, GOOGLE_DRIVE_URL_RE)

MAX_FILESIZE = ENV.fetch("MAX_FILESIZE", "200M")

def run_yt_dlp(*args)
  out, err, status = Open3.capture3("yt-dlp", *args)
  raise "yt-dlp failed: #{err.to_s.strip[0, 500]}" unless status.success?

  out
end

def extracted_filename(id, dir = media_dir_for(id))
  path = Dir.glob(File.join(dir, "#{id}.*")).first
  raise "yt-dlp reported success but produced no output file" unless path

  File.join(File.basename(dir), File.basename(path))
end

# Re-encodes an already-downloaded file down to a speech-transcription-sized
# copy: mono, 16kHz, 64kbps — Whisper doesn't need or want hi-fi stereo audio,
# and this is usually a 4-8x size reduction, enough to get most single videos
# under upstream providers' request-size limits (OpenRouter's audio endpoint
# caps the base64-encoded body at 50 MiB) without needing to split the file
# into multiple chunks. Cached the same way as downloads: skip re-encoding if
# the compressed file already exists.
def validate_relative_filename!(filename)
  raise ArgumentError, "invalid filename" if filename.include?("..") || filename.start_with?("/") || filename.count("/") > 1
end

def compress_for_transcription(filename)
  validate_relative_filename!(filename)

  src = File.join(OUTPUT_DIR, filename)
  raise ArgumentError, "file not found: #{filename}" unless File.exist?(src)

  rel_dir   = File.dirname(filename)
  base      = File.basename(filename, ".*")
  dest_name = "#{base}_16k.mp3"
  dest      = File.join(OUTPUT_DIR, rel_dir, dest_name)

  unless File.exist?(dest)
    _out, err, status = Open3.capture3(
      "ffmpeg", "-y", "-i", src, "-ac", "1", "-ar", "16000", "-b:a", "64k", dest
    )
    raise "ffmpeg failed: #{err.to_s.strip[0, 500]}" unless status.success?
  end

  File.join(rel_dir, dest_name)
end

# Reads a media file's duration via ffprobe. Returns nil (rather than
# raising) on failure — duration is used for progress/offset bookkeeping,
# not correctness-critical, so a probe failure shouldn't abort a split.
def probe_duration(path)
  out, _err, status = Open3.capture3(
    "ffprobe", "-v", "error", "-show_entries", "format=duration",
    "-of", "default=noprint_wrappers=1:nokey=1", path
  )
  status.success? ? out.strip.to_f : nil
end

# Splits an already-downloaded (ideally already-compressed) file into fixed-
# length chunks via ffmpeg's segment muxer, for files too long/large to
# transcribe in one upstream request. `-c copy` (no re-encode) — fast, and
# fine for an mp3 source since frame boundaries are tiny compared to a
# 20-30 minute cut point. Chunks live in a `<base>_chunks/` subdirectory so
# repeated requests for the same file can detect and reuse existing chunks
# instead of re-splitting (same caching convention as downloads/compression).
def split_for_transcription(filename, chunk_minutes)
  validate_relative_filename!(filename)

  src = File.join(OUTPUT_DIR, filename)
  raise ArgumentError, "file not found: #{filename}" unless File.exist?(src)

  rel_dir   = File.dirname(filename)
  base      = File.basename(filename, ".*")
  ext       = File.extname(filename).delete_prefix(".")
  chunk_dir = File.join(OUTPUT_DIR, rel_dir, "#{base}_chunks")
  FileUtils.mkdir_p(chunk_dir)

  existing = Dir.glob(File.join(chunk_dir, "#{base}_*.#{ext}")).sort
  cached   = !existing.empty?

  if existing.empty?
    pattern = File.join(chunk_dir, "#{base}_%03d.#{ext}")
    _out, err, status = Open3.capture3(
      "ffmpeg", "-y", "-i", src, "-f", "segment",
      "-segment_time", (chunk_minutes.to_i * 60).to_s,
      "-c", "copy", "-reset_timestamps", "1", pattern
    )
    raise "ffmpeg split failed: #{err.to_s.strip[0, 500]}" unless status.success?

    existing = Dir.glob(File.join(chunk_dir, "#{base}_*.#{ext}")).sort
  end

  chunks = existing.map do |path|
    {
      filename: File.join(rel_dir, "#{base}_chunks", File.basename(path)),
      size:     File.size(path),
      duration: probe_duration(path)
    }
  end

  { chunks: chunks, cached: cached }
end

def handle_extract(body)
  payload = JSON.parse(body.to_s)
  url  = payload["url"].to_s
  want = (payload["want"] || "audio").to_s

  raise ArgumentError, "url must be a youtube.com/youtu.be or drive.google.com link" unless url.match?(SUPPORTED_URL_RE)

  case want
  when "metadata"
    json = run_yt_dlp("--dump-json", "--no-playlist", url)
    { type: "metadata", metadata: JSON.parse(json) }

  when "audio"
    id          = extract_source_id(url) or raise ArgumentError, "could not find a source id in that url"
    dir         = media_dir_for(id)
    cached_path = File.join(dir, "#{id}.mp3")
    was_cached  = File.exist?(cached_path)
    unless was_cached
      template = File.join(dir, "#{id}.%(ext)s")
      run_yt_dlp("-x", "--audio-format", "mp3", "--audio-quality", "0",
                 "--no-playlist", "--max-filesize", MAX_FILESIZE, "-o", template, url)
    end
    { type: "audio", filename: extracted_filename(id, dir), cached: was_cached }

  when "video"
    id          = extract_source_id(url) or raise ArgumentError, "could not find a source id in that url"
    dir         = media_dir_for(id)
    cached_path = File.join(dir, "#{id}.mp4")
    was_cached  = File.exist?(cached_path)
    unless was_cached
      template = File.join(dir, "#{id}.%(ext)s")
      run_yt_dlp("-f", "mp4", "--no-playlist", "--max-filesize", MAX_FILESIZE, "-o", template, url)
    end
    { type: "video", filename: extracted_filename(id, dir), cached: was_cached }

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
      raise ArgumentError, "url must be a youtube.com/youtu.be or drive.google.com link" unless url.match?(SUPPORTED_URL_RE)

      id = extract_source_id(url)
      raise ArgumentError, "could not find a source id in that url" unless id

      dir         = media_dir_for(id)
      cached_path = File.join(dir, "#{id}.mp3")
      if File.exist?(cached_path)
        job_set(id, status: "done", percent: 100.0, filename: File.join(File.basename(dir), File.basename(cached_path)),
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

server.mount_proc "/compress" do |req, res|
  res["Content-Type"] = "application/json"
  begin
    payload  = JSON.parse(req.body.to_s)
    filename = compress_for_transcription(payload["filename"].to_s)
    size     = File.size(File.join(OUTPUT_DIR, filename))
    res.body = { filename: filename, size: size }.to_json
  rescue ArgumentError, JSON::ParserError => e
    res.status = 422
    res.body = { error: e.message }.to_json
  rescue StandardError => e
    res.status = 500
    res.body = { error: e.message }.to_json
  end
end

server.mount_proc "/split" do |req, res|
  res["Content-Type"] = "application/json"
  begin
    payload = JSON.parse(req.body.to_s)
    result  = split_for_transcription(payload["filename"].to_s, payload["chunk_minutes"] || 25)
    res.body = result.to_json
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
