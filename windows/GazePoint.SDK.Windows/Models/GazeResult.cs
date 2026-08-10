using System;
using System.Windows;

namespace GazePoint.SDK.Windows.Models
{
    /// <summary>
    /// Result of gaze point calculation
    /// </summary>
    public class GazeResult
    {
        /// <summary>
        /// The calculated gaze point in screen coordinates
        /// </summary>
        public Point GazePoint { get; set; }
        
        /// <summary>
        /// Confidence score from 0.0 to 1.0
        /// </summary>
        public double Confidence { get; set; }
        
        /// <summary>
        /// Whether the user is currently blinking
        /// </summary>
        public bool IsBlinking { get; set; }
        
        /// <summary>
        /// Head pose information
        /// </summary>
        public HeadPose HeadPose { get; set; }
        
        /// <summary>
        /// Timestamp of the result
        /// </summary>
        public DateTime Timestamp { get; set; }
        
        public GazeResult()
        {
            HeadPose = new HeadPose();
            Timestamp = DateTime.Now;
        }
    }
}
