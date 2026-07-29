import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui';

import 'gazepoint_sdk_method_channel.dart';
import 'models/gaze_result.dart';
import 'models/performance_metrics.dart';

/// The interface that implementations of gazepoint_sdk must implement.
abstract class GazepointSdkPlatform extends PlatformInterface {
  /// Constructs a GazepointSdkPlatform.
  GazepointSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static GazepointSdkPlatform _instance = MethodChannelGazepointSdk();

  /// The default instance of [GazepointSdkPlatform] to use.
  static GazepointSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [GazepointSdkPlatform] when
  /// they register themselves.
  static set instance(GazepointSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initialize the gaze tracker
  Future<void> initialize() {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Start gaze tracking
  Future<void> startTracking() {
    throw UnimplementedError('startTracking() has not been implemented.');
  }

  /// Stop gaze tracking
  Future<void> stopTracking() {
    throw UnimplementedError('stopTracking() has not been implemented.');
  }

  /// Get the latest gaze result
  Future<GazeResult?> getLatestGaze() {
    throw UnimplementedError('getLatestGaze() has not been implemented.');
  }

  /// Calibrate with known screen points
  Future<void> calibrate(List<Offset> calibrationPoints) {
    throw UnimplementedError('calibrate() has not been implemented.');
  }

  /// Reset calibration
  Future<void> resetCalibration() {
    throw UnimplementedError('resetCalibration() has not been implemented.');
  }

  /// Get performance metrics
  Future<PerformanceMetrics> getPerformanceMetrics() {
    throw UnimplementedError('getPerformanceMetrics() has not been implemented.');
  }

  /// Stream of gaze results
  Stream<GazeResult> get gazeStream {
    throw UnimplementedError('gazeStream has not been implemented.');
  }

  /// Check if gaze tracking is supported on this device
  Future<bool> isSupported() {
    throw UnimplementedError('isSupported() has not been implemented.');
  }

  /// Check if camera permission is granted
  Future<bool> hasCameraPermission() {
    throw UnimplementedError('hasCameraPermission() has not been implemented.');
  }

  /// Request camera permission
  Future<bool> requestCameraPermission() {
    throw UnimplementedError('requestCameraPermission() has not been implemented.');
  }
}
