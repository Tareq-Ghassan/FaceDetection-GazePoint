/**
 * GazePoint SDK for Web
 * Real-time eye tracking and gaze point detection
 */

export { GazeTracker } from './core/GazeTracker';
export { FaceDetector } from './core/FaceDetector';
export { GazeEstimator } from './core/GazeEstimator';
export { HeadPoseEstimator } from './core/HeadPoseEstimator';
export { CameraManager } from './utils/CameraManager';
export { KalmanFilter } from './utils/KalmanFilter';

export * from './types';

// Version
export const VERSION = '2.0.0';
