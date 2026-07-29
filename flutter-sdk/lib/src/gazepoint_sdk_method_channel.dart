import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

import 'gazepoint_sdk_platform_interface.dart';
import 'models/gaze_result.dart';
import 'models/performance_metrics.dart';

/// An implementation of [GazepointSdkPlatform] that uses method channels.
class MethodChannelGazepointSdk extends GazepointSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('gazepoint_sdk');

  /// The event channel for gaze stream
  @visibleForTesting
  final eventChannel = const EventChannel('gazepoint_sdk/gaze_stream');

  Stream<GazeResult>? _gazeStream;

  @override
  Future<void> initialize() async {
    try {
      await methodChannel.invokeMethod<void>('initialize');
    } on PlatformException catch (e) {
      throw Exception('Failed to initialize: ${e.message}');
    }
  }

  @override
  Future<void> startTracking() async {
    try {
      await methodChannel.invokeMethod<void>('startTracking');
    } on PlatformException catch (e) {
      throw Exception('Failed to start tracking: ${e.message}');
    }
  }

  @override
  Future<void> stopTracking() async {
    try {
      await methodChannel.invokeMethod<void>('stopTracking');
    } on PlatformException catch (e) {
      throw Exception('Failed to stop tracking: ${e.message}');
    }
  }

  @override
  Future<GazeResult?> getLatestGaze() async {
    try {
      final result = await methodChannel.invokeMethod<Map>('getLatestGaze');
      if (result == null) return null;
      return GazeResult.fromJson(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      debugPrint('Failed to get latest gaze: ${e.message}');
      return null;
    }
  }

  @override
  Future<void> calibrate(List<Offset> calibrationPoints) async {
    try {
      final points = calibrationPoints.map((p) => {
        'x': p.dx,
        'y': p.dy,
      }).toList();
      
      await methodChannel.invokeMethod<void>('calibrate', {
        'calibrationPoints': points,
      });
    } on PlatformException catch (e) {
      throw Exception('Failed to calibrate: ${e.message}');
    }
  }

  @override
  Future<void> resetCalibration() async {
    try {
      await methodChannel.invokeMethod<void>('resetCalibration');
    } on PlatformException catch (e) {
      throw Exception('Failed to reset calibration: ${e.message}');
    }
  }

  @override
  Future<PerformanceMetrics> getPerformanceMetrics() async {
    try {
      final result = await methodChannel.invokeMethod<Map>('getPerformanceMetrics');
      if (result == null) {
        throw Exception('No performance metrics available');
      }
      return PerformanceMetrics.fromJson(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw Exception('Failed to get performance metrics: ${e.message}');
    }
  }

  @override
  Stream<GazeResult> get gazeStream {
    _gazeStream ??= eventChannel.receiveBroadcastStream().map((event) {
      return GazeResult.fromJson(Map<String, dynamic>.from(event as Map));
    });
    return _gazeStream!;
  }

  @override
  Future<bool> isSupported() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('isSupported');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to check support: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> hasCameraPermission() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('hasCameraPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to check camera permission: ${e.message}');
      return false;
    }
  }

  @override
  Future<bool> requestCameraPermission() async {
    try {
      final result = await methodChannel.invokeMethod<bool>('requestCameraPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to request camera permission: ${e.message}');
      return false;
    }
  }
}
