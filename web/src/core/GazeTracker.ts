/**
 * GazePoint SDK for Web - Main Tracker Class
 */

import {
  GazeTrackerOptions,
  GazeResult,
  CalibrationPoint,
  PerformanceMetrics,
  TrackerState,
  Point2D,
} from '../types';
import { FaceDetector } from './FaceDetector';
import { GazeEstimator } from './GazeEstimator';
import { HeadPoseEstimator } from './HeadPoseEstimator';
import { CameraManager } from '../utils/CameraManager';
import { KalmanFilter } from '../utils/KalmanFilter';

/**
 * Main GazeTracker class for eye tracking in web browsers
 */
export class GazeTracker {
  private options: Required<GazeTrackerOptions>;
  private state: TrackerState = TrackerState.UNINITIALIZED;
  
  private cameraManager: CameraManager;
  private faceDetector: FaceDetector;
  private gazeEstimator: GazeEstimator;
  private headPoseEstimator: HeadPoseEstimator;
  
  private kalmanFilterX: KalmanFilter;
  private kalmanFilterY: KalmanFilter;
  
  private animationFrameId: number | null = null;
  private lastFrameTime: number = 0;
  private frameCount: number = 0;
  private droppedFrames: number = 0;
  
  private calibrationPoints: CalibrationPoint[] = [];

  constructor(options: GazeTrackerOptions = {}) {
    // Set default options
    this.options = {
      videoElement: options.videoElement || document.createElement('video'),
      canvasElement: options.canvasElement || document.createElement('canvas'),
      onGazeUpdate: options.onGazeUpdate || (() => {}),
      onError: options.onError || console.error,
      modelPath: options.modelPath || 'https://cdn.jsdelivr.net/npm/@mediapipe/face_mesh',
      targetFPS: options.targetFPS || 30,
      debug: options.debug || false,
      cameraConstraints: options.cameraConstraints || {
        video: {
          width: { ideal: 1280 },
          height: { ideal: 720 },
          frameRate: { ideal: 30 },
        },
      },
      processNoise: options.processNoise || 0.01,
      measurementNoise: options.measurementNoise || 0.1,
    };

    // Initialize components
    this.cameraManager = new CameraManager(this.options.videoElement);
    this.faceDetector = new FaceDetector(this.options.modelPath);
    this.gazeEstimator = new GazeEstimator();
    this.headPoseEstimator = new HeadPoseEstimator();
    
    // Initialize Kalman filters for smoothing
    this.kalmanFilterX = new KalmanFilter(
      this.options.processNoise,
      this.options.measurementNoise
    );
    this.kalmanFilterY = new KalmanFilter(
      this.options.processNoise,
      this.options.measurementNoise
    );
  }

  /**
   * Initialize the tracker and load ML models
   */
  public async initialize(): Promise<void> {
    try {
      this.state = TrackerState.INITIALIZING;
      
      // Load face detection model
      await this.faceDetector.initialize();
      
      this.state = TrackerState.READY;
    } catch (error) {
      this.state = TrackerState.ERROR;
      this.options.onError(error as Error);
      throw error;
    }
  }

  /**
   * Start camera and begin tracking
   */
  public async start(): Promise<void> {
    if (this.state !== TrackerState.READY && this.state !== TrackerState.PAUSED) {
      throw new Error('Tracker must be initialized before starting');
    }

    try {
      // Start camera
      await this.cameraManager.start(this.options.cameraConstraints);
      
      this.state = TrackerState.TRACKING;
      this.lastFrameTime = performance.now();
      
      // Start processing loop
      this.processFrame();
    } catch (error) {
      this.state = TrackerState.ERROR;
      this.options.onError(error as Error);
      throw error;
    }
  }

  /**
   * Stop tracking and release camera
   */
  public stop(): void {
    if (this.animationFrameId !== null) {
      cancelAnimationFrame(this.animationFrameId);
      this.animationFrameId = null;
    }
    
    this.cameraManager.stop();
    this.state = TrackerState.READY;
  }

  /**
   * Pause tracking (keeps camera active)
   */
  public pause(): void {
    if (this.state === TrackerState.TRACKING) {
      this.state = TrackerState.PAUSED;
    }
  }

  /**
   * Resume tracking
   */
  public resume(): void {
    if (this.state === TrackerState.PAUSED) {
      this.state = TrackerState.TRACKING;
      this.processFrame();
    }
  }

  /**
   * Calibrate tracker with custom points
   */
  public async calibrate(points: CalibrationPoint[]): Promise<void> {
    this.calibrationPoints = points;
    this.gazeEstimator.calibrate(points);
  }

