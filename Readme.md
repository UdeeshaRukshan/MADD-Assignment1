# SE4020 - Assignment 01 - Part A

---

## Project Name - StaySafe: Community Crime Alert & Safety App

## Student Id - IT20124138



## Student Name - Gamage U.R


---

## 01. Brief Description of Project

StaySafe is a modern, cross-platform mobile application designed to empower citizens to report, monitor, and respond to criminal activities in their communities. The app provides real-time crime mapping, emergency SOS features, live CCTV feeds, chat with authorities and neighbors, and a personal health dashboard for emergencies. It leverages advanced integrations such as Firebase, HealthKit, CoreML, and SiriKit to deliver a comprehensive safety experience.

---

## 02. Users of the System

- **General Public / Citizens:** Report crimes, receive alerts, and access safety resources.
- **Law Enforcement / Admins:** Monitor reports, communicate with citizens, and manage alerts.
- **Community Watch Groups:** Collaborate and share information about local safety.

---

## 03. What is Unique About Your Solution

- **Multi-Window iPad Support:** Users can open multiple screens (e.g., map, chat, CCTV) simultaneously.
- **Integrated HealthKit:** Heart rate and step data are used as evidence during emergencies.
- **Live CCTV Monitoring:** View and analyze live or recorded camera feeds with suspicious activity detection.((Only used CoreML not models integrated))
- **Real-Time Chat:** Secure, public and private messaging with neighbors and authorities.
- **Modern UI/UX:** Consistent dark theme, gradients, and custom components for a professional look.
- **SiriKit Integration:** Voice-activated emergency reporting and quick actions.
- **Advanced Notification System:** In-app and system notifications for critical events.

---

## 04. New Features Compared to Assignment 01

- **Health Dashboard:** View and share heart rate and step data during emergencies.
- **Multi-Window Support:** Open different app sections in separate windows on iPad.
- **CCTV Feed Analysis:** CoreML-powered suspicious activity detection in camera feeds.
- **Enhanced Chat:** Public channels, private messages, and alert tagging.
- **SOS Overlay:** Improved emergency workflow with PIN cancel, evidence recording, and health data.
- **Profile Badges & Recent Activity:** Gamification and transparency for user engagement.
- **Admin Mode (visionOS):** Specialized admin dashboard for immersive monitoring.

---

## 05. Platform Specific Features

- **iPad Multi-Window:** Open multiple app scenes using UISceneDelegate and custom window management.
- **HealthKit (iOS):** Access and display heart rate and step count.
- **SiriKit:** Voice commands for emergency actions.
- **CoreML (iOS):** On-device suspicious activity detection in CCTV feeds.(Only used CoreML not models integrated)
- **Push Notifications:** System and in-app notifications using UserNotifications framework.
- **Apple Pencil Support:** Sketch crime scenes on iPad.

---

## 06. Advanced Library Integrations

- **Firebase:** Firestore for real-time data, Authentication, Cloud Messaging.
- **HealthKit:** For heart rate and step data.
- **CoreML & Vision:** For live video analysis.
- **SiriKit:** For voice-activated features.
- **MapKit:** For crime mapping and location selection.
- **AVFoundation:** For audio/video evidence recording.
- **SwiftUI:** For all UI, including custom modifiers and previews.

---

## 07. Functionality of Screens (with Screenshots)

> _Note: Screenshots are referenced by filename. Please see the `/screenshots` folder for images._

### **Screen 1: Initial Screen**
- Animated splash with logo and loading indicator.
- Navigates to main content after animation.
- ![Initial Screen](screenshots/initial_screen.png)

### **Screen 2: Main Tab View**
- Tab bar for Crime Map, Chat, CCTV, and Profile.
- Floating SOS button for emergencies.
- ![Main Tab](screenshots/main_tab.png)

### **Screen 3: Crime Map & Reporting**
- View recent, nearby, and priority crimes on a map and list.
- Search/filter crimes.
- Report a new crime with location, details, and sketch.
- ![Crime Map](screenshots/crime_map.png)

