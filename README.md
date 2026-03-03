CipherTask
Secure Encrypted To-Do Application
(Flutter + MVVM Architecture)

CipherTask is a secure task management mobile application developed using Flutter and the Model–View–ViewModel (MVVM) architectural pattern. The application is designed with a strong emphasis on data confidentiality, integrity, and secure user authentication.

The system implements industry-standard encryption mechanisms, biometric authentication, and secure key management to protect sensitive user data stored locally on the device.

Project Objectives

The primary objective of CipherTask is to demonstrate secure mobile data storage and secure authentication practices by:

• Encrypting all stored task data
• Securing cryptographic keys using platform-protected storage
• Enforcing biometric authentication
• Preventing unauthorized access through automatic session control

Core Features

Encrypted Local Database
The application uses either SQLCipher or Encrypted Hive to ensure that the entire local database file is encrypted at rest.

AES-256 Encryption
Sensitive task notes are encrypted using AES-256 encryption before being stored in the database.

Secure Key Storage
Encryption keys are stored using secure platform services:
• Android Keystore (Android devices)
• iOS Keychain (iOS devices)
Access is handled via flutter_secure_storage.

Biometric Authentication
Users can authenticate using:
• Fingerprint
• Face ID

Automatic Session Lock
The application automatically locks after two (2) minutes of inactivity to prevent unauthorized access.

Strict MVVM Architecture
The application strictly enforces separation of concerns using the MVVM pattern.

Project Structure (MVVM)

lib/

main.dart
Entry point of the application. Handles dependency injection and route configuration.

models/ (Data Layer – Plain Data Models)
• todo_model.dart – Defines the task entity structure
• user_model.dart – Defines user profile data

views/ (User Interface Layer – UI Only)
• login_view.dart – Biometric and password authentication interface
• register_view.dart – User registration with optional multi-factor authentication
• todo_list_view.dart – Main secure task dashboard
• widgets/ – Reusable secure input and UI components

viewmodels/ (Business Logic Layer – State Management)
• auth_viewmodel.dart – Handles login, biometric authentication, and auto-logout logic
• todo_viewmodel.dart – Handles encrypted CRUD operations for tasks

services/ (Security and Data Access Layer)
• encryption_service.dart – AES-256 encryption and decryption logic
• database_service.dart – SQLCipher or Encrypted Hive implementation
• key_storage_service.dart – Wrapper for secure key storage
• session_service.dart – Inactivity timeout management

utils/
• constants.dart – Configuration values (timeouts, security parameters)

Application Flow

The system strictly follows the MVVM communication pattern:

View → ViewModel → Service → Database

Views do not directly interact with the database or encryption mechanisms. All data processing, encryption, and security logic are handled within the ViewModel and Service layers.

Security Implementation

Encrypted Database

The entire local database file is encrypted using SQLCipher or Encrypted Hive.

Database Key Management

• The encryption key is generated securely during the first application launch.
• The key is stored using flutter_secure_storage.
• The key is never hardcoded in the source code.
• The key is protected by platform-level secure storage mechanisms.

Security Assurance

If an attacker extracts the database file from the device storage, the contents remain unreadable without access to the securely stored encryption key.

Conclusion

CipherTask demonstrates secure mobile application development practices by integrating encryption at rest, secure key management, biometric authentication, and strict architectural separation using MVVM. The application serves as a practical implementation of mobile data protection principles and secure session management.
