(function () {
  var localHosts = new Set(["127.0.0.1", "localhost"]);

  if (!localHosts.has(window.location.hostname)) {
    return;
  }

  var lastUpdatedAt = null;

  function checkForReload() {
    fetch("/.dev-reload.json?ts=" + Date.now(), { cache: "no-store" })
      .then(function (response) {
        if (!response.ok) {
          return null;
        }

        return response.json();
      })
      .then(function (payload) {
        if (!payload || !payload.updatedAt) {
          return;
        }

        if (lastUpdatedAt && payload.updatedAt !== lastUpdatedAt) {
          window.location.reload();
          return;
        }

        lastUpdatedAt = payload.updatedAt;
      })
      .catch(function () {
        // Ignore polling errors during local development.
      });
  }

  setInterval(checkForReload, 1000);
  checkForReload();
})();
