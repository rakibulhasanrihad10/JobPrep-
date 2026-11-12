import 'dart:io';

/// Builds the Flutter Web release bundle using WebAssembly (`--wasm`) when the
/// active Flutter SDK supports it, falling back cleanly to the standard JS/CanvasKit
/// release build otherwise.
Future<void> main(List<String> args) async {
  final helpResult = await Process.run(
    'flutter',
    ['build', 'web', '--help'],
    runInShell: Platform.isWindows,
  );
  final helpText = '${helpResult.stdout}\n${helpResult.stderr}';
  final supportsWasm = helpText.contains('--wasm');

  final buildArgs = <String>[
    'build',
    'web',
    if (supportsWasm) '--wasm',
    '--release',
    ...args,
  ];

  stdout.writeln(
    supportsWasm
        ? 'Flutter SDK supports --wasm; building WebAssembly + CanvasKit '
            'fallback bundle...'
        : 'Flutter SDK does not advertise --wasm; falling back to standard '
            'release web build...',
  );

  final process = await Process.start(
    'flutter',
    buildArgs,
    runInShell: Platform.isWindows,
    mode: ProcessStartMode.inheritStdio,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    stderr.writeln(
      'flutter ${buildArgs.join(' ')} failed with exit code $exitCode.',
    );
    exit(exitCode);
  }
}
