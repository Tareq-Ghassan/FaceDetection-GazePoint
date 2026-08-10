namespace GazePoint.SDK.Windows.Models
{
    /// <summary>
    /// Head pose angles in degrees
    /// </summary>
    public class HeadPose
    {
        /// <summary>
        /// Rotation around X-axis (nodding)
        /// </summary>
        public double Pitch { get; set; }
        
        /// <summary>
        /// Rotation around Y-axis (shaking head)
        /// </summary>
        public double Yaw { get; set; }
        
        /// <summary>
        /// Rotation around Z-axis (tilting head)
        /// </summary>
        public double Roll { get; set; }
    }
}
