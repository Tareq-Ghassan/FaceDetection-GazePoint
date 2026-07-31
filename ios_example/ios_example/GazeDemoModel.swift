import AVFoundation
import GazePointSDK
import SwiftUI

@MainActor
@Observable
final class GazeDemoModel {
    var permissionDenied = false
    var statusText = "Starting camera…"
    var gazePoint: CGPoint?
    var confidence: Float = 0
    var isBlinking = false
    var pitch: Float = 0
    var yaw: Float = 0
    var roll: Float = 0
    var faceDetected = false

    let session = AVCaptureSession()

    private let sessionQueue = DispatchQueue(label: "com.gazepoint.ios-example.camera")
    private let videoOutput = AVCaptureVideoDataOutput()
    private var frameProcessor: FrameProcessor?

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    guard let self else { return }
                    if granted {
                        self.configureSession()
                    } else {
                        self.permissionDenied = true
                        self.statusText = "Camera permission denied"
                    }
                }
            }
        default:
            permissionDenied = true
            statusText = "Camera permission denied. Enable it in Settings."
        }
    }

    func stop() {
        sessionQueue.async { [session] in
            if session.isRunning {
                session.stopRunning()
            }
        }
    }

    private func configureSession() {
        let processor = FrameProcessor { [weak self] result in
            Task { @MainActor in
                self?.apply(result)
            }
        }
        frameProcessor = processor

        sessionQueue.async { [session, videoOutput] in
            session.beginConfiguration()
            session.sessionPreset = .high

            session.inputs.forEach { session.removeInput($0) }
            session.outputs.forEach { session.removeOutput($0) }

            guard
                let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
                let input = try? AVCaptureDeviceInput(device: camera),
                session.canAddInput(input)
            else {
                Task { @MainActor in
                    self.statusText = "Front camera unavailable"
                }
                session.commitConfiguration()
                return
            }

            session.addInput(input)

            videoOutput.alwaysDiscardsLateVideoFrames = true
            videoOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ]

            guard session.canAddOutput(videoOutput) else {
                session.commitConfiguration()
                return
            }

            session.addOutput(videoOutput)
            videoOutput.setSampleBufferDelegate(processor, queue: DispatchQueue(label: "com.gazepoint.ios-example.frames"))

            if let connection = videoOutput.connection(with: .video) {
                if connection.isVideoOrientationSupported {
                    connection.videoOrientation = .portrait
                }
                if connection.isVideoMirroringSupported {
                    connection.isVideoMirrored = true
                }
            }

            session.commitConfiguration()
            session.startRunning()

            Task { @MainActor in
                self.statusText = "Look at the screen — tracking…"
            }
        }
    }

    private func apply(_ result: GazeTracker.GazeResult?) {
        guard let result else {
            faceDetected = false
            statusText = "No face detected"
            return
        }

        faceDetected = true
        gazePoint = result.gazePoint
        confidence = result.confidence
        isBlinking = result.isBlinking
        pitch = result.headPose.pitch
        yaw = result.headPose.yaw
        roll = result.headPose.roll
        statusText = isBlinking ? "Blink detected" : "Tracking"
    }
}

/// Runs off the main actor so camera callbacks stay non-blocking.
nonisolated final class FrameProcessor: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, @unchecked Sendable {
    private let tracker = GazeTracker()
    private let onResult: @Sendable (GazeTracker.GazeResult?) -> Void

    init(onResult: @escaping @Sendable (GazeTracker.GazeResult?) -> Void) {
        self.onResult = onResult
    }

    func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let result = tracker.calculateGazePoint(from: pixelBuffer, orientation: .leftMirrored)
        onResult(result)
    }
}
