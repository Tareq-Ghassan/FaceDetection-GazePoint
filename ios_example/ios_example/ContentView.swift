import SwiftUI

struct ContentView: View {
    @State private var model = GazeDemoModel()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                CameraPreviewView(session: model.session)
                    .ignoresSafeArea()

                // Gaze indicator in screen coordinates from GazePointSDK
                if let point = model.gazePoint, model.faceDetected {
                    Circle()
                        .fill(Color.green.opacity(0.85))
                        .frame(width: 28, height: 28)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 2)
                        )
                        .position(x: point.x, y: point.y)
                        .animation(.easeOut(duration: 0.08), value: point)
                }

                VStack {
                    Spacer()

                    statusPanel
                        .padding()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .preferredColorScheme(.dark)
        .onAppear { model.start() }
        .onDisappear { model.stop() }
        .alert("Camera Access Needed", isPresented: $model.permissionDenied) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Enable camera access in Settings → ios_example to test gaze tracking.")
        }
    }

    private var statusPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GazePoint SDK Demo")
                .font(.headline)

            Text(model.statusText)
                .font(.subheadline)
                .foregroundStyle(model.faceDetected ? .green : .yellow)

            if model.faceDetected {
                Text(String(
                    format: "Gaze: (%.0f, %.0f)  Confidence: %.0f%%",
                    model.gazePoint?.x ?? 0,
                    model.gazePoint?.y ?? 0,
                    model.confidence * 100
                ))
                .font(.caption.monospaced())

                Text(String(
                    format: "Head  pitch: %.1f  yaw: %.1f  roll: %.1f",
                    model.pitch,
                    model.yaw,
                    model.roll
                ))
                .font(.caption.monospaced())

                Text(model.isBlinking ? "Eyes: blinking" : "Eyes: open")
                    .font(.caption)
            } else {
                Text("Point the front camera at your face.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ContentView()
}
