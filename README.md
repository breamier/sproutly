# Sproutly

Sproutly is a comprehensive Flutter-based mobile application designed to be the perfect companion for plant enthusiasts. Whether you're a seasoned gardener or a new plant parent, Sproutly helps you track, manage, and nurture your green friends with ease. Log their growth, set care reminders, diagnose issues, and access a handy guidebook—all in one place.

## Key Features

- **My Plant Library**: Add, view, edit, and manage your personal collection of plants. Each plant has its own detailed profile with care requirements.
- **Growth Journal**: Document your plant's journey with dated notes and photos. Track progress from a small sprout to a flourishing plant.
- **Care Reminders & Schedules**: Never miss a watering day again. Set customizable reminders for watering, rotating, and checking light or overall health, delivered via local notifications.
- **Plant Issue Tracking**: Log and monitor any issues your plant faces, such as pests or leaf discoloration, and mark them as resolved.
- **In-App Guidebook**: Access a rich database of plant information, including care tips, water and light requirements, and more, for a variety of plant types.
- **Image Management**: Take photos directly in the app or upload from your gallery to visually track plant growth or update profile pictures. Images are managed and hosted using Cloudinary.

## Tech Stack

- **Framework**: Flutter
- **Database**: Cloud Firestore
- **Authentication**: Firebase Authentication
- **Image Management**: Cloudinary
- **State Management**: Provider
- **Local Notifications**: `flutter_local_notifications`

## Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- Flutter SDK installed on your machine.
- A configured Firebase project.
- A Cloudinary account for image hosting.

### Installation

1.  **Clone the repository**

    ```sh
    git clone https://github.com/breamier/sproutly.git
    cd sproutly
    ```

2.  **Configure Firebase**
    This project is integrated with Firebase. You will need to set up your own Firebase project and connect it to the app. The easiest way is using the FlutterFire CLI:

    ```sh
    flutterfire configure
    ```

    This will generate the necessary configuration files, including `lib/firebase_options.dart`.

3.  **Configure Cloudinary**
    Sproutly uses Cloudinary for image hosting. Create a `.env` file in the root of the project with your credentials:

    ```
    CLOUDINARY_CLOUD_NAME=your_cloud_name
    CLOUDINARY_API_KEY=your_api_key
    CLOUDINARY_API_SECRET=your_api_secret
    ```

4.  **Install Dependencies**

    ```sh
    flutter pub get
    ```

5.  **Run the Application**
    ```sh
    flutter run
    ```

## Project Structure

The project is structured to separate concerns, making it easier to navigate and maintain.

- `lib/models/`: Contains the data models for the application, such as `Plant`, `Reminder`, and `PlantJournalEntry`.
- `lib/screens/`: Holds all the UI screens, organized into subdirectories by feature (e.g., `dashboard`, `user_plant_library`, `growth_journal`).
- `lib/services/`: Includes services that handle backend communication and business logic, like `database_service.dart` for Firestore operations and `notification_service.dart`.
- `lib/cloudinary/`: Contains the helper functions for picking, uploading, and deleting images with Cloudinary.
- `lib/widgets/`: Stores reusable UI components, such as the custom navigation bar `navbar.dart`.
