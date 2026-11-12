import { createServer } from 'node:http';
import { appendFile, mkdtemp, readFile, rm, stat } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { extname, join, normalize, resolve } from 'node:path';
import { spawn } from 'node:child_process';

const WEB_DIR = resolve('build/web');
const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.mjs': 'application/javascript; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.wasm': 'application/wasm',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.ttf': 'font/ttf',
  '.otf': 'font/otf',
  '.woff': 'font/woff',
  '.woff2': 'font/woff2',
};

if (!existsSync(join(WEB_DIR, 'index.html'))) {
  console.error(`Missing ${join(WEB_DIR, 'index.html')}. Run web build first.`);
  process.exit(1);
}

const server = createServer(async (req, res) => {
  try {
    const reqUrl = new URL(req.url || '/', 'http://127.0.0.1');
    let relPath = decodeURIComponent(reqUrl.pathname);
    if (relPath === '/' || relPath === '') relPath = '/index.html';
    const safePath = normalize(relPath).replace(/^(\.\.[/\\])+/, '');
    let fullPath = join(WEB_DIR, safePath);

    if (!existsSync(fullPath)) {
      fullPath = join(WEB_DIR, 'index.html');
    } else {
      const info = await stat(fullPath);
      if (info.isDirectory()) {
        fullPath = join(fullPath, 'index.html');
      }
    }

    const ext = extname(fullPath).toLowerCase();
    const mime = fullPath.endsWith('manifest.json')
      ? 'application/manifest+json; charset=utf-8'
      : MIME_TYPES[ext] || 'application/octet-stream';
    const body = await readFile(fullPath);
    res.writeHead(200, {
      'Content-Type': mime,
      'Cache-Control': 'no-cache',
    });
    res.end(body);
  } catch (err) {
    res.writeHead(500);
    res.end(String(err));
  }
});

async function verifyPwaInstallability(baseUrl) {
  const checks = [];
  const manifestRes = await fetch(new URL('manifest.json', baseUrl));
  if (!manifestRes.ok) {
    throw new Error(`manifest.json returned HTTP ${manifestRes.status}`);
  }
  const manifest = await manifestRes.json();
  checks.push({
    name: 'manifest-metadata',
    pass: Boolean(
      manifest.name &&
        manifest.short_name &&
        manifest.start_url &&
        manifest.display === 'standalone' &&
        manifest.theme_color &&
        manifest.background_color,
    ),
    detail: `${manifest.short_name} (${manifest.display}, theme=${manifest.theme_color})`,
  });

  const icons = Array.isArray(manifest.icons) ? manifest.icons : [];
  const hasAny192 = icons.some((i) => i.sizes === '192x192' && i.purpose === 'any');
  const hasAny512 = icons.some((i) => i.sizes === '512x512' && i.purpose === 'any');
  const hasMask192 = icons.some((i) => i.sizes === '192x192' && i.purpose === 'maskable');
  const hasMask512 = icons.some((i) => i.sizes === '512x512' && i.purpose === 'maskable');
  let allIconsOk = hasAny192 && hasAny512 && hasMask192 && hasMask512;
  for (const icon of icons) {
    const iconRes = await fetch(new URL(icon.src, baseUrl));
    if (!iconRes.ok || !iconRes.headers.get('content-type')?.includes('image/png')) {
      allIconsOk = false;
    }
  }
  checks.push({
    name: 'maskable-and-standard-icons',
    pass: allIconsOk,
    detail: `${icons.length} PNG icons verified (any + maskable 192/512)`,
  });

  const swRes = await fetch(new URL('sw.js', baseUrl));
  const swText = swRes.ok ? await swRes.text() : '';
  checks.push({
    name: 'service-worker-script',
    pass: swRes.ok && swText.includes("addEventListener('fetch'"),
    detail: swRes.ok ? 'sw.js served cleanly' : `HTTP ${swRes.status}`,
  });

  const indexRes = await fetch(baseUrl);
  const indexText = indexRes.ok ? await indexRes.text() : '';
  checks.push({
    name: 'ios-and-splash-tags',
    pass:
      indexRes.ok &&
      indexText.includes('apple-mobile-web-app-capable') &&
      indexText.includes('apple-touch-icon.png') &&
      indexText.includes('id="jobprep-loader"'),
    detail: 'Apple PWA meta tags & lightweight branded loader present',
  });

  const bootstrapRes = await fetch(new URL('flutter_bootstrap.js', baseUrl));
  const bootstrapText = bootstrapRes.ok ? await bootstrapRes.text() : '';
  checks.push({
    name: 'wasm-with-js-fallback',
    pass:
      bootstrapRes.ok &&
      bootstrapText.includes('main.dart.js') &&
      bootstrapText.includes("register('sw.js'"),
    detail: bootstrapText.includes('main.dart.wasm')
      ? 'Wasm (skwasm) + CanvasKit/JS fallback + sw.js active'
      : 'CanvasKit/JS fallback + sw.js active',
  });

  console.log('\n=== PWA Installability & Web Runtime Checks ===');
  let allPass = true;
  for (const c of checks) {
    console.log(`  ${c.pass ? 'PASS' : 'FAIL'} [${c.name}]: ${c.detail}`);
    if (!c.pass) allPass = false;
  }
  return allPass;
}

