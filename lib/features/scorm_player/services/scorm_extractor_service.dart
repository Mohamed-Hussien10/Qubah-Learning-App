import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../../../core/utils/debug_logger.dart';
import '../domain/scorm_package.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Service responsible for:
///   1. Extracting SCORM ZIP packages to the app documents directory
///   2. Parsing imsmanifest.xml for metadata
///   3. Auto-detecting the main HTML entry file
///
/// Extraction creates a unique subfolder per package to avoid collisions.
/// ──────────────────────────────────────────────────────────────────────────────
class ScormExtractorService {
  static const _uuid = Uuid();

  /// Extract a ZIP file and return a [ScormPackage] entity.
  ///
  /// [zipFilePath] – absolute path to the .zip file on disk.
  /// [onProgress]  – callback with progress value (0.0 – 1.0) during extraction.
  ///
  ///
  /// Throws [FormatException] if the ZIP is invalid.
  /// Throws [FileSystemException] if extraction fails.
  static Future<ScormPackage?> getCachedPackage(String packageId, String zipFilePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final extractDir = Directory('${appDir.path}/scorm_packages/$packageId');
    
    if (await extractDir.exists()) {
      DebugLogger.fileSystem('Found cached package: $packageId');
      final manifest = await _parseManifest(extractDir.path);
      final entryFile = await _detectEntryFile(extractDir.path, manifest);
      
      if (entryFile != null) {
        final now = DateTime.now();
        final packageName = manifest?.title ?? zipFilePath.split(Platform.pathSeparator).last.replaceAll('.zip', '');
        return ScormPackage(
          id: packageId,
          name: packageName,
          zipFilePath: zipFilePath,
          extractedPath: extractDir.path,
          entryFilePath: entryFile,
          loadedAt: now,
          lastOpenedAt: now,
          manifest: manifest,
        );
      }
    }
    return null;
  }

  static Future<ScormPackage> extractAndPrepare(
    String zipFilePath, {
    void Function(double progress)? onProgress,
    String? packageId,
  }) async {
    final effectivePackageId = packageId ?? _uuid.v4();
    DebugLogger.fileSystem('Starting extraction for: $zipFilePath');
    DebugLogger.fileSystem('Package ID: $effectivePackageId');

    // ── 1. Read ZIP file ────────────────────────────────────────────────────
    final zipFile = File(zipFilePath);
    if (!await zipFile.exists()) {
      throw FileSystemException('ZIP file not found', zipFilePath);
    }

    final bytes = await zipFile.readAsBytes();
    DebugLogger.fileSystem(
      'ZIP size: ${(bytes.length / 1024 / 1024).toStringAsFixed(2)} MB',
    );

    // ── 2. Decode archive ───────────────────────────────────────────────────
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (e) {
      throw FormatException('Invalid ZIP archive: $e');
    }

    DebugLogger.fileSystem('Archive contains ${archive.length} entries.');

    // ── 3. Determine output directory ───────────────────────────────────────
    final appDir = await getApplicationDocumentsDirectory();
    final extractDir = Directory('${appDir.path}/scorm_packages/$effectivePackageId');
    await extractDir.create(recursive: true);
    DebugLogger.fileSystem('Extraction target: ${extractDir.path}');

    // ── 4. Extract files ────────────────────────────────────────────────────
    int extractedCount = 0;
    for (final entry in archive) {
      final filePath = '${extractDir.path}/${entry.name}';

      if (entry.isFile) {
        final file = File(filePath);
        await file.create(recursive: true);
        await file.writeAsBytes(entry.content as List<int>);
      } else {
        await Directory(filePath).create(recursive: true);
      }

      extractedCount++;
      onProgress?.call(extractedCount / archive.length);
    }

    DebugLogger.success(
      'Extracted $extractedCount entries to ${extractDir.path}',
    );

    // ── 5. Parse manifest (if available) ────────────────────────────────────
    final manifest = await _parseManifest(extractDir.path);

    // ── 6. Detect main HTML entry file ──────────────────────────────────────
    final entryFile = await _detectEntryFile(extractDir.path, manifest);
    if (entryFile == null) {
      throw FileSystemException(
        'No HTML entry file found in the extracted package.',
        extractDir.path,
      );
    }

    DebugLogger.success('Entry file detected: $entryFile');

    // ── 7. Build package entity ─────────────────────────────────────────────
    final now = DateTime.now();
    final packageName =
        manifest?.title ??
        zipFilePath.split(Platform.pathSeparator).last.replaceAll('.zip', '');

    return ScormPackage(
      id: effectivePackageId,
      name: packageName,
      zipFilePath: zipFilePath,
      extractedPath: extractDir.path,
      entryFilePath: entryFile,
      loadedAt: now,
      lastOpenedAt: now,
      manifest: manifest,
    );
  }

