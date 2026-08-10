cmake_minimum_required(VERSION 3.20)
project(GazePointSDK VERSION 2.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find dependencies
find_package(OpenCV 4.5 REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(DLIB REQUIRED dlib-1)

# Library sources
set(SOURCES
    src/GazeTracker.cpp
    src/FaceDetector.cpp
    src/GazeEstimator.cpp
    src/HeadPoseEstimator.cpp
    src/KalmanFilter.cpp
)

# Create library
add_library(gazepoint SHARED ${SOURCES})

target_include_directories(gazepoint
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${OpenCV_INCLUDE_DIRS}
        ${DLIB_INCLUDE_DIRS}
)

target_link_libraries(gazepoint
    PUBLIC
        ${OpenCV_LIBS}
        ${DLIB_LIBRARIES}
)

# Example executable
add_executable(gazepoint_example examples/basic.cpp)
target_link_libraries(gazepoint_example gazepoint)

# Install
install(TARGETS gazepoint
    EXPORT GazePointSDKTargets
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

install(DIRECTORY include/gazepoint
    DESTINATION include
)

# Package config
install(EXPORT GazePointSDKTargets
    FILE GazePointSDKTargets.cmake
    NAMESPACE GazePoint::
    DESTINATION lib/cmake/GazePointSDK
)
