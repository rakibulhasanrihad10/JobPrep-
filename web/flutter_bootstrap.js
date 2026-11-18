{{flutter_js}}
{{flutter_build_config}}

(function () {
  const loader = document.getElementById('jobprep-loader');

  function dismissLoader() {
    if (!loader || loader.dataset.dismissed === '1') return;
    loader.dataset.dismissed = '1';
    loader.classList.add('is-ready');
    window.setTimeout(() => {
      if (loader.parentNode) {
        loader.parentNode.removeChild(loader);
      }
    }, 260);
  }

  window.addEventListener('flutter-first-frame', dismissLoader, { once: true });

  // Register custom PWA service worker cleanly (avoids Flutter's deprecated SW config).
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      navigator.serviceWorker.register('sw.js', { scope: './' }).catch(() => {
        // Non-fatal in private browsing or restricted WebViews.
      });
    });
  }

  _flutter.loader.load({
    onEntrypointLoaded: async function (engineInitializer) {
      const appRunner = await engineInitializer.initializeEngine();
      await appRunner.runApp();
      window.requestAnimationFrame(() => window.setTimeout(dismissLoader, 60));
    },
  });
})();
