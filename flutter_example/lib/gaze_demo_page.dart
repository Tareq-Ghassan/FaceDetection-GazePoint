import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazepoint_sdk/gazepoint_sdk.dart';

/// Demo host mirroring android_example / ios_example.
class GazeDemoPage extends StatefulWidget {
  const GazeDemoPage({super.key});

  @override
  State<GazeDemoPage> createState() => _GazeDemoPageState();
}

class _GazeDemoPageState extends State<GazeDemoPage> {
  final GazeTracker _tracker = GazeTracker();
  StreamSubscription<GazeResult>? _subscription;

  String _status = 'Starting…';
  Offset? _gazePoint;
  double _confidence = 0;
  bool _isBlinking = false;
  double _pitch = 0;
  double _yaw = 0;
  double _roll = 0;
  bool _faceDetected = false;
  bool _isTracking = false;
  PerformanceMetrics? _metrics;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      if (!await _tracker.isSupported()) {
        setState(() => _status = 'Gaze tracking not supported on this device');
        return;
      }

      final granted = await _tracker.requestCameraPermission();
      if (!granted) {
        setState(() => _status = 'Camera permission denied');
        return;
      }

      await _tracker.initialize();
      await _tracker.startTracking();

      _subscription = _tracker.gazeStream.listen(_onGaze);

      setState(() {
        _isTracking = true;
        _status = 'Look at the screen — tracking…';
      });
    } catch (e) {
      setState(() => _status = 'Error: $e');
    }
  }

  void _onGaze(GazeResult result) {
    setState(() {
      _faceDetected = true;
      _gazePoint = result.gazePoint;
      _confidence = result.confidence;
      _isBlinking = result.isBlinking;
      _pitch = result.headPose.pitch;
      _yaw = result.headPose.yaw;
      _roll = result.headPose.roll;
      _status = result.isBlinking ? 'Blink detected' : 'Tracking';
    });
  }

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      await _tracker.stopTracking();
      setState(() {
        _isTracking = false;
        _status = 'Tracking stopped';
        _faceDetected = false;
      });
    } else {
      await _tracker.startTracking();
      setState(() {
        _isTracking = true;
        _status = 'Look at the screen — tracking…';
      });
    }
  }

  Future<void> _refreshMetrics() async {
    if (!_tracker.isInitialized) return;
    final metrics = await _tracker.getPerformanceMetrics();
    setState(() => _metrics = metrics);
  }

  Future<void> _runCalibration() async {
    if (!_tracker.isInitialized || !_isTracking) {
      setState(() => _status = 'Start tracking before calibrating');
      return;
    }

    final size = MediaQuery.sizeOf(context);
    final targets = <Offset>[
      const Offset(50, 80),
      Offset(size.width - 50, 80),
      Offset(50, size.height - 80),
      Offset(size.width - 50, size.height - 80),
      Offset(size.width / 2, size.height / 2),
    ];

    final samples = <GazeCalibrationPoint>[];

    for (final target in targets) {
      if (!mounted) return;
      setState(() => _status = 'Look at the green target…');

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return _CalibrationTargetDialog(target: target);
        },
      );

      final latest = await _tracker.getLatestGaze();
      if (latest != null) {
        samples.add(GazeCalibrationPoint(
          expected: target,
          actual: latest.gazePoint,
        ));
      }
    }

    if (samples.length < 3) {
      setState(() => _status = 'Calibration failed — not enough samples');
      return;
    }

    await _tracker.calibrate(samples);
    setState(() => _status = 'Calibration complete (${samples.length} points)');
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _tracker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gaze = _gazePoint;

    return Scaffold(
      backgroundColor: const Color(0xFF0E1116),
      body: Stack(
        children: [
          // Full-screen tracking surface
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPainter(),
            ),
          ),

          if (gaze != null && _isTracking)
            Positioned(
              left: gaze.dx - 14,
              top: gaze.dy - 14,
              child: IgnorePointer(
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: (_isBlinking ? Colors.orange : const Color(0xFF3DDC84))
                        .withValues(alpha: 0.75),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white70, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: (_isBlinking ? Colors.orange : const Color(0xFF3DDC84))
                            .withValues(alpha: 0.45),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _StatusPanel(
                    status: _status,
                    faceDetected: _faceDetected,
                    confidence: _confidence,
                    isBlinking: _isBlinking,
                    pitch: _pitch,
                    yaw: _yaw,
                    roll: _roll,
                    gazePoint: gaze,
                    metrics: _metrics,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _tracker.isInitialized ? _toggleTracking : null,
                          child: Text(_isTracking ? 'Stop' : 'Start'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _tracker.isInitialized ? _runCalibration : null,
                          child: const Text('Calibrate'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        onPressed: _tracker.isInitialized ? _refreshMetrics : null,
                        icon: const Icon(Icons.speed),
                        tooltip: 'Performance',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPanel extends StatelessWidget {
  const _StatusPanel({
    required this.status,
    required this.faceDetected,
    required this.confidence,
    required this.isBlinking,
    required this.pitch,
    required this.yaw,
    required this.roll,
    required this.gazePoint,
    required this.metrics,
  });

  final String status;
  final bool faceDetected;
  final double confidence;
  final bool isBlinking;
  final double pitch;
  final double yaw;
  final double roll;
  final Offset? gazePoint;
  final PerformanceMetrics? metrics;

  @override
  Widget build(BuildContext context) {
    final gazeText = gazePoint == null
        ? '—'
        : '(${gazePoint!.dx.toStringAsFixed(0)}, ${gazePoint!.dy.toStringAsFixed(0)})';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GazePoint Flutter',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(status),
          const SizedBox(height: 12),
          _line('Face', faceDetected ? 'Detected' : 'Not detected'),
          _line('Gaze', gazeText),
          _line('Confidence', '${(confidence * 100).toStringAsFixed(0)}%'),
          _line('Blink', isBlinking ? 'Yes' : 'No'),
          _line(
            'Head pose',
            'p ${pitch.toStringAsFixed(1)}  y ${yaw.toStringAsFixed(1)}  r ${roll.toStringAsFixed(1)}',
          ),
          if (metrics != null) ...[
            const SizedBox(height: 8),
            _line('FPS', metrics!.fps.toStringAsFixed(1)),
            _line(
              'Avg ms',
              metrics!.avgProcessingTimeMs.toStringAsFixed(1),
            ),
          ],
        ],
      ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontFeatures: [
                FontFeature.tabularFigures(),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalibrationTargetDialog extends StatefulWidget {
  const _CalibrationTargetDialog({required this.target});

  final Offset target;

  @override
  State<_CalibrationTargetDialog> createState() =>
      _CalibrationTargetDialogState();
}

class _CalibrationTargetDialogState extends State<_CalibrationTargetDialog> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black54,
      child: Stack(
        children: [
          Positioned(
            left: widget.target.dx - 18,
            top: widget.target.dy - 18,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF3DDC84),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'Look at the green target',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