function findChromeExecutable() {
  return (
    process.env.CHROME_PATH ||
    [
      '/usr/bin/google-chrome',
      '/usr/bin/chromium',
      '/usr/bin/chromium-browser',
      'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe',
      'C:\\Program Files (x86)\\Microsoft\\Edge\\Application\\msedge.exe',
    ].find((candidate) => existsSync(candidate))
  );
}

async function launchHeadlessChrome(userDataDir) {
  const chromePath = findChromeExecutable();
  if (!chromePath) {
    throw new Error('Could not find Chrome/Chromium executable.');
  }

  const chrome = spawn(
    chromePath,
    [
      '--headless=new',
      '--disable-gpu',
      '--remote-debugging-port=0',
      `--user-data-dir=${userDataDir}`,
      '--no-first-run',
      '--no-default-browser-check',
      '--disable-dev-shm-usage',
      '--no-sandbox',
      'about:blank',
    ],
    { stdio: ['ignore', 'pipe', 'pipe'] },
  );

  const port = await new Promise((resolvePort, rejectPort) => {
    let stderrBuf = '';
    const timer = setTimeout(() => {
      rejectPort(new Error(`Chrome failed to open DevTools port cleanly.\n${stderrBuf}`));
    }, 20000);

    chrome.stderr.on('data', (chunk) => {
      stderrBuf += chunk.toString();
      const match = stderrBuf.match(/DevTools listening on ws:\/\/127\.0\.0\.1:(\d+)\//);
      if (match) {
        clearTimeout(timer);
        resolvePort(Number(match[1]));
      }
    });

    chrome.on('exit', (code) => {
      clearTimeout(timer);
      rejectPort(new Error(`Chrome exited prematurely (${code}).\n${stderrBuf}`));
    });
  });

  return { chrome, port };
}

async function verifyMobileThrottledRuntime(cdpPort, baseUrl) {
  const targetsRes = await fetch(`http://127.0.0.1:${cdpPort}/json/list`);
  const targets = await targetsRes.json();
  const pageTarget = targets.find((t) => t.type === 'page') ?? targets[0];
  if (!pageTarget?.webSocketDebuggerUrl) {
    throw new Error('No Chrome page target found for CDP runtime verification.');
  }

  const ws = new WebSocket(pageTarget.webSocketDebuggerUrl);
  await new Promise((res, rej) => {
    ws.addEventListener('open', res, { once: true });
    ws.addEventListener('error', rej, { once: true });
  });

  let nextId = 1;
  const pending = new Map();
  const exceptions = [];

  ws.addEventListener('message', (event) => {
    const msg = JSON.parse(event.data);
    if (msg.id && pending.has(msg.id)) {
      const { res, rej } = pending.get(msg.id);
      pending.delete(msg.id);
      if (msg.error) rej(new Error(msg.error.message));
      else res(msg.result);
    } else if (msg.method === 'Runtime.exceptionThrown') {
      exceptions.push(msg.params?.exceptionDetails?.text || 'Runtime exception');
    }
  });

  const send = (method, params = {}) => {
    const id = nextId++;
    return new Promise((res, rej) => {
      pending.set(id, { res, rej });
      ws.send(JSON.stringify({ id, method, params }));
    });
  };

  try {
    await send('Page.enable');
    await send('Runtime.enable');
    await send('Network.enable');
    await send('Emulation.setDeviceMetricsOverride', {
      width: 390,
      height: 844,
      deviceScaleFactor: 2,
      mobile: true,
    });
    // Mid-range phone simulation: 4x CPU slowdown + Slow 4G/Fast 3G throttling.
    await send('Emulation.setCPUThrottlingRate', { rate: 4 });
    await send('Network.emulateNetworkConditions', {
      offline: false,
      latency: 150,
      downloadThroughput: (1.6 * 1024 * 1024) / 8,
      uploadThroughput: (750 * 1024) / 8,
    });

    await send('Page.navigate', { url: baseUrl });

    const startMs = Date.now();
    let appReady = false;
    while (Date.now() - startMs < 25000) {
      const evalRes = await send('Runtime.evaluate', {
        expression: `(() => ({
          loaderRemoved: !document.getElementById('jobprep-loader'),
          hasFlutterView: Boolean(document.querySelector('flutter-view, flt-glass-pane')),
          swControlledOrRegistered: 'serviceWorker' in navigator
        }))()`,
        returnByValue: true,
      });
      const val = evalRes?.result?.value;
      if (val?.hasFlutterView && val?.loaderRemoved) {
        appReady = true;
        break;
      }
      await new Promise((r) => setTimeout(r, 350));
    }

    // Check active service worker & test enabling reduce_effects smoothness cleanly.
    const runtimeStats = await send('Runtime.evaluate', {
      expression: `(async () => {
        localStorage.setItem('flutter.jobprep.reduce_effects', 'true');
        let swState = 'unsupported';
        if ('serviceWorker' in navigator) {
          const reg = await Promise.race([
            navigator.serviceWorker.ready,
            new Promise((r) => setTimeout(() => r(null), 5000)),
          ]);
          swState = reg?.active?.state || 'pending';
        }
        const frames = await new Promise((resolve) => {
          const deltas = [];
          let last = performance.now();
          let count = 0;
          function step(now) {
            deltas.push(now - last);
            last = now;
            if (++count >= 20) resolve(deltas);
            else requestAnimationFrame(step);
          }
          requestAnimationFrame(step);
        });
        const avgMs = frames.reduce((a, b) => a + b, 0) / frames.length;
        return {
          swState,
          avgFrameMs: Number(avgMs.toFixed(1)),
          estimatedFps: Math.round(1000 / Math.max(avgMs, 1)),
          reduceEffectsStored: localStorage.getItem('flutter.jobprep.reduce_effects') === 'true',
          wasmSupported: Boolean(window._flutter?.buildConfig?.builds?.some((b) => b.compileTarget === 'dart2wasm')),
        };
      })()`,
      awaitPromise: true,
      returnByValue: true,
    });

    const stats = runtimeStats?.result?.value || {};
    console.log('\n=== Mid-Range Phone (4x CPU + Slow 4G) Chrome Runtime Check ===');
    console.log(`  App booted & loader dismissed: ${appReady ? 'PASS' : 'FAIL'}`);
    console.log(`  Service worker state         : ${stats.swState}`);
    console.log(`  Wasm build configured        : ${stats.wasmSupported ? 'YES' : 'NO (JS fallback)'}`);
    console.log(`  reduce_effects frame pacing  : ${stats.avgFrameMs} ms (~${stats.estimatedFps} fps)`);
    console.log(`  Uncaught runtime exceptions  : ${exceptions.length}`);

    if (!appReady || exceptions.length > 0) {
      throw new Error(
        `Runtime check failed (appReady=${appReady}, exceptions=${exceptions.join('; ')})`,
      );
    }
  } finally {
    await send('Emulation.setCPUThrottlingRate', { rate: 1 }).catch(() => {});
    ws.close();
  }
}

await new Promise((resolveListen) => server.listen(0, '127.0.0.1', resolveListen));
const address = server.address();
const baseUrl = `http://127.0.0.1:${address.port}/`;
console.log(`Serving build/web at ${baseUrl}`);

const reportPath = resolve('build/lighthouse-report.json');
const chromeTempDir = await mkdtemp(join(tmpdir(), 'jobprep-chrome-'));
let chromeProcess;
let exitCode = 0;

try {
  const pwaOk = await verifyPwaInstallability(baseUrl);
  if (!pwaOk) exitCode = 1;

  const launched = await launchHeadlessChrome(chromeTempDir);
  chromeProcess = launched.chrome;

  await verifyMobileThrottledRuntime(launched.port, baseUrl);
  if (chromeProcess && !chromeProcess.killed) {
    chromeProcess.kill();
    chromeProcess = null;
  }

  const chromeFlags =
    '--headless=new --no-sandbox --disable-gpu --disable-dev-shm-usage';
  const resultStatus = await new Promise((resolveSpawn, rejectSpawn) => {
    const child =
      process.platform === 'win32'
        ? spawn(
            'cmd.exe',
            [
              '/d',
              '/s',
              '/c',
              `npx.cmd --yes lighthouse ${baseUrl} --output=json --output-path="${reportPath}" --only-categories=performance,accessibility,best-practices --max-wait-for-load=60000 --chrome-flags="${chromeFlags}" --quiet`,
            ],
            { stdio: 'inherit', shell: false, env: process.env },
          )
        : spawn(
            'npx',
            [
              '--yes',
              'lighthouse',
              baseUrl,
              '--output=json',
              `--output-path=${reportPath}`,
              '--only-categories=performance,accessibility,best-practices',
              '--max-wait-for-load=60000',
              `--chrome-flags=${chromeFlags}`,
              '--quiet',
            ],
            { stdio: 'inherit', shell: false, env: process.env },
          );
    child.on('error', rejectSpawn);
    child.on('close', (code) => resolveSpawn(code ?? 1));
  });

  if (resultStatus !== 0 && !existsSync(reportPath)) {
    console.error(`Lighthouse failed with exit code ${resultStatus}`);
    exitCode = resultStatus || 1;
  } else {
    const lhr = JSON.parse(await readFile(reportPath, 'utf8'));
    const perfScore = Math.round((lhr.categories?.performance?.score ?? 0) * 100);
    const a11yScore = Math.round((lhr.categories?.accessibility?.score ?? 0) * 100);
    const bpScore = Math.round((lhr.categories?.['best-practices']?.score ?? 0) * 100);

    console.log('\n=== Lighthouse Summary ===');
    console.log(`Performance score   : ${perfScore}/100`);
    console.log(`Accessibility score : ${a11yScore}/100`);
    console.log(`Best Practices score: ${bpScore}/100`);

    const perfMetrics = [
      'first-contentful-paint',
      'largest-contentful-paint',
      'total-blocking-time',
      'cumulative-layout-shift',
      'speed-index',
    ];
    console.log('\n=== Performance Metrics (Mobile Throttled) ===');
    for (const id of perfMetrics) {
      const audit = lhr.audits?.[id];
      if (!audit) continue;
      console.log(`  ${audit.title}: ${audit.displayValue ?? audit.numericValue}`);
    }

    if (process.env.GITHUB_STEP_SUMMARY) {
      const summaryLines = [
        '### PWA Installability & Lighthouse Report',
        '',
        `- **Installability checks**: ${pwaOk ? 'PASSED' : 'FAILED'} (manifest, maskable icons, service worker, iOS meta tags, Wasm + JS fallback)`,
        `- **Performance**: **${perfScore}/100**`,
        `- **Accessibility**: **${a11yScore}/100**`,
        `- **Best Practices**: **${bpScore}/100**`,
        `- **FCP / LCP / CLS**: ${lhr.audits?.['first-contentful-paint']?.displayValue ?? '-'} / ${lhr.audits?.['largest-contentful-paint']?.displayValue ?? '-'} / ${lhr.audits?.['cumulative-layout-shift']?.displayValue ?? '-'}`,
        '',
      ].join('\n');
      await appendFile(process.env.GITHUB_STEP_SUMMARY, `${summaryLines}\n`);
    }

    if (perfScore < 50) {
      console.error(`\nERROR: Lighthouse performance score ${perfScore} < 50 threshold.`);
      exitCode = 1;
    }
  }
} catch (err) {
  console.error(err);
  exitCode = 1;
} finally {
  if (chromeProcess && !chromeProcess.killed) {
    chromeProcess.kill();
  }
  await rm(chromeTempDir, { recursive: true, force: true }).catch(() => {});
  server.close();
}

process.exit(exitCode);
