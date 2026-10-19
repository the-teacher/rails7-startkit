// Case 10: YouTube Audio Download — async job started via
// POST /ai/requests/youtube/start, progress polled via
// GET /ai/requests/youtube/status/:id until status is "done" or "error".
(function () {
  const form = document.getElementById("ah-form");
  const input = document.getElementById("ah-input");
  const btn = document.getElementById("ah-btn");
  const output = document.getElementById("ah-output");
  const progressWrap = document.getElementById("ah-yt-progress-wrap");
  const progressBar = document.getElementById("ah-yt-progress-bar");
  const percentEl = document.getElementById("ah-yt-percent");
  const sizeEl = document.getElementById("ah-yt-size");
  const speedEl = document.getElementById("ah-yt-speed");
  const etaEl = document.getElementById("ah-yt-eta");
  const filenameEl = document.getElementById("ah-yt-filename");
  const transcribeWrap = document.getElementById("ah-yt-transcribe-wrap");
  const transcribeBtn = document.getElementById("ah-yt-transcribe-btn");
  const modelSelect = document.getElementById("ah-yt-model");
  const timecodesCheckbox = document.getElementById("ah-yt-timecodes");
  const timecodesHint = document.getElementById("ah-yt-timecodes-hint");
  const transcriptWrap = document.getElementById("ah-yt-transcript-wrap");
  const transcriptEl = document.getElementById("ah-yt-transcript");
  const transcriptMetaEl = document.getElementById("ah-yt-transcript-meta");
  const uploadForm = document.getElementById("ah-upload-form");
  const uploadInput = document.getElementById("ah-upload-input");
  const uploadLabel = document.getElementById("ah-upload-label");
  const uploadFilenameEl = document.getElementById("ah-upload-filename");
  const uploadBtn = document.getElementById("ah-upload-btn");
  if (!form) return;

  function selectedModelOption() {
    return modelSelect.options[modelSelect.selectedIndex];
  }

  function modelSupportsTimecodes() {
    const opt = selectedModelOption();
    return !!opt && opt.dataset.timecodes === "true";
  }

  function modelRequiresTimecodes() {
    const opt = selectedModelOption();
    return !!opt && opt.dataset.required === "true";
  }

  function updateTimecodesHint() {
    if (modelRequiresTimecodes()) {
      // e.g. gpt-4o-transcribe-diarize — there's no plain-text mode for this
      // model, so the checkbox can't actually turn anything off. Force it on
      // and disabled instead of silently ignoring an unchecked box.
      timecodesCheckbox.checked = true;
      timecodesCheckbox.disabled = true;
      timecodesHint.textContent = "This model always returns speaker-labeled segments — the checkbox has no effect.";
      timecodesHint.style.display = "block";
      return;
    }

    timecodesCheckbox.disabled = false;
    const show = timecodesCheckbox.checked && !modelSupportsTimecodes();
    timecodesHint.textContent = "Selected model doesn't support timecodes — ignoring, will return plain text.";
    timecodesHint.style.display = show ? "block" : "none";
  }

  modelSelect.addEventListener("change", updateTimecodesHint);
  timecodesCheckbox.addEventListener("change", updateTimecodesHint);
  updateTimecodesHint();

  let pollTimer = null;
  let transcribePollTimer = null;
  let currentFilename = null;

  function stopPolling() {
    if (pollTimer) {
      clearInterval(pollTimer);
      pollTimer = null;
    }
  }

  function resetUI() {
    stopPolling();
    progressWrap.style.display = "flex";
    progressBar.style.width = "0%";
    percentEl.textContent = "0%";
    sizeEl.textContent = "";
    speedEl.textContent = "";
    etaEl.textContent = "";
    filenameEl.textContent = "";
    output.innerHTML = '<span class="ah-placeholder">Starting…</span>';
    currentFilename = null;
    transcribeWrap.style.display = "none";
    timecodesHint.style.display = "none";
    transcriptWrap.style.display = "none";
    transcriptEl.textContent = "";
    transcriptMetaEl.textContent = "";
  }

  // Shared by both sources — a finished yt-dlp download and a finished local
  // upload end up in the exact same state: a filename on the shared
  // filesystem, ready for the "Recognize audio" button.
  function showReadyForTranscription(filename) {
    currentFilename = filename;
    transcribeWrap.style.display = "flex";
    updateTimecodesHint();
  }

  function renderJob(job) {
    const pct = job.percent || 0;
    progressBar.style.width = pct + "%";
    percentEl.textContent = pct.toFixed(1) + "%";
    sizeEl.textContent = job.total ? "of " + job.total : "";
    speedEl.textContent = job.speed ? job.speed : "";
    etaEl.textContent = job.eta ? "ETA " + job.eta : "";
    const names = [job.filename, job.video_filename].filter(Boolean);
    if (names.length) filenameEl.textContent = names.join("\n");
    const stageLabel = job.stage === "video" ? "video" : "audio";

    if (job.status === "starting" || job.status === "downloading") {
      output.textContent = job.status === "starting" ? "Starting download…" : "Downloading " + stageLabel + "…";
    } else if (job.status === "done") {
      stopPolling();
      progressBar.style.width = "100%";
      percentEl.textContent = "100%";
      const sizeStr = job.size ? " (" + (job.size / 1024 / 1024).toFixed(2) + " MB)" : "";
      output.textContent = job.cached
        ? "✓ Already downloaded — reusing cached file: " + job.filename + sizeStr
        : "✓ Done — " + job.filename + sizeStr;
      if (job.video_filename) output.textContent += "\nvideo: " + job.video_filename;
      if (job.filename) showReadyForTranscription(job.filename);
    } else if (job.status === "error") {
      stopPolling();
      output.textContent = "✗ Error: " + (job.error || "unknown error");
    }
  }

  function pollStatus(id) {
    fetch("/ai/requests/youtube/status/" + id)
      .then((r) => r.json())
      .then((job) => {
        if (job.error && !job.status) {
          stopPolling();
          output.textContent = "✗ Error: " + job.error;
          return;
        }
        renderJob(job);
      })
      .catch(() => {
        stopPolling();
        output.textContent = "✗ Network error while polling status.";
      });
  }

  form.addEventListener("submit", (e) => {
    e.preventDefault();
    const url = input.value.trim();
    if (!url) return;

    resetUI();
    btn.disabled = true;
    btn.textContent = "Starting…";

    fetch("/ai/requests/youtube/start", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ url: url, video: document.getElementById("ah-yt-video").checked }),
    })
      .then((r) => r.json())
      .then((data) => {
        if (data.error) {
          output.textContent = "✗ Error: " + data.error;
          return;
        }
        btn.textContent = "Downloading…";
        pollTimer = setInterval(() => pollStatus(data.id), 700);
        pollStatus(data.id);
      })
      .catch(() => {
        output.textContent = "✗ Network error.";
      })
      .finally(() => {
        btn.disabled = false;
        btn.textContent = "Download";
      });
  });

  uploadInput.addEventListener("change", () => {
    const file = uploadInput.files[0];
    if (file) {
      uploadFilenameEl.textContent = file.name;
      uploadLabel.classList.add("has-file");
    } else {
      uploadFilenameEl.textContent = "Choose a file from disk…";
      uploadLabel.classList.remove("has-file");
    }
  });

  uploadForm.addEventListener("submit", (e) => {
    e.preventDefault();
    const file = uploadInput.files[0];
    if (!file) return;

    stopPolling();
    progressWrap.style.display = "none";
    transcribeWrap.style.display = "none";
    timecodesHint.style.display = "none";
    transcriptWrap.style.display = "none";
    filenameEl.textContent = "";
    output.innerHTML = '<span class="ah-placeholder">Uploading…</span>';
    uploadBtn.disabled = true;
    uploadBtn.textContent = "Uploading…";

    const formData = new FormData();
    formData.append("file", file);

    fetch("/ai/requests/youtube/upload", {
      method: "POST",
      body: formData,
    })
      .then((r) => r.json())
      .then((data) => {
        if (data.error) {
          output.textContent = "✗ Error: " + data.error;
          return;
        }
        const sizeStr = data.size ? " (" + (data.size / 1024 / 1024).toFixed(2) + " MB)" : "";
        output.textContent = "✓ Uploaded — " + data.filename + sizeStr;
        filenameEl.textContent = data.filename;
        showReadyForTranscription(data.filename);
      })
      .catch(() => {
        output.textContent = "✗ Network error.";
      })
      .finally(() => {
        uploadBtn.disabled = false;
        uploadBtn.textContent = "Upload";
      });
  });

  function stopTranscribePolling() {
    if (transcribePollTimer) {
      clearInterval(transcribePollTimer);
      transcribePollTimer = null;
    }
  }

  function renderChunkList(chunks) {
    if (!chunks || !chunks.length) return "";
    const icon = { pending: "⏳", transcribing: "…", done: "✓", error: "✗" };
    return chunks
      .map((c) => {
        const dur = c.duration ? " (" + Math.round(c.duration / 60) + " min)" : "";
        return (icon[c.status] || "•") + " part " + (c.index + 1) + dur + " — " + c.status;
      })
      .join("\n");
  }

  const downloadsEl = document.getElementById("ah-yt-downloads");

  function renderDownloads(job) {
    downloadsEl.textContent = "";
    if (!job || !job.filename || job.filename.indexOf("/") < 0) return;
    const dir = encodeURIComponent(job.filename.split("/")[0]);
    const base = "/ai/requests/youtube/transcript?dir=" + dir;
    const links = [["⬇ All (.txt)", "&part=all"], ["⬇ Full (.json)", "&format=json"]];
    (job.parts || []).forEach((p) => {
      if ((job.parts || []).length > 1) links.push(["⬇ Part " + p.index + " (.txt)", "&part=" + p.index]);
    });
    links.forEach(([label, qs]) => {
      const a = document.createElement("a");
      a.href = base + qs;
      a.textContent = label;
      downloadsEl.appendChild(a);
    });
  }

  function renderTranscribeJob(job) {
    downloadsEl.textContent = "";
    if (job.chunked) {
      const total = job.total_chunks || (job.chunks && job.chunks.length) || 0;
      const current = job.current_chunk || 0;
      transcriptEl.textContent =
        "Splitting into " + total + " chunk(s) (~" + Math.round((total ? 100 : 0)) + "%)\n\n" +
        renderChunkList(job.chunks);

      if (job.status === "running") {
        transcriptMetaEl.textContent = "Chunk " + current + " / " + total + " — this can take a while for long recordings.";
        return;
      }
      if (job.status === "done") {
        stopTranscribePolling();
        const partsList = (job.parts || [])
          .map((p) => "part " + p.index + ": " + p.txt + (p.segments ? " (" + p.segments + " segments)" : ""))
          .join("\n");
        transcriptEl.textContent =
          "✓ Done — " + total + " part(s), saved under storage/youtube_stream/:\n\n" + partsList +
          "\n\nmanifest: " + job.manifest;
        const metaParts = [];
        if (job.cached) metaParts.push("✓ cached — reused previous run");
        if (job.compressed) metaParts.push("compressed to " + job.filename + " for upload");
        metaParts.push(job.timecodes ? "Timecodes: on" : "Timecodes: off");
        metaParts.push(job.diarization ? "Speaker labels: yes (see manifest)" : "Speaker labels: no (see manifest)");
        transcriptMetaEl.textContent = metaParts.join(" · ");
        renderDownloads(job);
        transcribeBtn.disabled = false;
        transcribeBtn.textContent = "Recognize audio";
      } else if (job.status === "error") {
        stopTranscribePolling();
        transcriptEl.textContent += "\n\n✗ Error: " + (job.error || "unknown error");
        transcribeBtn.disabled = false;
        transcribeBtn.textContent = "Recognize audio";
      }
      return;
    }

    if (job.status === "running") {
      transcriptEl.textContent = "Recognizing… (this can take a while for long/compressed files)";
      return;
    }
    if (job.status === "done") {
      stopTranscribePolling();
      transcriptEl.textContent = job.text || "(empty transcript)";
      const metaParts = [];
      if (job.cached) metaParts.push("✓ cached — reused previous transcript");
      if (job.model) metaParts.push("Model: " + job.model);
      if (job.time) metaParts.push(job.time + "s");
      if (job.cost) metaParts.push("$" + (+job.cost).toFixed(6));
      if (job.compressed) metaParts.push("compressed to " + job.filename + " for upload");
      metaParts.push(job.timecodes ? "Timecodes: on" : "Timecodes: off");
      if (job.timecodes) metaParts.push(job.diarization ? "Speaker labels: yes" : "Speaker labels: no");
      transcriptMetaEl.textContent = metaParts.join(" · ");
      renderDownloads(job);
      transcribeBtn.disabled = false;
      transcribeBtn.textContent = "Recognize audio";
    } else if (job.status === "error") {
      stopTranscribePolling();
      transcriptEl.textContent = "✗ Error: " + (job.error || "unknown error");
      transcribeBtn.disabled = false;
      transcribeBtn.textContent = "Recognize audio";
    }
  }

  function pollTranscribeStatus(id) {
    fetch("/ai/requests/youtube/transcribe/status/" + id)
      .then((r) => r.json())
      .then((job) => {
        if (job.error && !job.status) {
          stopTranscribePolling();
          transcriptEl.textContent = "✗ Error: " + job.error;
          transcribeBtn.disabled = false;
          transcribeBtn.textContent = "Recognize audio";
          return;
        }
        renderTranscribeJob(job);
      })
      .catch(() => {
        stopTranscribePolling();
        transcriptEl.textContent = "✗ Network error while polling status.";
        transcribeBtn.disabled = false;
        transcribeBtn.textContent = "Recognize audio";
      });
  }

  transcribeBtn.addEventListener("click", () => {
    if (!currentFilename) return;

    stopTranscribePolling();
    transcriptWrap.style.display = "flex";
    transcriptEl.textContent = "";
    transcriptMetaEl.textContent = "";
    transcribeBtn.disabled = true;
    transcribeBtn.textContent = "Starting…";

    fetch("/ai/requests/youtube/transcribe/start", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        filename: currentFilename,
        model: modelSelect.value,
        timecodes: timecodesCheckbox.checked,
        language: document.getElementById("ah-yt-language").value,
      }),
    })
      .then((r) => r.json())
      .then((data) => {
        if (data.error) {
          transcriptEl.textContent = "✗ Error: " + data.error;
          transcribeBtn.disabled = false;
          transcribeBtn.textContent = "Recognize audio";
          return;
        }
        transcribeBtn.textContent = "Recognizing…";
        transcribePollTimer = setInterval(() => pollTranscribeStatus(data.id), 1500);
        pollTranscribeStatus(data.id);
      })
      .catch(() => {
        transcriptEl.textContent = "✗ Network error.";
        transcribeBtn.disabled = false;
        transcribeBtn.textContent = "Recognize audio";
      });
  });
})();
