/**
 * Kalman Filter for smoothing gaze point tracking
 */

export class KalmanFilter {
  private processNoise: number;
  private measurementNoise: number;
  private estimate: number = 0;
  private errorCovariance: number = 1;

  constructor(processNoise: number = 0.01, measurementNoise: number = 0.1) {
    this.processNoise = processNoise;
    this.measurementNoise = measurementNoise;
  }

  public filter(measurement: number): number {
    // Prediction
    const predictedEstimate = this.estimate;
    const predictedErrorCovariance = this.errorCovariance + this.processNoise;

    // Update
    const kalmanGain =
      predictedErrorCovariance /
      (predictedErrorCovariance + this.measurementNoise);
    
    this.estimate = predictedEstimate + kalmanGain * (measurement - predictedEstimate);
    this.errorCovariance = (1 - kalmanGain) * predictedErrorCovariance;

    return this.estimate;
  }

  public reset(): void {
    this.estimate = 0;
    this.errorCovariance = 1;
  }
}
