# ParkSure - A Smart Parking System

## About the Project

ParkSure is a mobile application designed to simplify parking management by leveraging real-time data and advanced technology. The app allows users to search, reserve, and pay for parking spots seamlessly.

## Modules Overview

- **User Authentication**: Manages user sign-up and login functionalities using Firebase Authentication.
- **Parking Spot Discovery**: Utilizes Google Maps API to display available parking spots relative to the user's location.
- **Booking Management**: Handles the reservation process, allowing users to select and book available spots.
- **Payment Processing**: Integrates with RazorPay API to facilitate secure online payments.
- **Notifications**: Employs Twilio API to send SMS confirmations and updates to users.
- **User Dashboard**: Provides an interface for users to view and manage their bookings and account settings.

## Tools and Technologies

- **Frontend**: Flutter
- **Backend**: Firebase Firestore

### APIs Used:

- Google Maps API
- RazorPay API
- Twilio API

## Project Progress

We have implemented the following features so far:

- **User Authentication**: Users can register themselves.
- **User Dashboard**: Users can add their vehicles
- **Real-Time Parking Spot Discovery**: Users can find nearby parking spots based on their current location.
- **Search Functionality**: Ability to search for parking spots in any specified region.


## Execution Instructions

### Prerequisites

Ensure you have Flutter installed on your machine. You can download it from Flutter's official website.

### Steps to Run the Project

1. **Install Dependencies**
    ```sh
    flutter pub get
    ```

2. **Configure Firebase**
    - Set up a Firebase project at [Firebase Console](https://console.firebase.google.com/).
    - Enable Authentication and Firestore Database.
    - Download the `google-services.json` file and place it in the `android/app` directory.
    - Download the `GoogleService-Info.plist` file and place it in the `ios/Runner` directory.

4. **Set Up APIs**
    - **Google Maps API**: Obtain an API key from the [Google Cloud Console](https://console.cloud.google.com/) and enable the Maps SDK for both Android and iOS.

5. **Add API Keys to the Project**
    - For Google Maps, add your API key in the `AndroidManifest.xml` and `AppDelegate.swift` files for Android and iOS, respectively.

6. **Run the Application**
    Connect your device or start an emulator, then execute:
    ```sh
    flutter run
    ```
