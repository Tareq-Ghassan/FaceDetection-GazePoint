#pragma once

#include <functional>
#include <memory>
#include <opencv2/opencv.hpp>

namespace gazepoint {

struct Point2D {
    double x;
    double y;
};

struct HeadPose {
    double pitch;
    double yaw;
    double roll;
};

struct GazeResult {
    Point2D gazePoint;
    double confidence;
    bool isBlinking;
    HeadPose headPose;
    long timestamp;
};

class GazeTracker {
public:
    GazeTracker();
    ~GazeTracker();
    
    // Initialize tracker
    bool initialize();
    
    // Start/stop tracking
    bool startTracking();
    void stopTracking();
    bool isTracking() const;
    
    // Process single frame
    bool processFrame();
    
    // Calibration
    bool calibrate(const std::vector<std::pair<Point2D, Point2D>>& points);
    
    // Callbacks
    std::function<void(const GazeResult&)> onGazeUpdate;
    std::function<void(const std::string&)> onError;
    
private:
    class Impl;
    std::unique_ptr<Impl> pImpl;
};

} // namespace gazepoint
