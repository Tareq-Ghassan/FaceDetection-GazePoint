# Face Detection and Gaze Point Calculation

This project aims to detect faces and calculate Gaze Points.

# Before You Start: What is a Gaze Point?

Gaze points are the fundamental units of measurement utilized in eye tracking research.
Each gaze point represents an individual record of a participant's gaze at a specific moment.
The number of these individual moments per second depends on the sampling rate of the eye tracking device.
<img src="https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/assets/67103763/57a5b78c-5f7c-4e56-8200-eda9ce83f79b" alt="What is a Gaze Point image " height="250"/>

# How It Works:

I employed CameraX to initiate a camera preview. Additionally,
I utilized ML-kit for detecting faces and their landmarks.
The process begins immediately with face detection. When a face is detected,
the system attempts to obtain eye landmarks for both eyes. If these landmarks are available,
it proceeds to calculate the gaze point.

# Use Cases:

1. Best-case scenario: When it successfully detects a face and both eyes.
<img src="https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/assets/67103763/f8e2a1e5-157d-4619-b3b9-517b2f72dcee" alt="What is a Gaze Point image " height="250"/>

2. When no face is detected.
<img src="https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/assets/67103763/dff2b8b9-f1d5-43cd-baf7-83c73051acdc" alt="What is a Gaze Point image " height="250"/>


3. When a face is detected, but the landmarks for the eyes are not clear.
<img src="https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/assets/67103763/90b7545c-fefb-4198-8aba-ae7702fb1d07" alt="What is a Gaze Point image " height="250"/>


4. When there is more than one face detected.
<img src="https://github.com/Tareq-Ghassan/FaceDetection-GazePoint/assets/67103763/0bf69c13-75cf-42d6-9b0a-202d2f9d966b" alt="What is a Gaze Point image " height="250"/>


# Sample Video:
https://drive.google.com/file/d/1gXo4yceQTww4hI5zgYV7oBvWIEw0lSWn/view?usp=sharing

# Contact Me:
If you have any questions, feedback, or inquiries, please don't hesitate to get in touch with me. I'm here to assist you!

Linkedin: www.linkedin.com/in/tareq-abu-saleh-3b5374203

Feel free to use the contact details provided above, and I'll respond as soon as possible. Your input is valuable to me, and I look forward to hearing from you.
