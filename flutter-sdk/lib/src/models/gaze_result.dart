import 'dart:ui';
import 'head_pose.dart';

/// Result of gaze point calculation
class GazeResult {
  /// The calculated gaze point in screen coordinates
  final Offset gazePoint;
  
  /// Confidence score from 0.0 to 1.0
  final double confidence;
  
  /// Whether the user is blinking
  final bool isBlinking;
  
  /// Head pose information
  final HeadPose headPose;
  
  /// Timestamp of the result (milliseconds since epoch)
  final int timestamp;

  const GazeResult({
    required this.gazePoint,
    required this.confidence,
    required this.isBlinking,
    required this.headPose,
    required this.timestamp,
  });

  /// Create from JSON
  factory GazeResult.fromJson(Map<String, dynamic> json) {
    return GazeResult(
      gazePoint: Offset(
        (json['gazePointX'] as num).toDouble(),
        (json['gazePointY'] as num).toDouble(),
      ),
      confidence: (json['confidence'] as num).toDouble(),
      isBlinking: json['isBlinking'] as bool,
      headPose: HeadPose.fromJson(json['headPose'] as Map<String, dynamic>),
      timestamp: json['timestamp'] as int,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'gazePointX': gazePoint.dx,
      'gazePointY': gazePoint.dy,
      'confidence': confidence,
      'isBlinking': isBlinking,
      'headPose': headPose.toJson(),
      'timestamp': timestamp,
    };
  }

  @override
  String toString() {
    return 'GazeResult(gazePoint: $gazePoint, confidence: ${(confidence * 100).toStringAsFixed(0)}%, '
        'isBlinking: $isBlinking, headPose: $headPose)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GazeResult &&
        other.gazePoint == gazePoint &&
        other.confidence == confidence &&
        other.isBlinking == isBlinking &&
        other.headPose == headPose &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(
      gazePoint,
      confidence,
      isBlinking,
      headPose,
      timestamp,
    );
  }
}
