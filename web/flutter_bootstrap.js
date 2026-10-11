{{flutter_js}}
{{flutter_build_config}}

// Version the app bundle so browsers see each deployment immediately.
const focFastBuildVersion = {{flutter_service_worker_version}};
for (const build of _flutter.buildConfig.builds) {
  if (build.mainJsPath) {
    build.mainJsPath = `${build.mainJsPath}?v=${focFastBuildVersion}`;
  }
}

async function startFocFast() {
  if ('serviceWorker' in navigator) {
    try {
      const appScope = new URL('.', document.baseURI).href;
      const registrations = await navigator.serviceWorker.getRegistrations();
      const oldWorkers = registrations.filter(
        (item) =>
          item.scope === appScope &&
          new URL(item.active?.scriptURL || appScope).pathname.endsWith('/flutter_service_worker.js'),
      );
      if (oldWorkers.length > 0) {
        await Promise.all(oldWorkers.map((item) => item.unregister()));
        if (navigator.serviceWorker.controller) {
          window.location.reload();
          return;
        }
      }

      // Network-first fetching keeps new pushes fresh.
      await navigator.serviceWorker.register('foc_fast_sw.js', { scope: './' });
    } catch (error) {
      console.warn('Could not enable app installation:', error);
    }
  }
  await _flutter.loader.load();
}

startFocFast();
