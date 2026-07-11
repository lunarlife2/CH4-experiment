# Ran Up
Ran Up is a health and safety running companion for Apple Watch that tracks heart rate (BPM) and monitors the user's target heart rate zone in real time. The app delivers instant haptic and audio feedback whenever runners move outside their selected zone, helping them maintain safe and effective training intensity without interrupting their run.

## App Background
Many runners find it difficult to maintain the correct training intensity without constantly checking their heart rate. This can reduce workout effectiveness and increase the risk of overexertion. Ran Up addresses this challenge by providing real-time heart rate zone guidance directly on Apple Watch through haptic and audio feedback.

## Tech Stack
1. Swift : Used as the main programming language to build the iOS and WatchOS application.
2. SwiftUI : Used to create the app’s user interface, including the spending list, add expense form, and budget overview screen.
3. Xcode : Used as the main development environment for writing code, designing the app, testing, and running the project on iOS Simulator or device.
4. Figma : Used for designing the app flow, wireframe, and visual interface before implementing it in code.
5. HealthKit : Streaming real-time heart rate metrics (BPM) directly from the Apple Watch sensors.
6. WatchConnectivity: Two way communication between iOS and watchOS apps
7. Watch Kit : Drives the core application lifecycle, UI layout transitions, and coordinates active background workout sessions on watchOS. Also delivers distinct, localized haptic patterns to notify the runner the exact moment they drift outside their target threshold, enabling screen-free adjustments.

## Accessibility
* Differentiate Without Color Alone:
Critical training states do not rely on color alone; color shifts (green/red) are paired with explicit text labels and unique heart shapes. On the Activity Log, data metrics are distinguished by specialized iconography—using a dedicated map-pin icon for distance and a stopwatch icon for pace, ensuring full readability for colorblind users.

* Sufficient Contrast:
To support outdoor readability under direct sunlight or night runs, the app features a high-contrast dark mode. Vital metrics, like large numerical values for BPM and pace, are rendered in crisp white and vivid orange text against a solid pure black background, ensuring the screen remains easily glanceable while in rapid motion.

## Team Members
We are HLTeam, a passionate group of innovators dedicated to creating meaningful health and wellness solutions.
1. Averina Harseno Subianto - PM (Project Manager): Leads project planning, coordination, and execution.
2. Ni Komang Ayu Juliana - Developer: Develops the iOS application and manages its integration with watchOS
3. Yimei Winata - Developer: Develops the watchOS application and ensures seamless communication with iOS.
4. Grace Michelle - UI/UX Designer: Designs intuitive and engaging user experiences for the iOS app.
5. Hilli Kamilia Putri Saba - UI/UX Designer: Creates user-friendly and optimized interfaces for the watchOS app.

# The Tech Report Link
https://docs.zoom.us/doc/rLLb5QSJTPaqzRAK-1qcJA

# Design Guideline Link
https://www.figma.com/design/hEXR54Vl7bvOOQiDY3LrGP/CH4?node-id=193-5649
