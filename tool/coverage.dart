#!/usr/bin/env dart

import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:path/path.dart' as p;

/// Generates a coverage report for the project.
void main(List<String> args) async {
  final isCI = io.Platform.environment['CI'] == 'true';
  final parser = ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'Prints this help message.',
      negatable: false,
    )
    ..addOption(
      'report',
      abbr: 'r',
      help: 'What kind of report to generate.',
      allowed: ['lcov-only', 'html', 'html-open-browser'],
      defaultsTo: isCI ? 'lcov-only' : 'html-open-browser',
    );
  final results = parser.parse(args);

  if (results['help'] as bool) {
    io.stderr.writeln(parser.usage);
    return;
  }

  await _generateImportAll();
  await _testWithCoverage();

  // If we're reporting html or html-open-browser, generate the HTML report.
  if (results['report'] != 'lcov-only') {
    await _generateHtmlReport();

    // Open the browser if requested.
    if (results['report'] == 'html-open-browser') {
      final process = await io.Process.start(
        'open',
        ['coverage/html/index.html'],
      );

      process.stdout.listen(io.stdout.add);
      process.stderr.listen(io.stderr.add);

      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        throw Exception('Failed to open browser: $exitCode');
      }
    }
  }
}

/// Generates a file that imports all the files in the project.
///
/// By default, tools such as codecov only see the files that are imported
/// directly or transitively by the main file; in other words, 100% coverage
/// can be achieved by writing a dummy test that imports nothing.
///
/// This function generates a file that imports all the files in the project,
/// and places it in the `coverage` directory, which in turn can be included by
/// the test runner to generate a more accurate coverage report.
Future<io.File> _generateImportAll() async {
  // Find all Dart files in the `lib` directory.
  final files = await io.Directory('lib')
      .list(recursive: true)
      .where((entity) => entity is io.File && entity.path.endsWith('.dart'))
      .map((entity) => entity.path)
      .toList();

  // Sort alphabetically for consistency.
  files.sort();

  // Create a file that imports all the files.
  final output = StringBuffer();
  output.writeln('// Auto-generated file. Do not edit.');
  output.writeln('// To regenerate, run `dart tool/coverage.dart`.');
  output.writeln();
  output.writeln('// ignore_for_file: unused_import\n\n');

  for (final file in files) {
    final relative = p.relative(file, from: 'lib');
    output.writeln("import 'package:dt/$relative';");
  }

  // Create a dummy main function.
  output.writeln();
  output.writeln('void main() {}');

  // Create the coverage directory if it doesn't exist.
  final coverage = io.Directory('coverage');
  await coverage.create();

  // Write the file to the `coverage` directory.
  final file = io.File(p.join(coverage.path, 'all_test.dart'));
  await file.writeAsString(output.toString());
  return file;
}

/// Runs `dart run coverage:test_with_coverage -- -P coverage`.
Future<void> _testWithCoverage() async {
  final process = await io.Process.start(
    'dart',
    [
      'run',
      'coverage:test_with_coverage',
      '--',
      '-P',
      'coverage',
    ],
  );

  process.stdout.listen(io.stdout.add);
  process.stderr.listen(io.stderr.add);

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw Exception('Failed to run test_with_coverage: $exitCode');
  }
}

/// Runs `genhtml coverage/lcov.info -o coverage/html`.
Future<void> _generateHtmlReport() async {
  final process = await io.Process.start(
    'genhtml',
    [
      'coverage/lcov.info',
      '-o',
      'coverage/html',
    ],
  );

  process.stdout.listen(io.stdout.add);
  process.stderr.listen(io.stderr.add);

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw Exception('Failed to generate HTML report: $exitCode');
  }
}
