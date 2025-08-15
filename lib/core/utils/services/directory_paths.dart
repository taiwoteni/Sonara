import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DirectoryPaths {
  static final DirectoryPaths _instance = DirectoryPaths._internal();
  Directory? _applicationSupportDirectory;
  Directory? _temporaryDirectory;
  Directory? _applicationDocumentsDirectory;
  bool _isInitialized = false;

  factory DirectoryPaths() {
    return _instance;
  }

  DirectoryPaths._internal();

  /// Initializes all directory paths. Call this during app startup.
  Future<void> initialize() async {
    if (!_isInitialized) {
      _applicationSupportDirectory = await getApplicationSupportDirectory();
      _temporaryDirectory = await getTemporaryDirectory();
      _applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
      _isInitialized = true;
      print(
        'DirectoryPaths initialized with support dir: ${_applicationSupportDirectory?.path}',
      );
    }
  }

  /// Ensures the singleton is initialized, useful for lazy initialization.
  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Getter for application support directory.
  Directory get applicationSupportDirectory {
    if (!_isInitialized || _applicationSupportDirectory == null) {
      throw Exception(
        'DirectoryPaths not initialized. Call initialize() first.',
      );
    }
    return _applicationSupportDirectory!;
  }

  /// Getter for temporary directory.
  Directory get temporaryDirectory {
    if (!_isInitialized || _temporaryDirectory == null) {
      throw Exception(
        'DirectoryPaths not initialized. Call initialize() first.',
      );
    }
    return _temporaryDirectory!;
  }

  /// Getter for application documents directory.
  Directory get applicationDocumentsDirectory {
    if (!_isInitialized || _applicationDocumentsDirectory == null) {
      throw Exception(
        'DirectoryPaths not initialized. Call initialize() first.',
      );
    }
    return _applicationDocumentsDirectory!;
  }

  /// Refreshes all directory paths if needed.
  Future<void> refresh() async {
    _applicationSupportDirectory = await getApplicationSupportDirectory();
    _temporaryDirectory = await getTemporaryDirectory();
    _applicationDocumentsDirectory = await getApplicationDocumentsDirectory();
    _isInitialized = true;
    print(
      'DirectoryPaths refreshed with support dir: ${_applicationSupportDirectory?.path}',
    );
  }
}
