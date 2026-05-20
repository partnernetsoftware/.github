import { invoke } from "@tauri-apps/api/core";

window.addEventListener("DOMContentLoaded", () => {
  const statusEl = document.querySelector<HTMLPreElement>("#status");
  const toggleButton = document.querySelector<HTMLButtonElement>("#toggle-window");
  const toggleResult = document.querySelector<HTMLParagraphElement>("#toggle-result");

  invoke("worker_status")
    .then((status) => {
      if (statusEl) {
        statusEl.textContent = JSON.stringify(status, null, 2);
      }
    })
    .catch((error) => {
      if (statusEl) {
        statusEl.textContent = `Unable to read Tauri status: ${error}`;
      }
    });

  toggleButton?.addEventListener("click", async () => {
    toggleButton.disabled = true;
    toggleButton.textContent = "Restoring...";

    try {
      const message = await invoke<string>("hide_then_restore");
      if (toggleResult) {
        toggleResult.textContent = message;
      }
    } catch (error) {
      if (toggleResult) {
        toggleResult.textContent = `Toggle failed: ${error}`;
      }
    } finally {
      setTimeout(() => {
        toggleButton.disabled = false;
        toggleButton.textContent = "Hide for one second";
      }, 1200);
    }
  });
});
