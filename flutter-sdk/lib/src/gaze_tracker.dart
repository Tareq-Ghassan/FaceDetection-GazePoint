import 'dart:async';
import 'dart:ui';

import 'gazepoint_sdk_platform_interface.dart';
import 'models/gaze_result.dart';
import 'models/performance_metrics.dart';

/// Main GazeTracker class for Flutter applications
/// 
/// Example usage:
/// ```dart
/// final gazeTracker = GazeTracker();
/// 
/// // Initialize
/// await gazeTracker.initialize();
/// 
/// // Check support and permissions
/// if (await gazeTracker.isSupported() && await gazeTracker.requestCameraPermission()) {
///   // Start tracking
///   await gazeTracker.startTracking();
///   
///   // Listen to gaze stream
///   gazeTracker.gazeStream.listen((result) {
///     print('Gaze at: ${result.gazePoint}');
///   });
/// }
/// ```
class GazeTracker {
  final GazepointSdkPlatform _platform = GazepointSdkPlatform.instance;
  
  bool _isInitialized = false;
  bool _isTracking = false;

  /// Whether the tracker is initialized
  bool get isInitialized => _isInitialized;

  /// Whether tracking is currently active
  bool get isTracking => _isTracking;

  /// Initialize the gaze tracker
  /// 
  /// Must be called before starting tracking.
  Future<void> initialize() async {
    if (_isInitialized) {
      throw StateError('GazeTracker is already initialized');
    }
    
    await _platform.initialize();
    _isInitialized = true;
  }

  /// Start gaze tracking
  /// 
  /// Requires [initialize] to be called first.
  /// Requires camera permission to be granted.
  Future<void> startTracking() async {
    if (!_isInitialized) {
      throw StateError('GazeTracker not initialized. Call initialize() first.');
    }
    
    if (_isTracking) {
      throw StateError('Tracking is already active');
    }
    
    // Check camera permission
    if (!await hasCameraPermission()) {
      throw StateError('Camera permission not granted');
    }
    
    await _platform.startTracking();
    _isTracking = true;
  }

  /// Stop gaze tracking
  Future<void> stopTracking() async {
    if (!_isTracking) {
      return;
    }
    
    await _platform.stopTracking();
    _isTracking = false;
  }

  /// Get the latest gaze result
  /// 
  /// Returns null if no gaze data is available.
  Future<GazeResult?> getLatestGaze() async {
    if (!_isInitialized) {
      throw StateError('GazeTracker not initialized');
    }
    
    return await _platform.getLatestGaze();
  }

  /// Calibrate the gaze tracker with known screen points
  /// 
  /// [calibrationPoints] should contain at least 3 points that the user
  /// is known to be looking at. More points (5-9) provide better calibration.
  /// 
  /// Example:
  /// ```dart
  /// final points = [
  ///   Offset(100, 100),  // Top-left
  ///   Offset(375, 100),  // Top-right
  ///   Offset(100, 750),  // Bottom-left
  ///   Offset(375, 750),  // Bottom-right
  ///   Offset(187.5, 425),// Center
  /// ];
  /// await gazeTracker.calibrate(points);
  /// ```
  Future<void> calibrate(List<Offset> calibrationPoints) async {
    if (!_isInitialized) {
      throw StateError('GazeTracker not initialized');
    }
    
    if (calibrationPoints.length < 3) {
      throw ArgumentError('At least 3 calibration points are required');
    }
    
    await _platform.calibrate(calibrationPoints);
  }

  /// Reset calibration to default
  Future<void> resetCalibration() async {
    if (!_isInitialized) {
      throw StateError('GazeTracker not initialized');
    }
    
    await _platform.resetCalibration();
  }

  /// Get current performance metrics
  Future<PerformanceMetrics> getPerformanceMetrics() async {
    if (!_isInitialized) {
      throw StateError('GazeTracker not initialized');
    }
    
    return await _platform.getPerformanceMetrics();
  }

  /// Stream of gaze results
  /// 
  /// Provides real-time updates of gaze point detection.
  /// Stream is active only when tracking is started.
  Stream<GazeResult> get gazeStream => _platform.gazeStream;

  /// Check if gaze tracking is supported on this device
  /// 
  /// Returns true if the device has a front-facing camera and
  /// meets the minimum requirements for gaze tracking.
  Future<bool> isSupported() async {
    return await _platform.isSupported();
  }

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() async {
    return await _platform.hasCameraPermission();
  }

  /// Request camera permission from the user
  /// 
  /// Returns true if permission was granted, false otherwise.
  Future<bool> requestCameraPermission() async {
    return await _platform.requestCameraPermission();
  }

  /// Dispose resources
  Future<void> dispose() async {
    if (_isTracking) {
      await stopTracking();
    }
    _isInitialized = false;
    _isTracking = false;
  }
}
