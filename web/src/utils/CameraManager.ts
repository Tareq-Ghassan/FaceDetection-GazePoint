/**
 * Camera management using WebRTC
 */

export class CameraManager {
  private videoElement: HTMLVideoElement;
  private stream: MediaStream | null = null;

  constructor(videoElement: HTMLVideoElement) {
    this.videoElement = videoElement;
  }

  public async start(constraints: MediaStreamConstraints): Promise<void> {
    try {
      this.stream = await navigator.mediaDevices.getUserMedia(constraints);
      this.videoElement.srcObject = this.stream;
      await this.videoElement.play();
    } catch (error) {
      console.error('Failed to start camera:', error);
      throw error;
    }
  }

  public stop(): void {
    if (this.stream) {
      this.stream.getTracks().forEach(track => track.stop());
      this.stream = null;
    }
    this.videoElement.srcObject = null;
  }
}