### **Screen 4: Crime Detail**
- Detailed view of a crime, locations, evidence, and actions.
- Multi-window support for iPad.
- ![Crime Detail](screenshots/crime_detail.png)

### **Screen 5: Add Crime Form**
- Form for reporting a crime with title, description, category, severity, location, and sketch.
- ![Add Crime](screenshots/add_crime.png)

### **Screen 6: CCTV Monitoring**
- Grid of cameras, live feed preview, and suspicious activity detection.
- ![CCTV List](screenshots/cctv_list.png)

### **Screen 7: Chat**
- Public and private conversations, search, and alert tagging.
- ![Chat List](screenshots/chat_list.png)

### **Screen 8: SOS Overlay**
- Emergency countdown, PIN cancel, evidence recording, and health data display.
- ![SOS Overlay](screenshots/sos_overlay.png)

### **Screen 9: Profile & Health Dashboard**
- View and edit profile, badges, recent activity, and health data (heart rate, steps).
- ![Profile](screenshots/profile.png)
- ![Health Dashboard](screenshots/health_dashboard.png)

---

## 08. Best Practices Used in Code

- **Consistent Naming:** All variables, functions, and types use camelCase and descriptive names.
- **Structs & Constants:** Data models use `struct`, and constants are used for keys and identifiers.
- **MVVM Architecture:** Separation of concerns with ViewModels for business logic.
- **SwiftUI Previews:** All views have previews for rapid UI iteration.
- **Error Handling:** All async operations handle errors gracefully and provide user feedback.
- **Reusable Components:** Custom views (e.g., `StatCard`, `SectionContainer`, `SOSActionRow`) are modular.
- **Accessibility:** Large tap targets, color contrast, and dynamic text where possible.
- **Example:**
    ```swift
    struct Badge: Identifiable {
        let id = UUID()
        let name: String
        let icon: String
        let color: Color
    }
    ```
- **Comments & Documentation:** Key methods and complex logic are commented for clarity.

---

## 09. UI Components Used

- `TabView`, `NavigationStack`, `NavigationLink`
- `Map`, `MapAnnotation`
- `Button`, `TextField`, `SecureField`, `Slider`, `Toggle`, `Picker`
- `List`, `ScrollView`, `LazyVStack`, `LazyVGrid`
- `Sheet`, `Alert`, `ProgressView`
- `Image`, `VideoPlayer`, `WKWebView`
- Custom SwiftUI shapes and modifiers

---

## 10. Testing Carried Out

- **Unit Tests:** Implemented for `CrimeViewModel`, `SOSViewModel`, and data models.
- **Example:**
    ```swift
    @Test func testAddCrime() throws {
        let viewModel = CrimeViewModel()
        let crime = CriminalActivity(...)
        viewModel.addCrime(crime)
        #expect(viewModel.criminalActivities.contains(where: { $0.title == crime.title }))
    }
    ```
- **Manual Testing:** All screens tested on iPhone and iPad simulators for UI/UX and feature correctness.

---

## 11. Documentation

### (a) Design Choices

- **MVVM Pattern:** For clear separation of UI and logic.
- **Dark Theme:** For modern look and better night usability.
- **Modular Components:** For reusability and maintainability.

### (b) Implementation Decisions

- **Firebase for Real-Time Data:** Chosen for scalability and ease of integration.
- **HealthKit & CoreML:** To leverage device capabilities for user safety.
- **SwiftUI:** For rapid UI development and cross-platform support.

### (c) Challenges

- Handling multi-window state and scene management on iPad.
- Ensuring HealthKit and CoreML permissions and error handling.
- Making the UI responsive and accessible across devices.

---

## 12. Reflection

**Challenges Faced:**
- Integrating multiple advanced frameworks (Firebase, HealthKit, CoreML) and managing permissions.
- Debugging multi-window support and scene transitions on iPad.
- Ensuring smooth user experience with real-time data and notifications.

**What I Would Do Differently:**
- Start with a more detailed UI/UX wireframe to streamline development.
- Modularize feature-specific code even further for easier testing.
- Invest more time in automated UI tests for critical flows.

---

