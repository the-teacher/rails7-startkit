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
  if (!form) return;

  let pollTimer = null;

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
  }

  function renderJob(job) {
    const pct = job.percent || 0;
    progressBar.style.width = pct + "%";
    percentEl.textContent = pct.toFixed(1) + "%";
    sizeEl.textContent = job.total ? "of " + job.total : "";
    speedEl.textContent = job.speed ? job.speed : "";
    etaEl.textContent = job.eta ? "ETA " + job.eta : "";
    if (job.filename) filenameEl.textContent = job.filename;

    if (job.status === "starting" || job.status === "downloading") {
      output.textContent = job.status === "starting" ? "Starting download…" : "Downloading…";
    } else if (job.status === "done") {
      stopPolling();
      progressBar.style.width = "100%";
      percentEl.textContent = "100%";
      const sizeStr = job.size ? " (" + (job.size / 1024 / 1024).toFixed(2) + " MB)" : "";
      output.textContent = job.cached
        ? "✓ Already downloaded — reusing cached file: " + job.filename + sizeStr
        : "✓ Done — " + job.filename + sizeStr;
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
      body: JSON.stringify({ url: url }),
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
})();
