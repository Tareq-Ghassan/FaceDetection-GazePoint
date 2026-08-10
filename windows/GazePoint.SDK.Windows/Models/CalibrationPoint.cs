using System.Windows;

namespace GazePoint.SDK.Windows.Models
{
    /// <summary>
    /// Calibration point pairing expected and actual gaze
    /// </summary>
    public class CalibrationPoint
    {
        /// <summary>
        /// Where the user was asked to look
        /// </summary>
        public Point Expected { get; set; }
        
        /// <summary>
        /// Where the tracker measured the gaze
        /// </summary>
        public Point Actual { get; set; }
    }
}
