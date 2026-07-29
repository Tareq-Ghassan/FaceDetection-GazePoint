/// Performance monitoring metrics
class PerformanceMetrics {
  /// Frames per second
  final double fps;
  
  /// Average processing time in milliseconds
  final double avgProcessingTimeMs;
  
  /// Maximum processing time in milliseconds
  final double maxProcessingTimeMs;
  
  /// Number of dropped frames
  final int droppedFrames;
  
  /// Total frames processed
  final int totalFrames;

  const PerformanceMetrics({
    required this.fps,
    required this.avgProcessingTimeMs,
    required this.maxProcessingTimeMs,
    required this.droppedFrames,
    required this.totalFrames,
  });

  /// Create from JSON
  factory PerformanceMetrics.fromJson(Map<String, dynamic> json) {
    return PerformanceMetrics(
      fps: (json['fps'] as num).toDouble(),
      avgProcessingTimeMs: (json['avgProcessingTimeMs'] as num).toDouble(),
      maxProcessingTimeMs: (json['maxProcessingTimeMs'] as num).toDouble(),
      droppedFrames: json['droppedFrames'] as int,
      totalFrames: json['totalFrames'] as int,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'fps': fps,
      'avgProcessingTimeMs': avgProcessingTimeMs,
      'maxProcessingTimeMs': maxProcessingTimeMs,
      'droppedFrames': droppedFrames,
      'totalFrames': totalFrames,
    };
  }

  /// Check if performance is degraded
  bool get isPerformanceDegraded => fps < 15 || avgProcessingTimeMs > 100;

  @override
  String toString() {
    return 'PerformanceMetrics(\n'
        '  FPS: ${fps.toStringAsFixed(1)}\n'
        '  Avg Processing: ${avgProcessingTimeMs.toStringAsFixed(1)} ms\n'
        '  Max Processing: ${maxProcessingTimeMs.toStringAsFixed(1)} ms\n'
        '  Dropped Frames: $droppedFrames\n'
        '  Total Frames: $totalFrames\n'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PerformanceMetrics &&
        other.fps == fps &&
        other.avgProcessingTimeMs == avgProcessingTimeMs &&
        other.maxProcessingTimeMs == maxProcessingTimeMs &&
        other.droppedFrames == droppedFrames &&
        other.totalFrames == totalFrames;
  }

  @override
  int get hashCode {
    return Object.hash(
      fps,
      avgProcessingTimeMs,
      maxProcessingTimeMs,
      droppedFrames,
      totalFrames,
    );
  }
}
