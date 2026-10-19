module Ai
  class RequestsController < ApplicationController
    include ActionController::Live
    include Ai::RequestEvents
    layout "ai"

    skip_before_action :verify_authenticity_token

    # ---------------------------------------------------------------------------
    # GET /ai/requests/simple
    # Case 1: Simple request — no hooks, no streaming.
    # ---------------------------------------------------------------------------
    def simple
    end

    # POST /ai/requests/simple
    def simple_call
      req = SimpleRequest.call(input: params.require(:input))

      result = req.result
      render json: {
        output: result.output,
        model:  result.model&.name,
        time:   result.execution_time,
        usage:  usage_json(result.usage),
        cost:   result.usage&.cost&.total
      }
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/streaming
    # Case 2: Same simple request but with token-by-token streaming via SSE.
    # No lifecycle sidebar.
    # ---------------------------------------------------------------------------
    def streaming
    end

    # GET /ai/requests/streaming/stream?input=...
    def streaming_stream
      prepare_sse_response

      input = params.require(:input)

      stream   = response.stream
      sse_done = ActionController::Live::SSE.new(stream, event: "completion")

      req = SimpleRequest.call(
        input:  input,
        token:  build_token_stream(sse_done)
      )

      result = req.result
      sse_done.write({ done: true, model: result.model&.name, time: result.execution_time, usage: usage_json(result.usage), cost: result.usage&.cost&.total }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_done.write({ done: true, error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    ensure
      sse_done.close
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/lifecycle
    # Case 3: Streaming + full lifecycle sidebar with request hook events.
    # (Kept identical to the original ai/support page)
    # ---------------------------------------------------------------------------
    def lifecycle
    end

    # GET /ai/requests/lifecycle/stream?input=...
    def lifecycle_stream
      prepare_sse_response

      input = params.require(:input)

      stream   = response.stream
      sse      = ActionController::Live::SSE.new(stream, event: "processing")
      sse_done = ActionController::Live::SSE.new(stream, event: "completion")

      req = SupportRequest.call(
        input:  input,
        token:  build_token_stream(sse_done),
        stream: build_request_event_stream(sse)
      )

      result = req.result
      sse_done.write({ done: true, usage: usage_json(result.usage), cost: result.usage&.cost&.total }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_done.write({ done: true, error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    ensure
      sse_done.close
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/ruby_llm
    # Case 4: ruby_llm backend — streaming + lifecycle sidebar.
    # Same as Case 3 but HTTP calls go through the ruby_llm gem.
    # ---------------------------------------------------------------------------
    def ruby_llm
    end

    # GET /ai/requests/ruby_llm/stream?input=...
    def ruby_llm_stream
      prepare_sse_response

      input = params.require(:input)

      stream   = response.stream
      sse      = ActionController::Live::SSE.new(stream, event: "processing")
      sse_done = ActionController::Live::SSE.new(stream, event: "completion")

      req = SupportRubyLLMRequest.call(
        input:  input,
        token:  build_token_stream(sse_done),
        stream: build_request_event_stream(sse)
      )

      result = req.result
      sse_done.write({ done: true, usage: usage_json(result.usage), cost: result.usage&.cost&.total }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_done.write({ done: true, error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    ensure
      sse_done.close
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/fallback
    # Case 5: Fallback chain demo — 2 intentionally broken models prepended via
    # req.models.prepend, then SupportRubyLLMRequest's own chain takes over.
    # The lifecycle sidebar shows :retry events for each failed model before
    # the first working model succeeds.
    # ---------------------------------------------------------------------------
    def fallback
    end

    # GET /ai/requests/fallback/stream?input=...
    def fallback_stream
      prepare_sse_response

      input = params.require(:input)

      stream   = response.stream
      sse      = ActionController::Live::SSE.new(stream, event: "processing")
      sse_done = ActionController::Live::SSE.new(stream, event: "completion")

      req = SupportRubyLLMRequest.new(
        input:  input,
        token:  build_token_stream(sse_done),
        stream: build_request_event_stream(sse)
      )

      # Prepend 2 broken models — they will fail and trigger :retry events in the sidebar.
      req.models.prepend([
        { provider: :openrouter, model: "fake-provider/broken-model-one" },
        { provider: :openrouter, model: "fake-provider/broken-model-two" }
      ])

      req.call

      sse_done.write({ done: true, usage: usage_json(req.result&.usage), cost: req.result&.usage&.cost&.total }.to_json)
    rescue ActionController::Live::ClientDisconnected
    rescue StandardError => e
      sse_done.write({ done: true, error: "#{e.class.name.split('::').last}: #{e.message}" }.to_json) rescue nil
    ensure
      sse_done.close
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/memory
    # Case 6: Memory request — conversation history persisted via JsonFile.
    # Each browser session gets its own memory file under storage/ai/memory/sessions/.
    # ---------------------------------------------------------------------------
    def memory
      @session_id = memory_session_id
      mem = AppMemory.new(file_name: "sessions/#{@session_id}")
      mem.load
      @history = mem.turns
    end

    # POST /ai/requests/memory/call
    def memory_call
      mem = AppMemory.new(file_name: "sessions/#{memory_session_id}")

      req = MemoryRequest.call(
        input:  params.require(:input),
        memory: mem
      )

      result = req.result
      render json: {
        output: result.output,
        model:  result.model&.name,
        time:   result.execution_time,
        usage:  usage_json(result.usage),
        cost:   result.usage&.cost&.total
      }
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/image
    # Case 7: Image generation — OpenAI Images API, dall-e-2 256×256 ($0.016/img).
    # ---------------------------------------------------------------------------
    def image
    end

    # POST /ai/requests/image/call
    def image_call
      prompt = params.require(:input)
      req    = ImageRequest.call(input: prompt)
      result = req.result
      render json: {
        b64:   result.output,
        model: result.model&.name,
        time:  result.execution_time,
        usage: usage_json(result.usage),
        cost:  result.usage&.cost&.total
      }
    rescue StandardError => e
      render json: { error: "#{e.class.name.split('::').last}: #{e.message}" }, status: :unprocessable_entity
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/transcribe
    # Case 8: Audio transcription — upload a file, get back the transcript text.
    # Synchronous call, no job id / polling — OpenRouter's transcription endpoint
    # returns the transcript directly (upstream providers time out after ~60s,
    # so long recordings should be split before uploading).
    # ---------------------------------------------------------------------------
    def transcribe
      @models = AudioTranscriptionRequest::MODELS
    end

    # POST /ai/requests/transcribe/call
    def transcribe_call
      file  = params.require(:audio)
      model = params[:model].presence

      raise ArgumentError, "Unknown model: #{model.inspect}" if model && !AudioTranscriptionRequest::MODELS.key?(model)

      req = AudioTranscriptionRequest.new(input: file.tempfile.path)
      req.models.replace([AudioTranscriptionRequest.parse_model(model)]) if model
      req.call

      result = req.result
      render json: {
        text:  result.output,
        model: result.model&.name,
        time:  result.execution_time,
        usage: usage_json(result.usage),
        cost:  result.usage&.cost&.total
      }
    rescue StandardError => e
      render json: { error: "#{e.class.name.split('::').last}: #{e.message}" }, status: :unprocessable_entity
    end

    # ---------------------------------------------------------------------------
    # GET /ai/requests/jev
    # Case 9: Jev (TypeSafe AI) via Vercel AI Gateway — an evaluation model, not a
    # chat model. Returns a typed score, not free text. Shown as raw JSON — no
    # response processing.
    # ---------------------------------------------------------------------------
    def jev
    end

    # POST /ai/requests/jev/call
    def jev_call
      req    = JevRequest.call(input: params.require(:input))
      result = req.result

      render json: {
        output: result.processed, # format :json => parsed Hash, not the raw string
        model:  result.model&.name,
        time:   result.execution_time,
        usage:  usage_json(result.usage)
      }
    rescue StandardError => e
      render json: { error: "#{e.class.name.split('::').last}: #{e.message}" }, status: :unprocessable_entity
    end

    # POST /ai/requests/memory/clear
    def memory_clear
      sid = session[:ai_memory_id]
      if sid
        mem = AppMemory.new(file_name: "sessions/#{sid}")
        mem.load
        mem.delete
        session.delete(:ai_memory_id)
      end
      redirect_to ai_requests_memory_path
    end

    YOUTUBE_STREAM_URL = ENV.fetch("YOUTUBE_STREAM_URL", "http://youtube_stream:4567")

    # ---------------------------------------------------------------------------
    # GET /ai/requests/youtube
    # Case 10: audio download — hands the URL to the standalone youtube_stream
    # container (yt-dlp), which downloads in the background and reports live
    # progress. YouTube and Google Drive URLs are accepted (SUPPORTED_URL_RE
    # in that container's server.rb); Rails itself does no URL validation, it
    # just proxies to that container and surfaces whatever error it returns.
    # ---------------------------------------------------------------------------
    def youtube
    end

    # POST /ai/requests/youtube/start
    # body: { url: "https://youtu.be/..." or "https://drive.google.com/file/d/..." }
    # Returns immediately with a job id — the actual download runs in the
    # youtube_stream container's background thread.
    def youtube_start
      url = params.require(:url)
      uri = URI("#{YOUTUBE_STREAM_URL}/jobs")

      video    = ActiveModel::Type::Boolean.new.cast(params[:video]) || false
      http_res = Net::HTTP.post(uri, { url: url, video: video }.to_json, "Content-Type" => "application/json")
      render json: JSON.parse(http_res.body), status: http_res.code.to_i
    rescue StandardError => e
      render json: { error: e.message }, status: :bad_gateway
    end

    # GET /ai/requests/youtube/status/:job_id
    # Proxies the youtube_stream container's job status — the browser never
    # talks to that container directly, only through Rails.
    def youtube_status
      uri = URI("#{YOUTUBE_STREAM_URL}/jobs/#{params.require(:job_id)}")

      http_res = Net::HTTP.get_response(uri)
      render json: JSON.parse(http_res.body), status: http_res.code.to_i
    rescue StandardError => e
      render json: { error: e.message }, status: :bad_gateway
    end

    # POST /ai/requests/youtube/upload
    # multipart form: { file: <audio/video file> }
    # Alternate source for the same page — skips yt-dlp/youtube_stream
    # entirely, just copies the upload onto the shared filesystem under its
    # own dated directory (same "<DD_MM_YYYY>_<id>/<id>.ext" convention as a
    # yt-dlp download — see server.rb's media_dir_for) and returns
    # { filename: ... } in the exact shape the download job's status
    # endpoint returns. Synchronous — a local file copy is fast even for a
    # large file, unlike an actual network download, so no job id/polling
    # needed here.
    def youtube_upload
      file = params.require(:file)
      ext  = File.extname(file.original_filename).delete_prefix(".").downcase
      raise ArgumentError, "could not determine a file extension from #{file.original_filename.inspect}" if ext.empty?

      # The trailing id is a content hash (not random), so re-uploading the same
      # bytes — even under another name — lands in the existing directory and
      # reuses its transcripts instead of repeating compression/Whisper work.
      hash     = Digest::SHA256.file(file.tempfile.path).hexdigest[0, 8]
      root     = Rails.root.join("storage", "youtube_stream")
      existing = Dir.glob(root.join("*_#{hash}", "*_#{hash}.#{ext}").to_s).first

      if existing
        return render json: {
          filename: "#{File.basename(File.dirname(existing))}/#{File.basename(existing)}",
          size: File.size(existing), reused: true
        }
      end

      slug = File.basename(file.original_filename, ".*").parameterize.presence || "upload"
      id   = "#{slug}_#{hash}"
      dir  = root.join("#{Time.now.strftime('%d_%m_%Y')}_#{id}")
      FileUtils.mkdir_p(dir)

      dest = dir.join("#{id}.#{ext}")
      FileUtils.cp(file.tempfile.path, dest)

      render json: { filename: "#{File.basename(dir)}/#{File.basename(dest)}", size: File.size(dest) }
    rescue StandardError => e
      render json: { error: "#{e.class.name.split('::').last}: #{e.message}" }, status: :unprocessable_entity
    end

    # OpenRouter's audio endpoint rejects a base64-encoded request body over
    # 50 MiB (52_428_800 bytes). Base64 inflates raw bytes by 4/3, so stay
    # well under that on the raw file — 30 MiB raw leaves headroom for the
    # surrounding JSON.
    MAX_RAW_BYTES_FOR_TRANSCRIPTION = 30 * 1024 * 1024

    # Length of each split chunk when a compressed file is still over
    # MAX_RAW_BYTES_FOR_TRANSCRIPTION — 20-30 min per chunk, user-approved
    # trade-off between "one giant risky call" and "too many tiny calls".
    CHUNK_MINUTES = 25

    # POST /ai/requests/youtube/transcribe/start
    # body: { filename: "<video_id>.mp3", model: "openai/whisper-1" (optional),
    #         timecodes: true|false (optional, defaults to true) }
    # Async, same reasoning as the download step: compress-if-needed + a real
    # Whisper call on a large file can take minutes, and one giant blocking
    # request is fragile (a long silent HTTP response is exactly the kind of
    # thing an intermediate proxy/browser can kill, surfacing as a client-side
    # "network error" even though the server eventually finishes fine).
    # Returns a job id immediately; the work runs on a background Thread and
    # is polled via /youtube/transcribe/status/:job_id.
    #
    # `timecodes` is silently downgraded to false (no error) when the chosen
    # model isn't in AudioTranscriptionRequest::TIMECODE_MODELS — the dropdown
    # already marks which models support it, so a mismatch here just means a
    # plain-text result instead of a 422.
    def youtube_transcribe_start
      filename = params.require(:filename)
      validate_relative_filename!(filename)

      path = Rails.root.join("storage", "youtube_stream", filename)
      raise ArgumentError, "file not found: #{filename}" unless File.exist?(path)

      model = params[:model].presence
      raise ArgumentError, "unknown model: #{model.inspect}" if model && !AudioTranscriptionRequest::MODELS.key?(model)

      language = params[:language].presence
      language = nil if language == "auto"
      raise ArgumentError, "unknown language: #{language.inspect}" if language && !AudioTranscriptionRequest::LANGUAGES.key?(language)

      requested_timecodes = params[:timecodes].nil? ? true : ActiveModel::Type::Boolean.new.cast(params[:timecodes])
      timecodes = AudioTranscriptionRequest.structured_output?(model, requested_timecodes)

      # Same fix as prepare_sse_response below: ActionDispatch::ServerTiming
      # crashes on Rails 8 (NoMethodError: undefined method 'group_by' for nil)
      # when any work happens on a separate Thread and this env key was never
      # initialized — previously only hit via ActionController::Live, now also
      # hit by this action's own background Thread.
      request.env["action_dispatch.server_timing_events"] ||= []

      job_id = SecureRandom.hex(8)
      cached = read_transcript_cache(filename, timecodes)

      # Transcripts made with a different language setting (including the old
      # auto-detect runs) are stale: drop them so the file is re-recognized.
      # Split chunks and compressed audio are kept, only text outputs go.
      if cached && cached[:language].to_s != language.to_s
        purge_transcripts(Rails.root.join("storage", "youtube_stream", File.dirname(filename)))
        cached = nil
      end

      if cached
        transcribe_job_write(job_id, status: "done", cached: true, **cached)
      else
        transcribe_job_write(job_id, status: "running")
        Thread.new do
          Rails.application.executor.wrap do
            run_transcription_job(job_id, filename, model, timecodes, language)
          end
        end
      end

      render json: { id: job_id, timecodes: timecodes }, status: 202
    rescue StandardError => e
      render json: { error: "#{e.class.name.split('::').last}: #{e.message}" }, status: :unprocessable_entity
    end

    # GET /ai/requests/youtube/transcribe/status/:job_id
    def youtube_transcribe_status
      job = transcribe_job_read(params.require(:job_id))
      raise ArgumentError, "unknown or expired job id" unless job

      render json: job
    rescue StandardError => e
      render json: { error: e.message }, status: :not_found
    end

    # GET /ai/requests/youtube/transcript?dir=<media dir>&part=all|<n>&format=txt|json
    # Downloads finished transcripts from a media directory: one part, all
    # parts joined, or a single combined JSON (parts + merged segments).
    # Part timestamps are already global (offset-adjusted when written), so
    # joining the part files needs no re-basing.
    def youtube_transcript
      dir = params.require(:dir)
      validate_relative_filename!(dir)
      raise ArgumentError, "invalid dir" if dir.include?("/")

      path = Rails.root.join("storage", "youtube_stream", dir)
      raise ArgumentError, "not found: #{dir}" unless File.directory?(path)

      parts = transcript_parts(path)
      raise ArgumentError, "no transcript yet for #{dir}" if parts.empty?

      base = dir.sub(/\A\d{2}_\d{2}_\d{4}_/, "")

      if params[:format] == "json"
        body = {
          source: dir, timecodes: parts.any? { |p| p[:segments] }, parts: parts,
          segments: parts.flat_map { |p| p[:segments] || [] }, text: parts.map { |p| p[:text] }.join("\n")
        }
        return send_data JSON.pretty_generate(body), type: "application/json", disposition: "attachment", filename: "#{base}.transcript.json"
      end

      if params[:part].present? && params[:part] != "all"
        part = parts.find { |p| p[:index] == params[:part].to_i }
        raise ArgumentError, "no such part" unless part

        send_data part[:text], type: "text/plain; charset=utf-8", disposition: "attachment",
                               filename: format("%s.part%02d.txt", base, part[:index])
      else
        send_data parts.map { |p| p[:text] }.join("\n"), type: "text/plain; charset=utf-8",
                  disposition: "attachment", filename: "#{base}.transcript.txt"
      end
    rescue StandardError => e
      render json: { error: e.message }, status: :not_found
    end

    private

    # Filenames coming from the client (or proxied back from youtube_stream)
    # now legitimately contain one subdirectory level — each source lives in
    # its own "<id>/" or "<DD_MM_YYYY>_<id>/" directory (see server.rb's
    # media_dir_for) — so a bare `include?("/")` rejection would break every
    # real request. Still blocks traversal and anything nested deeper than
    # that one level.
    def validate_relative_filename!(filename)
      raise ArgumentError, "invalid filename" if filename.include?("..") || filename.start_with?("/") || filename.count("/") > 1
    end

    # Runs in the background Thread spawned by youtube_transcribe_start above.
    # Dispatches to the single-shot or chunked path depending on file size
    # after compression — chunking is only needed once a single request would
    # still exceed OpenRouter's body-size limit.
    def run_transcription_job(job_id, filename, model, timecodes, language)
      original_filename = filename
      path       = Rails.root.join("storage", "youtube_stream", filename)
      compressed = false

      if File.size(path) > MAX_RAW_BYTES_FOR_TRANSCRIPTION
        filename, path = compress_via_stream(filename)
        compressed = true
      end

      if File.size(path) > MAX_RAW_BYTES_FOR_TRANSCRIPTION
        run_chunked_transcription_job(job_id, original_filename, filename, model, compressed, timecodes, language)
      else
        run_single_transcription_job(job_id, original_filename, filename, path, model, compressed, timecodes, language)
      end
    rescue StandardError => e
      transcribe_job_write(job_id, status: "error", error: "#{e.class.name.split('::').last}: #{e.message}")
    end

    # Reads whatever transcript a media directory holds: the chunked manifest's
    # part files if present, otherwise the single-shot cache json.
    # => [{ index:, text:, segments: (only with timecodes) }, ...]
    def transcript_parts(path)
      manifest = Dir.glob(path.join("*.manifest.json").to_s).first
      if manifest
        return JSON.parse(File.read(manifest))["parts"].map do |p|
          part = { index: p["index"], text: File.read(path.join(p["txt"])) }
          part[:segments] = JSON.parse(File.read(path.join(p["json"])))["segments"] if p["json"]
          part
        end
      end

      cache = Dir.glob(path.join("*.transcript.json").to_s).reject { |f| f.include?(".part") }.first
      return [] unless cache

      data = JSON.parse(File.read(cache))
      return [] unless data["text"]

      [{ index: 1, text: data["text"], segments: data["segments"] }.compact]
    end

    # Removes every transcript output in a media directory (cache json, part
    # files, manifest) — never the media, compressed copy or split chunks.
    def purge_transcripts(dir)
      Dir.glob(dir.join("*.{transcript.json,transcript.txt,manifest.json}").to_s).each { |f| File.delete(f) }
    end

    def compress_via_stream(filename)
      uri      = URI("#{YOUTUBE_STREAM_URL}/compress")
      http_res = Net::HTTP.post(uri, { filename: filename }.to_json, "Content-Type" => "application/json")
      data     = JSON.parse(http_res.body)
      raise data["error"] if http_res.code.to_i >= 400

      new_filename = data["filename"]
      [new_filename, Rails.root.join("storage", "youtube_stream", new_filename)]
    end

    def run_single_transcription_job(job_id, original_filename, filename, path, model, compressed, timecodes, language)
      req = AudioTranscriptionRequest.new(input: path.to_s)
      req.models.replace(transcription_chain(model, timecodes, language)) if model || timecodes || language
      req.call

      result = req.result
      segments    = nil
      diarization = false
      text = result.output

      if timecodes
        parsed      = JSON.parse(result.output)
        segments    = parsed["segments"] || []
        diarization = segments.any? { |s| s["speaker"] }
        text        = render_bucketed_transcript(segments)
      end

      data = {
        text:        text,
        segments:    segments,
        timecodes:   timecodes,
        language:    language,
        diarization: diarization,
        model:       result.model&.name,
        time:        result.execution_time,
        usage:       usage_json(result.usage),
        cost:        result.usage&.cost&.total,
        compressed:  compressed,
        filename:    filename
      }.compact

      write_transcript_cache(original_filename, data, timecodes)
      transcribe_job_write(job_id, status: "done", **data)
    end

    # Builds the model chain for a transcription call, preserving the
    # existing dropdown semantics: an explicitly chosen model runs alone (no
    # auto-fallback) so a deliberately-broken model's failure stays visible
    # instead of being masked, and so a model that unconditionally requires
    # extra params (e.g. the diarize model) never silently falls back to a
    # plain model that would drop the very feature it was picked for. No
    # explicit model falls back to AudioTranscriptionRequest's own default
    # two-model chain. `timecodes` here is already the resolved value from
    # AudioTranscriptionRequest.structured_output? — true means "apply
    # whichever extra params this model needs/supports", covering both the
    # optional whisper verbose_json case and the mandatory diarize case.
    def transcription_chain(model, timecodes, language = nil)
      keys = model ? [model] : [AudioTranscriptionRequest::DEFAULT_MODEL, "openrouter:openai/whisper-1"]

      keys.map do |key|
        entry = AudioTranscriptionRequest.parse_model(key)
        extra = timecodes ? (AudioTranscriptionRequest::REQUIRED_PARAMS[key] || AudioTranscriptionRequest::OPTIONAL_TIMECODE_PARAMS[key] || {}) : {}
        entry.merge(extra).merge({ language: language }.compact)
      end
    end

    # Splits the (already-compressed) file into CHUNK_MINUTES-long pieces via
    # the youtube_stream container's /split endpoint, transcribes each chunk
    # in turn with response_format: "verbose_json" so real per-segment
    # timestamps come back, offsets each chunk's timestamps by the cumulative
    # duration of the chunks before it (so timestamps read continuously across
    # the whole recording), and writes one .transcript.txt/.transcript.json
    # pair per chunk plus a .manifest.json listing all parts. Job status is
    # updated after every chunk so the UI can show real chunk-by-chunk
    # progress instead of one opaque "running" spinner for a multi-hour file.
    #
    # No speaker diarization: verified against real OpenRouter calls (see
    # AudioTranscriptionRequest's MODELS comment) that diarization does not
    # currently work through OpenRouter for either provider its own docs cite
    # as an example — recorded in the manifest so it's not silently missing.
    def run_chunked_transcription_job(job_id, original_filename, filename, model, compressed, timecodes, language)
      uri        = URI("#{YOUTUBE_STREAM_URL}/split")
      http_res   = Net::HTTP.post(uri, { filename: filename, chunk_minutes: CHUNK_MINUTES }.to_json, "Content-Type" => "application/json")
      split_data = JSON.parse(http_res.body)
      raise split_data["error"] if http_res.code.to_i >= 400

      chunk_files = split_data["chunks"]
      total       = chunk_files.size
      chunks      = chunk_files.each_with_index.map do |c, i|
        { index: i, filename: c["filename"], duration: c["duration"], status: "pending" }
      end

      transcribe_job_write(job_id, status: "running", chunked: true, total_chunks: total, current_chunk: 0, chunks: chunks)

      base         = File.basename(original_filename, ".*")
      media_dir    = File.dirname(original_filename)
      storage_root = Rails.root.join("storage", "youtube_stream")
      storage      = storage_root.join(media_dir)
      chain        = transcription_chain(model, timecodes, language)

      offset      = 0.0
      parts       = []
      saw_speaker = false

      chunk_files.each_with_index do |c, i|
        part_index = i + 1
        part_base  = format("%s.part%02d", base, part_index)
        txt_path   = storage.join("#{part_base}.transcript.txt")
        json_path  = storage.join("#{part_base}.transcript.json")
        part = { index: part_index, txt: File.basename(txt_path) }

        # Resume support: a chunk whose part file already exists on disk (from
        # a previous run of this same job that got interrupted — e.g. a Rails
        # process restart) is not re-transcribed. Chunk splitting itself is
        # already cached the same way (see /split), so re-running a job on the
        # same file after an interruption only pays for the chunks that never
        # finished, not the whole thing over again.
        if File.exist?(txt_path) && (!timecodes || File.exist?(json_path))
          chunks[i][:status] = "done (cached)"
          if timecodes
            cached_json = JSON.parse(File.read(json_path))
            cached_segments = cached_json["segments"] || []
            part[:json]     = File.basename(json_path)
            part[:segments] = cached_segments.size
            saw_speaker ||= cached_segments.any? { |s| s["speaker"] }
          end
          chunks[i][:txt] = File.basename(txt_path)
          parts << part
          transcribe_job_write(job_id, current_chunk: i + 1, chunks: chunks)

          chunk_duration = c["duration"].to_f
          offset += chunk_duration > 0 ? chunk_duration : (CHUNK_MINUTES * 60)
          next
        end

        chunks[i][:status] = "transcribing"
        transcribe_job_write(job_id, current_chunk: i + 1, chunks: chunks)

        req = AudioTranscriptionRequest.new(input: storage_root.join(c["filename"]).to_s)
        req.models.replace(chain)
        req.call

        if timecodes
          data     = JSON.parse(req.result.output)
          segments = (data["segments"] || []).map do |seg|
            entry = { "start" => seg["start"].to_f + offset, "end" => seg["end"].to_f + offset, "text" => seg["text"] }
            entry["speaker"] = seg["speaker"] if seg["speaker"]
            entry
          end
          File.write(txt_path, render_bucketed_transcript(segments))
          File.write(json_path, { segments: segments, model: req.result.model&.name }.to_json)
          part[:json]     = File.basename(json_path)
          part[:segments] = segments.size
          saw_speaker ||= segments.any? { |s| s["speaker"] }
        else
          File.write(txt_path, req.result.output)
        end

        chunks[i][:status] = "done"
        chunks[i][:txt]    = File.basename(txt_path)
        parts << part
        transcribe_job_write(job_id, current_chunk: i + 1, chunks: chunks)

        chunk_duration = c["duration"].to_f
        offset += chunk_duration > 0 ? chunk_duration : (CHUNK_MINUTES * 60)
      end

      manifest_path = storage.join("#{base}.manifest.json")
      manifest = {
        original_filename: original_filename,
        model:              model || AudioTranscriptionRequest::DEFAULT_MODEL,
        chunk_minutes:      CHUNK_MINUTES,
        total_parts:        parts.size,
        timecodes:          timecodes,
        language:           language,
        diarization:        saw_speaker,
        diarization_note:   saw_speaker ? nil : (
          "No speaker labels in this run. OpenRouter's transcription endpoint does not support diarization at " \
          "all — verified against both provider/model combinations its own docs cite as examples (azure + " \
          "microsoft/mai-transcribe-2, deepgram + deepgram/nova-3): both return the same \"does not support " \
          "large audio inputs\" 400 regardless of file size. For real speaker labels, pick " \
          "\"OpenAI: GPT-4o Transcribe Diarize (direct)\" from the model dropdown."
        ),
        parts:              parts
      }.compact
      File.write(manifest_path, manifest.to_json)

      result_data = {
        chunked:      true,
        total_chunks: total,
        parts:        parts,
        manifest:     File.basename(manifest_path),
        timecodes:    timecodes,
        language:     language,
        diarization:  saw_speaker,
        compressed:   compressed,
        filename:     filename
      }

      write_transcript_cache(original_filename, result_data, timecodes)
      transcribe_job_write(job_id, status: "done", **result_data)
    end

    # Groups fine-grained ASR segments into fixed-width (default 15s) buckets
    # for a readable transcript file — the model's own segments are typically
    # every 2-5s (natural speech pauses), finer than requested; bucketing
    # keeps the "timestamp every ~15s" readability the file is meant for
    # without discarding any of the underlying per-segment data (that stays
    # in the sibling .transcript.json). When a segment carries a `speaker`
    # (gpt-4o-transcribe-diarize only — Whisper never sets this), it's
    # prefixed onto that segment's text so turn-taking stays visible even
    # after bucketing.
    def render_bucketed_transcript(segments, bucket_seconds: 15)
      return "" if segments.empty?

      buckets = {}
      segments.each do |seg|
        bucket = (seg["start"].to_f / bucket_seconds).floor * bucket_seconds
        text   = seg["text"].to_s.strip
        text   = "[#{seg['speaker']}] #{text}" if seg["speaker"]
        (buckets[bucket] ||= []) << text
      end

      buckets.sort.map { |start, texts| "[#{format_timestamp(start)}] #{texts.join(' ').strip}" }.join("\n")
    end

    def format_timestamp(seconds)
      total = seconds.to_i
      h = total / 3600
      m = (total % 3600) / 60
      s = total % 60
      h > 0 ? format("%02d:%02d:%02d", h, m, s) : format("%02d:%02d", m, s)
    end

    # Cached by the ORIGINAL (client-facing) filename, not the possibly-
    # compressed internal one — so the cache hits regardless of whether
    # compression happened, and survives even if the compressed copy is later
    # cleaned up. Keyed on filename + timecodes (the two produce differently-
    # shaped results, plain text vs. segments/parts), but not on model:
    # switching models in the dropdown won't force a fresh call — delete the
    # relevant .transcript.json file manually if you want to re-run with a
    # different model.
    def transcript_cache_path(filename, timecodes)
      dir    = File.dirname(filename)
      base   = File.basename(filename, ".*")
      suffix = timecodes ? ".timecodes" : ""
      Rails.root.join("storage", "youtube_stream", dir, "#{base}#{suffix}.transcript.json")
    end

    def read_transcript_cache(filename, timecodes)
      path = transcript_cache_path(filename, timecodes)
      return nil unless File.exist?(path)

      JSON.parse(File.read(path), symbolize_names: true)
    rescue JSON::ParserError
      nil
    end

    def write_transcript_cache(filename, data, timecodes)
      File.write(transcript_cache_path(filename, timecodes), data.to_json)
    end

    # Rails.cache rather than a plain in-process Hash: survives Rails' dev-mode
    # class reloading (a bare class-level Hash constant would get wiped on the
    # next code reload), and is already thread-safe.
    def transcribe_job_write(job_id, **fields)
      key  = "yt_transcribe:#{job_id}"
      data = (Rails.cache.read(key) || {}).merge(fields)
      Rails.cache.write(key, data, expires_in: 30.minutes)
    end

    def transcribe_job_read(job_id)
      Rails.cache.read("yt_transcribe:#{job_id}")
    end

    def memory_session_id
      session[:ai_memory_id] ||= SecureRandom.hex(8)
    end

    def prepare_sse_response
      # ActionDispatch::ServerTiming crashes with ActionController::Live on Rails 8
      # because the events array is nil when the stream runs on a separate thread.
      request.env["action_dispatch.server_timing_events"] ||= []

      # Tell the browser this is a streaming SSE response, not a regular HTTP response.
      response.headers["Content-Type"]  = "text/event-stream"

      # Disable HTTP caching — every connection must reach the server.
      response.headers["Cache-Control"] = "no-cache"

      # Disable nginx / proxy buffering so tokens reach the browser immediately.
      response.headers["X-Accel-Buffering"] = "no"
    end

    def build_token_stream(sse)
      ->(token) { sse.write({ token: token }.to_json) }
    end

    def usage_json(usage)
      return nil unless usage
      { input: usage.tokens.input, output: usage.tokens.output, total: usage.tokens.total }
    end
  end
end
