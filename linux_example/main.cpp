#include <iostream>
#include <iomanip>
#include <chrono>
#include <thread>
#include <signal.h>
#include <gazepoint/GazeTracker.hpp>

using namespace gazepoint;

// Global flag for graceful shutdown
bool g_running = true;

void signalHandler(int signum) {
    std::cout << "\n\nInterrupt signal (" << signum << ") received.\n";
    g_running = false;
}

void displayInstructions() {
    std::cout << "═══════════════════════════════════════\n";
    std::cout << "Commands:\n";
    std::cout << "  [c] Calibrate\n";
    std::cout << "  [s] Show Statistics\n";
    std::cout << "  [r] Restart Tracking\n";
    std::cout << "  [q] Quit\n";
    std::cout << "═══════════════════════════════════════\n";
}

void onGazeDetected(const GazeResult& result) {
    // Clear line and display gaze data
    std::cout << "\r" << std::string(120, ' ') << "\r";
    std::cout << "👁️  Gaze: (" 
              << std::fixed << std::setprecision(0) << result.gazePoint.x << ", "
              << result.gazePoint.y << ") | "
              << "Confidence: " << std::setprecision(1) << (result.confidence * 100) << "% | "
              << "Head: P" << result.headPose.pitch << "° "
              << "Y" << result.headPose.yaw << "° "
              << "R" << result.headPose.roll << "°" 
              << std::flush;
}

void onBlinkDetected() {
    std::cout << "\n👁️ Blink detected!\n";
}

void onTrackingLost() {
    std::cout << "\n⚠️  Tracking lost - please position your face in the camera view\n";
}

void runCalibration(GazeTracker& tracker) {
    std::cout << "\n\nStarting calibration...\n";
    std::cout << "Look at each point that appears on the screen.\n";
    
    try {
        auto result = tracker.calibrate(9);
        std::cout << "✓ Calibration completed successfully\n";
        std::cout << std::fixed << std::setprecision(2);
        std::cout << "  Average error: " << result.averageError << "px\n";
        std::cout << "  Max error: " << result.maxError << "px\n";
    } catch (const std::exception& e) {
        std::cout << "❌ Calibration failed: " << e.what() << "\n";
    }
}

void showStats(GazeTracker& tracker) {
    std::cout << "\n\n═══════════════════════════════════════\n";
    std::cout << "Performance Statistics\n";
    std::cout << "═══════════════════════════════════════\n";
    
    auto stats = tracker.getPerformanceStats();
    
    std::cout << std::fixed << std::setprecision(1);
    std::cout << "Frame Rate: " << stats.fps << " FPS\n";
    std::cout << "Average Latency: " << stats.averageLatency << "ms\n";
    std::cout << "Dropped Frames: " << stats.droppedFrames << "\n";
    
    int hours = stats.totalTrackingTime / 3600;
    int minutes = (stats.totalTrackingTime % 3600) / 60;
    int seconds = stats.totalTrackingTime % 60;
    std::cout << "Tracking Time: " 
              << std::setfill('0') << std::setw(2) << hours << ":"
              << std::setw(2) << minutes << ":"
              << std::setw(2) << seconds << "\n";
    
    std::cout << "Blinks Detected: " << stats.totalBlinks << "\n";
    std::cout << "═══════════════════════════════════════\n\n";
}

void restartTracking(GazeTracker& tracker) {
    std::cout << "\n\nRestarting tracking...\n";
    
    try {
        tracker.stopTracking();
        std::this_thread::sleep_for(std::chrono::milliseconds(500));
        tracker.startTracking();
        std::cout << "✓ Tracking restarted successfully\n";
    } catch (const std::exception& e) {
        std::cout << "❌ Failed to restart: " << e.what() << "\n";
    }
}

int main(int argc, char* argv[]) {
    // Register signal handler for graceful shutdown
    signal(SIGINT, signalHandler);
    signal(SIGTERM, signalHandler);
    
    std::cout << "═══════════════════════════════════════\n";
    std::cout << "   GazePoint SDK - Linux Example\n";
    std::cout << "═══════════════════════════════════════\n\n";
    
    try {
        // Initialize tracker
        std::cout << "Initializing GazePoint tracker...\n";
        GazeTracker tracker;
        tracker.initialize();
        std::cout << "✓ Tracker initialized successfully\n\n";
        
        // Set up event handlers
        tracker.setGazeCallback(onGazeDetected);
        tracker.setBlinkCallback(onBlinkDetected);
        tracker.setTrackingLostCallback(onTrackingLost);
        
        // Start tracking
        std::cout << "Starting eye tracking...\n";
        tracker.startTracking();
        std::cout << "✓ Tracking started\n\n";
        
        // Display instructions
        displayInstructions();
        
        // Run calibration
        std::cout << "\nRunning 9-point calibration...\n";
        auto calibrationResult = tracker.calibrate(9);
        std::cout << "✓ Calibration completed\n";
        std::cout << std::fixed << std::setprecision(2);
        std::cout << "  Average error: " << calibrationResult.averageError << "px\n";
        std::cout << "  Max error: " << calibrationResult.maxError << "px\n\n";
        
        std::cout << "Real-time tracking active...\n";
        std::cout << "(Gaze data will be displayed below)\n\n";
        
        // Main loop - non-blocking input check
        while (g_running) {
            // Check for input without blocking
            fd_set readfds;
            FD_ZERO(&readfds);
            FD_SET(STDIN_FILENO, &readfds);
            
            struct timeval tv;
            tv.tv_sec = 0;
            tv.tv_usec = 100000; // 100ms timeout
            
            if (select(STDIN_FILENO + 1, &readfds, nullptr, nullptr, &tv) > 0) {
                char input;
                std::cin >> input;
                
                switch (input) {
                    case 'c':
                    case 'C':
                        runCalibration(tracker);
                        break;
                    case 's':
                    case 'S':
                        showStats(tracker);
                        break;
                    case 'r':
                    case 'R':
                        restartTracking(tracker);
                        break;
                    case 'q':
                    case 'Q':
                        g_running = false;
                        break;
                    default:
                        std::cout << "\nUnknown command. Available: c, s, r, q\n";
                }
            }
            
            // Small delay to prevent busy waiting
            std::this_thread::sleep_for(std::chrono::milliseconds(10));
        }
        
        // Cleanup
        std::cout << "\n\nStopping tracker...\n";
        tracker.stopTracking();
        std::cout << "✓ Tracker stopped successfully\n";
        
    } catch (const std::exception& e) {
        std::cerr << "\n❌ Error: " << e.what() << "\n";
        return 1;
    }
    
    std::cout << "\nGoodbye! 👋\n";
    return 0;
}
