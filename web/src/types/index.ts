/**
 * GazePoint SDK for Web - Type Definitions
 */

/**
 * 2D point coordinates
 */
export interface Point2D {
  x: number;
  y: number;
}

/**
 * Head pose angles in degrees
 */
export interface HeadPose {
  /** Rotation around X-axis (nodding) */
  pitch: number;
  /** Rotation around Y-axis (shaking head) */
  yaw: number;
  /** Rotation around Z-axis (tilting head) */
  roll: number;
}

/**
 * Result of gaze point calculation
 */
export interface GazeResult {
  /** The calculated gaze point in screen coordinates (pixels) */
  gazePoint: Point2D;
  
  /** Confidence score from 0.0 to 1.0 */
  confidence: number;
  
  /** Whether the user is currently blinking */
  isBlinking: boolean;
  
  /** Head pose information */
  headPose: HeadPose;
  
  /** Timestamp in milliseconds */
  timestamp: number;
  
  /** Left eye center position */
  leftEye?: Point2D;
  
  /** Right eye center position */
  rightEye?: Point2D;
}

/**
 * Calibration point pairing expected and actual gaze
 */
export interface CalibrationPoint {
  /** Where the user was asked to look */
  expected: Point2D;
  
  /** Where the tracker measured the gaze */
  actual: Point2D;
}

/**
 * Performance metrics
 */
export interface PerformanceMetrics {
  /** Current frames per second */
  fps: number;
  
  /** Processing latency in milliseconds */
  latency: number;
  
  /** Number of dropped frames */
  droppedFrames: number;
  
  /** Total frames processed */
  totalFrames: number;
}

/**
 * Configuration options for GazeTracker
 */
export interface GazeTrackerOptions {
  /** Video element for camera feed (optional, will create if not provided) */
  videoElement?: HTMLVideoElement;
  
  /** Canvas element for visualization (optional) */
  canvasElement?: HTMLCanvasElement;
  
  /** Callback function called on each gaze update */
  onGazeUpdate?: (result: GazeResult) => void;
  
  /** Callback function called on errors */
  onError?: (error: Error) => void;
  
  /** Path to MediaPipe models (optional, uses CDN by default) */
  modelPath?: string;
  
  /** Target frame rate (default: 30) */
  targetFPS?: number;
  
  /** Enable debug visualization */
  debug?: boolean;
  
  /** Camera constraints */
  cameraConstraints?: MediaStreamConstraints;
  
  /** Kalman filter process noise (higher = less smooth, more responsive) */
  processNoise?: number;
  
  /** Kalman filter measurement noise (higher = smoother, less responsive) */
  measurementNoise?: number;
}

/**
 * Face detection result from MediaPipe
 */
export interface FaceDetectionResult {
  /** 468 facial landmarks */
  landmarks: Point2D[];
  
  /** Face bounding box */
  boundingBox: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
  
  /** Detection confidence */
  confidence: number;
}

/**
 * Eye region landmarks
 */
export interface EyeLandmarks {
  /** Left eye landmarks */
  leftEye: Point2D[];
  
  /** Right eye landmarks */
  rightEye: Point2D[];
  
  /** Left eye center */
  leftEyeCenter: Point2D;
  
  /** Right eye center */
  rightEyeCenter: Point2D;
}

/**
 * Tracker state
 */
export enum TrackerState {
  /** Not initialized */
  UNINITIALIZED = 'UNINITIALIZED',
  
  /** Initializing models */
  INITIALIZING = 'INITIALIZING',
  
  /** Ready to start */
  READY = 'READY',
  
  /** Currently tracking */
  TRACKING = 'TRACKING',
  
  /** Paused */
  PAUSED = 'PAUSED',
  
  /** Error state */
  ERROR = 'ERROR',
}
