# Aegis Docs: Secure Document Wallet

Aegis Docs is a privacy-focused mobile application built with Flutter that provides a secure, encrypted wallet for storing and managing sensitive documents. The app offers a suite of powerful tools for processing images and PDFs, ensuring that all user data remains private and under their control.

## Features

- **Secure, Encrypted Wallet:** All documents are encrypted on-device using AES-256 encryption.
- **Local Authentication:** The wallet is protected by the user's device biometrics (fingerprint/face ID).
- **Folder Organization:** Users can create a nested folder structure to organize their documents within the secure wallet.
- **Document Processing Tools:**
    - **Image Tools:** Resize, compress, crop, edit (grayscale filter), and change image formats (JPG, PNG, GIF, etc.).
    - **PDF Tools:** Convert multiple images to a single PDF, extract pages from a PDF to images, and apply password protection (lock/unlock/change password).
    - **Native PDF Compression:** High-performance PDF compression powered by a native MuPDF implementation.
- **Secure Export & Share:** Decrypt and export documents to the device or share them with other apps through the native OS share sheet.
- **Secure Cloud Sync:** End-to-end encrypted backup and restore functionality using the user's private Google Drive App Data Folder. The user's master password is required to decrypt the backup, ensuring data remains private even in the cloud.

## Architecture

The application is built using a clean, feature-first architecture that follows the **MVVM (Model-View-ViewModel)** pattern.

- **State Management:** **Riverpod** (with code generation) is used for state management, providing a clear separation between UI and business logic.
- **Navigation:** **GoRouter** is used for declarative, type-safe routing.
- **Dependency Injection:** Riverpod is used for injecting dependencies throughout the app.
- **Asynchronous Operations:** Heavy tasks like image processing, encryption, and zipping are performed in background **isolates** to keep the UI smooth and responsive.

## Project Structure

The project is organized by feature, with a clear separation between the UI (`view`), state management (`providers`), and the core business logic.

lib/

app/          # App-level config (routing, theme)

core/         # Core business logic (services, processors)

data/         # Data models and repositories

features/     # Individual app features (home, auth, settings, etc.)

shared_widgets/ # Reusable UI components
## Getting Started

1.  **Firebase Setup:** This project uses Firebase for Google Sign-In. Follow the `flutterfire configure` steps and add the `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files.
2.  **Google Cloud:** Enable the **Google Drive API** in your Google Cloud project and create an **OAuth 2.0 Web Client ID**.
3.  **Dependencies:** Run `flutter pub get` to install all necessary packages.
4.  **Code Generation:** Run `flutter pub run build_runner build` to generate the necessary files for Riverpod and GoRouter.
