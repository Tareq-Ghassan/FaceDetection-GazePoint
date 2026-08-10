/**
 * Gaze point estimation from facial landmarks
 */

import { Point2D, HeadPose, CalibrationPoint } from '../types';

export class GazeEstimator {
  private calibrationPoints: CalibrationPoint[] = [];

  public calibrate(points: CalibrationPoint[]): void {
    this.calibrationPoints = points;
  }

  public estimate(landmarks: Point2D[], headPose: HeadPose): Point2D {
    // TODO: Implement actual gaze estimation algorithm
    // This uses eye landmarks and head pose to calculate gaze direction
    
    // Placeholder: return center of screen
    return {
      x: window.innerWidth / 2,
      y: window.innerHeight / 2,
    };
  }
}
