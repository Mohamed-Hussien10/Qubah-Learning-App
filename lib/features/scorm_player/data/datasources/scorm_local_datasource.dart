import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/scorm_package.dart';
import '../../../../core/utils/debug_logger.dart';

/// ──────────────────────────────────────────────────────────────────────────────
/// Local data source that persists SCORM package metadata to SharedPreferences.
/// Stores a list of recently loaded packages for quick re-access.
/// ──────────────────────────────────────────────────────────────────────────────
class ScormLocalDataSource {
  static const String _storageKey = 'scorm_packages';

  /// Retrieve all saved packages, most recently opened first.
  Future<List<ScormPackage>> getRecentPackages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final packages = jsonList
          .map((e) => ScormPackage.fromJson(e as Map<String, dynamic>))
          .toList();

      // Sort by last opened (most recent first)
      packages.sort((a, b) => b.lastOpenedAt.compareTo(a.lastOpenedAt));

      DebugLogger.info(
        'Loaded ${packages.length} recent packages from storage.',
      );
      return packages;
    } catch (e, st) {
      DebugLogger.error('Failed to load recent packages', e, st);
      return [];
    }
  }

  /// Save or update a package in local storage.
  Future<void> savePackage(ScormPackage package) async {
    try {
      final packages = await getRecentPackages();

      // Remove existing entry with same ID (update scenario)
      packages.removeWhere((p) => p.id == package.id);

      // Add new/updated package at the front
      packages.insert(0, package);

      // Keep only last 20 packages
      final trimmed = packages.take(20).toList();

      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(trimmed.map((p) => p.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);

      DebugLogger.success('Package "${package.name}" saved to local storage.');
    } catch (e, st) {
      DebugLogger.error('Failed to save package', e, st);
    }
  }

  /// Remove a package from local storage by ID.
  Future<void> removePackage(String packageId) async {
    try {
      final packages = await getRecentPackages();
      packages.removeWhere((p) => p.id == packageId);

      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(packages.map((p) => p.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);

      DebugLogger.success('Package $packageId removed from storage.');
    } catch (e, st) {
      DebugLogger.error('Failed to remove package', e, st);
    }
  }

  /// Update the lastOpenedAt timestamp for a package.
  Future<void> updateLastOpened(String packageId) async {
    final packages = await getRecentPackages();
    final index = packages.indexWhere((p) => p.id == packageId);
    if (index != -1) {
      packages[index] = packages[index].copyWith(lastOpenedAt: DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      final jsonString = json.encode(packages.map((p) => p.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
    }
  }

  /// Clear all stored packages.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
    DebugLogger.info('All packages cleared from storage.');
  }
}