  /**
   * Get current performance metrics
   */
  public getPerformanceMetrics(): PerformanceMetrics {
    const now = performance.now();
    const elapsed = (now - this.lastFrameTime) / 1000; // seconds
    const fps = elapsed > 0 ? this.frameCount / elapsed : 0;
    
    return {
      fps,
      latency: 1000 / fps,
      droppedFrames: this.droppedFrames,
      totalFrames: this.frameCount,
    };
  }

  /**
   * Get current tracker state
   */
  public getState(): TrackerState {
    return this.state;
  }

  /**
   * Main processing loop
   */
  private async processFrame(): Promise<void> {
    if (this.state !== TrackerState.TRACKING) {
      return;
    }

    const startTime = performance.now();
    
    try {
      // Detect face
      const faceResult = await this.faceDetector.detectFace(this.options.videoElement);
      
      if (faceResult) {
        // Estimate head pose
        const headPose = this.headPoseEstimator.estimate(faceResult.landmarks);
        
        // Estimate gaze point
        const rawGazePoint = this.gazeEstimator.estimate(
          faceResult.landmarks,
          headPose
        );
        
        // Apply Kalman filtering for smoothness
        const smoothedGazePoint: Point2D = {
          x: this.kalmanFilterX.filter(rawGazePoint.x),
          y: this.kalmanFilterY.filter(rawGazePoint.y),
        };
        
        // Detect blink
        const isBlinking = this.detectBlink(faceResult.landmarks);
        
        // Create result
        const result: GazeResult = {
          gazePoint: smoothedGazePoint,
          confidence: faceResult.confidence,
          isBlinking,
          headPose,
          timestamp: Date.now(),
        };
        
        // Call callback
        this.options.onGazeUpdate(result);
        
        // Debug visualization
        if (this.options.debug && this.options.canvasElement) {
          this.drawDebug(faceResult.landmarks, smoothedGazePoint);
        }
      } else {
        this.droppedFrames++;
      }
      
      this.frameCount++;
      
    } catch (error) {
      console.error('Error processing frame:', error);
      this.droppedFrames++;
    }
    
    // Schedule next frame
    const processingTime = performance.now() - startTime;
    const targetFrameTime = 1000 / this.options.targetFPS;
    const delay = Math.max(0, targetFrameTime - processingTime);
    
    setTimeout(() => {
      this.animationFrameId = requestAnimationFrame(() => this.processFrame());
    }, delay);
  }

  /**
   * Detect blink using Eye Aspect Ratio (EAR)
   */
  private detectBlink(landmarks: Point2D[]): boolean {
    // MediaPipe Face Mesh landmark indices for eyes
    const LEFT_EYE_INDICES = [33, 133, 160, 159, 158, 157, 173, 144];
    const RIGHT_EYE_INDICES = [362, 263, 387, 386, 385, 384, 398, 373];
    
    const calculateEAR = (eyeIndices: number[]): number => {
      const points = eyeIndices.map(i => landmarks[i]);
      
      // Vertical distances
      const v1 = this.distance(points[1], points[5]);
      const v2 = this.distance(points[2], points[4]);
      
      // Horizontal distance
      const h = this.distance(points[0], points[3]);
      
      return (v1 + v2) / (2.0 * h);
    };
    
    const leftEAR = calculateEAR(LEFT_EYE_INDICES);
    const rightEAR = calculateEAR(RIGHT_EYE_INDICES);
    const avgEAR = (leftEAR + rightEAR) / 2.0;
    
    // Threshold for blink detection (typically 0.2-0.25)
    const EAR_THRESHOLD = 0.22;
    
    return avgEAR < EAR_THRESHOLD;
  }

  /**
   * Calculate Euclidean distance between two points
   */
  private distance(p1: Point2D, p2: Point2D): number {
    const dx = p2.x - p1.x;
    const dy = p2.y - p1.y;
    return Math.sqrt(dx * dx + dy * dy);
  }

  /**
   * Draw debug visualization
   */
  private drawDebug(landmarks: Point2D[], gazePoint: Point2D): void {
    const canvas = this.options.canvasElement;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;
    
    // Clear canvas
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    
    // Draw face landmarks
    ctx.fillStyle = 'rgba(0, 255, 0, 0.5)';
    landmarks.forEach(point => {
      ctx.beginPath();
      ctx.arc(point.x, point.y, 2, 0, 2 * Math.PI);
      ctx.fill();
    });
    
    // Draw gaze point
    ctx.fillStyle = 'rgba(255, 0, 0, 0.8)';
    ctx.beginPath();
    ctx.arc(gazePoint.x, gazePoint.y, 15, 0, 2 * Math.PI);
    ctx.fill();
  }
}
