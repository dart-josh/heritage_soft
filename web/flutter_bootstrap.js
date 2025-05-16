{{flutter_js}}
{{flutter_build_config}}

const userConfig =  {"canvasKitBaseUrl": "/canvaskit/","renderer": "canvaskit","entryPointBaseUrl":"/"};

_flutter.loader.load({
  config: userConfig,
  entrypointUrl: "/main.dart.js",
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}},
    serviceWorkerUrl: "/flutter_service_worker.js?v=",
  },
  onEntrypointLoaded: async function(engineInitializer) {
    const amaRunner = await engineInitializer.initializeEngine();
    await amaRunner.runApp();
    // hideLoader();     
  }
});

// flutter build web --no-web-resources-cdn