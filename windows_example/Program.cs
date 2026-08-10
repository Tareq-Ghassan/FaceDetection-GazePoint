using System;
using System.Threading.Tasks;
using GazePoint.SDK.Windows;

namespace GazePointExample
{
    /// <summary>
    /// Windows console example for GazePoint SDK
    /// Demonstrates real-time eye tracking and gaze detection
    /// </summary>
    class Program
    {
        private static GazeTracker? tracker;
        private static bool isRunning = true;

        static async Task Main(string[] args)
        {
            Console.WriteLine("═══════════════════════════════════════");
            Console.WriteLine("   GazePoint SDK - Windows Example");
            Console.WriteLine("═══════════════════════════════════════\n");

            try
            {
                // Initialize the tracker
                Console.WriteLine("Initializing GazePoint tracker...");
                tracker = new GazeTracker();
                await tracker.InitializeAsync();
                Console.WriteLine("✓ Tracker initialized successfully\n");

                // Subscribe to gaze events
                tracker.GazeDetected += OnGazeDetected;
                tracker.BlinkDetected += OnBlinkDetected;
                tracker.TrackingLost += OnTrackingLost;

                // Start tracking
                Console.WriteLine("Starting eye tracking...");
                await tracker.StartTrackingAsync();
                Console.WriteLine("✓ Tracking started\n");

                // Display instructions
                DisplayInstructions();

                // Run calibration
                Console.WriteLine("\nRunning 9-point calibration...");
                var calibrationResult = await tracker.CalibrateAsync(9);
                Console.WriteLine($"✓ Calibration completed");
                Console.WriteLine($"  Average error: {calibrationResult.AverageError:F2}px");
                Console.WriteLine($"  Max error: {calibrationResult.MaxError:F2}px\n");

                // Display real-time stats
                await DisplayRealtimeStats();

                // Main loop
                while (isRunning)
                {
                    var key = Console.ReadKey(true);
                    
                    switch (key.Key)
                    {
                        case ConsoleKey.C:
                            await Calibrate();
                            break;
                        case ConsoleKey.S:
                            await ShowStats();
                            break;
                        case ConsoleKey.R:
                            await RestartTracking();
                            break;
                        case ConsoleKey.Q:
                            isRunning = false;
                            break;
                    }
                }

                // Cleanup
                Console.WriteLine("\n\nStopping tracker...");
                await tracker.StopTrackingAsync();
                tracker.Dispose();
                Console.WriteLine("✓ Tracker stopped successfully");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"\n❌ Error: {ex.Message}");
                Console.WriteLine($"Stack trace: {ex.StackTrace}");
            }

            Console.WriteLine("\nPress any key to exit...");
            Console.ReadKey();
        }

        private static void DisplayInstructions()
        {
            Console.WriteLine("═══════════════════════════════════════");
            Console.WriteLine("Commands:");
            Console.WriteLine("  [C] Calibrate");
            Console.WriteLine("  [S] Show Statistics");
            Console.WriteLine("  [R] Restart Tracking");
            Console.WriteLine("  [Q] Quit");
            Console.WriteLine("═══════════════════════════════════════");
        }

        private static async Task DisplayRealtimeStats()
        {
            Console.WriteLine("Real-time tracking active...");
            Console.WriteLine("(Gaze data will be displayed below)\n");
        }

        private static void OnGazeDetected(object? sender, GazeResult e)
        {
            // Clear previous line and display current gaze data
            Console.SetCursorPosition(0, Console.CursorTop);
            Console.Write(new string(' ', Console.WindowWidth));
            Console.SetCursorPosition(0, Console.CursorTop);
            
            Console.Write($"👁️  Gaze: ({e.GazePoint.X:F0}, {e.GazePoint.Y:F0}) | " +
                         $"Confidence: {e.Confidence * 100:F1}% | " +
                         $"Head: P{e.HeadPose.Pitch:F1}° Y{e.HeadPose.Yaw:F1}° R{e.HeadPose.Roll:F1}°");
        }

        private static void OnBlinkDetected(object? sender, EventArgs e)
        {
            Console.WriteLine("\n👁️ Blink detected!");
        }

        private static void OnTrackingLost(object? sender, EventArgs e)
        {
            Console.WriteLine("\n⚠️  Tracking lost - please position your face in the camera view");
        }

        private static async Task Calibrate()
        {
            if (tracker == null) return;

            Console.WriteLine("\n\nStarting calibration...");
            Console.WriteLine("Look at each point that appears on the screen.");
            
            try
            {
                var result = await tracker.CalibrateAsync(9);
                Console.WriteLine($"✓ Calibration completed successfully");
                Console.WriteLine($"  Average error: {result.AverageError:F2}px");
                Console.WriteLine($"  Max error: {result.MaxError:F2}px");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Calibration failed: {ex.Message}");
            }
        }

        private static async Task ShowStats()
        {
            if (tracker == null) return;

            Console.WriteLine("\n\n═══════════════════════════════════════");
            Console.WriteLine("Performance Statistics");
            Console.WriteLine("═══════════════════════════════════════");
            
            var stats = await tracker.GetPerformanceStatsAsync();
            
            Console.WriteLine($"Frame Rate: {stats.FPS:F1} FPS");
            Console.WriteLine($"Average Latency: {stats.AverageLatency:F1}ms");
            Console.WriteLine($"Dropped Frames: {stats.DroppedFrames}");
            Console.WriteLine($"Tracking Time: {stats.TotalTrackingTime:hh\\:mm\\:ss}");
            Console.WriteLine($"Blinks Detected: {stats.TotalBlinks}");
            Console.WriteLine("═══════════════════════════════════════\n");
        }

        private static async Task RestartTracking()
        {
            if (tracker == null) return;

            Console.WriteLine("\n\nRestarting tracking...");
            
            try
            {
                await tracker.StopTrackingAsync();
                await Task.Delay(500);
                await tracker.StartTrackingAsync();
                Console.WriteLine("✓ Tracking restarted successfully");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Failed to restart: {ex.Message}");
            }
        }
    }
}
