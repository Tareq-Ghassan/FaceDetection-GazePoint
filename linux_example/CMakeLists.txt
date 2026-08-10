cmake_minimum_required(VERSION 3.16)
project(GazePointExample VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required packages
find_package(OpenCV REQUIRED)

# Include GazePoint SDK
include_directories(${CMAKE_SOURCE_DIR}/../linux/include)

# Add executable
add_executable(gazepoint_example main.cpp)

# Link libraries
target_link_libraries(gazepoint_example
    PRIVATE
    ${OpenCV_LIBS}
    pthread
)

# Set output directory
set_target_properties(gazepoint_example
    PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# Install target
install(TARGETS gazepoint_example
    RUNTIME DESTINATION bin
)

# Print configuration
message(STATUS "GazePoint Example Configuration:")
message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  OpenCV Version: ${OpenCV_VERSION}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
