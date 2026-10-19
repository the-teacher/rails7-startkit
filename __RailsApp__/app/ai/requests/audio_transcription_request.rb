class AudioTranscriptionRequest < ActiveHarness::Request
  transcribe true

  # Dropdown value format: "<provider>:<model id>" — explicit about which
  # provider a given entry goes through, since several models are reachable
  # both via :openrouter (vendor-prefixed model id, e.g. "openai/whisper-1")
  # and directly via :openai (bare model id, e.g. "whisper-1"), and the two
  # routes can behave very differently for the exact same underlying model
  # (see notes below) — the label makes that unambiguous instead of hiding it.
  #
  # --- OpenRouter route ---
  # Confirmed broken via OpenRouter on a real large audio file — several
  # models fail with "The selected model does not support large audio inputs"
  # (400) regardless of file size (re-tested down to a 17.7MB file, still
  # fails) — this looks like a broken/unwired route on OpenRouter's backend,
  # not an actual size limit. openai/gpt-4o-mini-transcribe and
  # openai/gpt-4o-transcribe specifically: confirmed via a real direct-OpenAI
  # call (provider: :openai, same 1-minute test clip) that the MODEL itself
  # works fine (774/776 total tokens, real transcript) — it's OpenRouter's
  # proxy for these two that's broken, not the model.
  #
  # --- Direct OpenAI route ---
  # gpt-4o-transcribe-diarize is OpenAI's real speaker-diarization model —
  # verified with a real call: response_format: "diarized_json" +
  # chunking_strategy: "auto" returns segments with a genuine non-empty
  # `speaker` field. This is the only model on this list that actually
  # diarizes — OpenRouter's diarization routes (see the gem's CHANGELOG) do
  # not work at all, on any file size, for either provider OpenRouter's own
  # docs cite as an example. Direct-OpenAI-only, 25MB file size cap (vs. this
  # app's general 30MB single-shot compression threshold — a file just under
  # 30MB but over 25MB would still fail with this specific model; not worth a
  # separate per-model threshold for a demo, but worth knowing about).
  MODELS = {
    "openrouter:openai/whisper-1"                  => "OpenAI: Whisper 1 (OpenRouter)",
    "openrouter:openai/whisper-large-v3"           => "OpenAI: Whisper Large V3 (OpenRouter)",
    "openrouter:openai/whisper-large-v3-turbo"     => "OpenAI: Whisper Large V3 Turbo (OpenRouter)",
    "openrouter:openai/gpt-4o-mini-transcribe"     => "OpenAI: GPT-4o Mini Transcribe (OpenRouter — broken, use direct)",
    "openrouter:openai/gpt-4o-transcribe"          => "OpenAI: GPT-4o Transcribe (OpenRouter — broken, use direct)",
    "openrouter:openai/gpt-transcribe"             => "OpenAI: GPT Transcribe (OpenRouter — system failure)",
    "openrouter:deepgram/nova-3"                   => "Deepgram: Nova-3 (OpenRouter)",
    "openrouter:google/chirp-3"                    => "Google: Chirp 3 (OpenRouter)",
    "openrouter:microsoft/mai-transcribe-1.5"      => "Microsoft: MAI-Transcribe 1.5 (OpenRouter)",
    "openrouter:mistralai/voxtral-mini-transcribe" => "Mistral: Voxtral Mini Transcribe (OpenRouter)",
    "openrouter:nvidia/parakeet-tdt-0.6b-v3"       => "NVIDIA: Parakeet TDT 0.6B v3 (OpenRouter)",
    "openrouter:qwen/qwen3-asr-flash-2026-02-10"   => "Qwen: Qwen3 ASR Flash (OpenRouter)",

    "openai:whisper-1"                 => "OpenAI: Whisper 1 (direct)",
    "openai:gpt-4o-transcribe"         => "OpenAI: GPT-4o Transcribe (direct)",
    "openai:gpt-4o-mini-transcribe"    => "OpenAI: GPT-4o Mini Transcribe (direct)",
    "openai:gpt-4o-transcribe-diarize" => "OpenAI: GPT-4o Transcribe Diarize (direct — speaker labels, 25MB cap)"
  }.freeze

  # Confirmed on a real file (compressed, ~S9E9ozkGW9Y) via OpenRouter:
  # whisper-large-v3-turbo (routed to Groq) took 14.5s / $0.0254 vs
  # whisper-1's 104.2s / $0.2284 — ~7x faster, ~9x cheaper, comparable
  # transcript completeness.
  DEFAULT_MODEL = "openrouter:openai/whisper-large-v3-turbo".freeze

  # Spoken-language choices for the UI ("auto" = let the model detect). Sent as
  # the ISO-639-1 `language` param; auto-detect can pick a wrong, similar-
  # sounding language on mixed or accented speech, so pinning it helps.
  LANGUAGES = {
    "ru" => "Русский", "en" => "English", "uk" => "Українська", "de" => "Deutsch",
    "fr" => "Français", "es" => "Español", "it" => "Italiano", "pl" => "Polski",
    "pt" => "Português", "tr" => "Türkçe", "zh" => "中文", "ja" => "日本語"
  }.freeze

  # Extra request params REQUIRED for a model to work at all on real (>30s)
  # audio — always sent regardless of the "Timecodes" checkbox, since there
  # is no meaningful plain-text mode for these (gpt-4o-transcribe-diarize's
  # whole purpose is the diarized_json/speaker output, and chunking_strategy
  # is mandatory past 30 seconds per OpenAI's docs).
  REQUIRED_PARAMS = {
    "openai:gpt-4o-transcribe-diarize" => { response_format: "diarized_json", chunking_strategy: "auto" }
  }.freeze

  # Extra request params sent only when "Timecodes" is checked — purely
  # optional structured-timestamp add-ons; these models work fine without
  # them too. Confirmed via a real response_format: "verbose_json" call —
  # whisper-family only, OpenAI's own API restricts it to whisper-1 (the
  # gpt-4o-transcribe family only supports plain json/text), and OpenRouter
  # mirrors that upstream restriction.
  OPTIONAL_TIMECODE_PARAMS = {
    "openrouter:openai/whisper-1"              => { response_format: "verbose_json", timestamp_granularities: ["segment"] },
    "openrouter:openai/whisper-large-v3"       => { response_format: "verbose_json", timestamp_granularities: ["segment"] },
    "openrouter:openai/whisper-large-v3-turbo" => { response_format: "verbose_json", timestamp_granularities: ["segment"] }
  }.freeze

  # Models the "Timecodes" checkbox in the UI marks as supported. Requesting
  # timecodes with a model not in this list is silently ignored (falls back
  # to a plain-text call) instead of erroring — see youtube_transcribe_start.
  TIMECODE_MODELS = (REQUIRED_PARAMS.keys + OPTIONAL_TIMECODE_PARAMS.keys).freeze

  # Splits a "<provider>:<model id>" dropdown value (a MODELS key) into a
  # { provider:, model: } hash ready to feed into `models.replace`.
  def self.parse_model(value)
    provider, model_id = value.to_s.split(":", 2)
    { provider: provider.to_sym, model: model_id }
  end

  # Whether calling `model` (a MODELS key, or nil for the default chain) with
  # `timecodes` (the raw checkbox value) will actually return structured
  # segment data — true unconditionally for REQUIRED_PARAMS models (e.g. the
  # diarize model, which has no other mode), otherwise only when the checkbox
  # is on AND the model supports it.
  def self.structured_output?(model, timecodes)
    key = model || DEFAULT_MODEL
    REQUIRED_PARAMS.key?(key) || (timecodes && OPTIONAL_TIMECODE_PARAMS.key?(key))
  end

  # deepgram/nova-3 used to be the second fallback here, but it fails on large
  # audio via OpenRouter (see MODELS comment above) — no point falling back
  # to something that breaks on exactly the files a fallback needs to handle.
  # Just turbo -> whisper-1, both confirmed to work on large files via OpenRouter.
  model do
    use      provider: :openrouter, model: "openai/whisper-large-v3-turbo"
    fallback provider: :openrouter, model: "openai/whisper-1"
  end
end
