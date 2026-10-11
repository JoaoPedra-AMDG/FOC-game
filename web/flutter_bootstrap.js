{{flutter_js}}
{{flutter_build_config}}

// A fresh URL for the compiled app bypasses the old Flutter worker's
// cache-first response and the browser's normal asset cache on every build.
const torqueBuildVersion = {{flutter_service_worker_version}};
for (const build of _flutter.buildConfig.builds) {
  if (build.mainJsPath) {
    build.mainJsPath = `${build.mainJsPath}?v=${torqueBuildVersion}`;
  }
}

async function startTorqueChase() {
  // Earlier releases installed Flutter's offline-first worker. Remove only
  // this app's worker before loading so subsequent visits get fresh assets.
  if ('serviceWorker' in navigator) {
    try {
      const appScope = new URL('.', document.baseURI).href;
      const registrations = await navigator.serviceWorker.getRegistrations();
      const oldWorkers = registrations.filter((item) => item.scope === appScope);
      if (oldWorkers.length > 0) {
        await Promise.all(oldWorkers.map((item) => item.unregister()));
        if (navigator.serviceWorker.controller) {
          window.location.reload();
          return;
        }
      }
    } catch (error) {
      console.warn('Could not remove the previous app cache worker:', error);
    }
  }
  await _flutter.loader.load();
}

startTorqueChase();
