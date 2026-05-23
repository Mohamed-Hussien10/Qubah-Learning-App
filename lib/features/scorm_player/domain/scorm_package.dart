/// ──────────────────────────────────────────────────────────────────────────────
/// Domain entity representing a SCORM learning package.
/// ──────────────────────────────────────────────────────────────────────────────
class ScormPackage {
  /// Unique identifier for this package instance.
  final String id;

  /// Display name (derived from ZIP filename or imsmanifest title).
  final String name;

  /// Original ZIP file path on disk.
  final String zipFilePath;

  /// Directory where the ZIP was extracted.
  final String extractedPath;

  /// The main HTML entry file path (absolute).
  final String entryFilePath;

  /// Timestamp of when the package was first loaded.
  final DateTime loadedAt;

  /// Timestamp of last time the package was opened.
  final DateTime lastOpenedAt;

  /// Optional metadata from imsmanifest.xml.
  final ScormManifestMetadata? manifest;

  /// Progress tracking placeholder (0.0 – 1.0).
  final double progress;

  const ScormPackage({
    required this.id,
    required this.name,
    required this.zipFilePath,
    required this.extractedPath,
    required this.entryFilePath,
    required this.loadedAt,
    required this.lastOpenedAt,
    this.manifest,
    this.progress = 0.0,
  });

  /// Creates a copy with optional field overrides.
  ScormPackage copyWith({
    String? name,
    String? entryFilePath,
    DateTime? lastOpenedAt,
    ScormManifestMetadata? manifest,
    double? progress,
  }) {
    return ScormPackage(
      id: id,
      name: name ?? this.name,
      zipFilePath: zipFilePath,
      extractedPath: extractedPath,
      entryFilePath: entryFilePath ?? this.entryFilePath,
      loadedAt: loadedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      manifest: manifest ?? this.manifest,
      progress: progress ?? this.progress,
    );
  }

  /// Serialize to JSON map for local storage.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'zipFilePath': zipFilePath,
    'extractedPath': extractedPath,
    'entryFilePath': entryFilePath,
    'loadedAt': loadedAt.toIso8601String(),
    'lastOpenedAt': lastOpenedAt.toIso8601String(),
    'progress': progress,
    if (manifest != null) 'manifest': manifest!.toJson(),
  };

  /// Deserialize from JSON map.
  factory ScormPackage.fromJson(Map<String, dynamic> json) {
    return ScormPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      zipFilePath: json['zipFilePath'] as String,
      extractedPath: json['extractedPath'] as String,
      entryFilePath: json['entryFilePath'] as String,
      loadedAt: DateTime.parse(json['loadedAt'] as String),
      lastOpenedAt: DateTime.parse(json['lastOpenedAt'] as String),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      manifest: json['manifest'] != null
          ? ScormManifestMetadata.fromJson(
              json['manifest'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

/// ──────────────────────────────────────────────────────────────────────────────
/// Metadata parsed from imsmanifest.xml.
/// ──────────────────────────────────────────────────────────────────────────────
class ScormManifestMetadata {
  final String? title;
  final String? description;
  final String? scormVersion;
  final String? launchUrl;

  const ScormManifestMetadata({
    this.title,
    this.description,
    this.scormVersion,
    this.launchUrl,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'scormVersion': scormVersion,
    'launchUrl': launchUrl,
  };

  factory ScormManifestMetadata.fromJson(Map<String, dynamic> json) {
    return ScormManifestMetadata(
      title: json['title'] as String?,
      description: json['description'] as String?,
      scormVersion: json['scormVersion'] as String?,
      launchUrl: json['launchUrl'] as String?,
    );
  }
}