  /// Parse imsmanifest.xml for SCORM metadata.
  static Future<ScormManifestMetadata?> _parseManifest(
    String extractedPath,
  ) async {
    final manifestFile = File('$extractedPath/imsmanifest.xml');
    if (!await manifestFile.exists()) {
      DebugLogger.warning(
        'imsmanifest.xml not found – skipping manifest parsing.',
      );
      return null;
    }

    try {
      final xmlString = await manifestFile.readAsString();
      final document = XmlDocument.parse(xmlString);

      // Extract title from <title> element
      String? title;
      final titleElements = document.findAllElements('title');
      if (titleElements.isNotEmpty) {
        final langstring = titleElements.first.findElements('langstring');
        if (langstring.isNotEmpty) {
          title = langstring.first.innerText.trim();
        }
        if (title == null || title.isEmpty) {
          title = titleElements.first.innerText.trim();
        }
      }

      // Extract description
      String? description;
      final descElements = document.findAllElements('description');
      if (descElements.isNotEmpty) {
        final langstring = descElements.first.findElements('langstring');
        if (langstring.isNotEmpty) {
          description = langstring.first.innerText.trim();
        }
      }

      // Extract SCORM version from metadata
      String? scormVersion;
      final schemaVersionElements = document.findAllElements('schemaversion');
      if (schemaVersionElements.isNotEmpty) {
        scormVersion = schemaVersionElements.first.innerText.trim();
      }

      // Extract launch URL from <resource> element
      String? launchUrl;
      final resourceElements = document.findAllElements('resource');
      for (final resource in resourceElements) {
        final href = resource.getAttribute('href');
        if (href != null && href.endsWith('.html')) {
          launchUrl = href;
          break;
        }
        // Also check for .htm
        if (href != null && href.endsWith('.htm')) {
          launchUrl = href;
          break;
        }
      }

      DebugLogger.info(
        'Manifest parsed – Title: $title, Version: $scormVersion, LaunchURL: $launchUrl',
      );

      return ScormManifestMetadata(
        title: title,
        description: description,
        scormVersion: scormVersion,
        launchUrl: launchUrl,
      );
    } catch (e, st) {
      DebugLogger.error('Failed to parse imsmanifest.xml', e, st);
      return null;
    }
  }

  /// Detect the main HTML entry file using priority order:
  ///   1. launchUrl from imsmanifest.xml
  ///   2. res/index.html
  ///   3. index.html (root)
  ///   4. First .html file found recursively
  static Future<String?> _detectEntryFile(
    String extractedPath,
    ScormManifestMetadata? manifest,
  ) async {
    DebugLogger.info('Detecting HTML entry file…');

    // Priority 1: manifest launchUrl
    if (manifest?.launchUrl != null) {
      final manifestEntry = File('$extractedPath/${manifest!.launchUrl}');
      if (await manifestEntry.exists()) {
        DebugLogger.info('Entry from manifest: ${manifestEntry.path}');
        return manifestEntry.path;
      }
    }

    // Priority 2: res/index.html
    final resIndex = File('$extractedPath/res/index.html');
    if (await resIndex.exists()) {
      DebugLogger.info('Entry found: res/index.html');
      return resIndex.path;
    }

    // Priority 3: index.html at root
    final rootIndex = File('$extractedPath/index.html');
    if (await rootIndex.exists()) {
      DebugLogger.info('Entry found: index.html');
      return rootIndex.path;
    }

    // Priority 4: First .html file found (recursive search)
    final dir = Directory(extractedPath);
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File &&
          (entity.path.endsWith('.html') || entity.path.endsWith('.htm'))) {
        DebugLogger.info('Entry found (fallback): ${entity.path}');
        return entity.path;
      }
    }

    DebugLogger.error('No HTML entry file detected.');
    return null;
  }

  /// Delete an extracted package from disk.
  static Future<void> deleteExtractedPackage(String extractedPath) async {
    try {
      final dir = Directory(extractedPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        DebugLogger.success('Deleted extracted package: $extractedPath');
      }
    } catch (e, st) {
      DebugLogger.error('Failed to delete package', e, st);
    }
  }
}
