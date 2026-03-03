 CipherTask

Secure Encrypted To-Do App (Flutter + MVVM)

CipherTask is a secure task management app built using Flutter and the MVVM architecture.
It focuses on protecting user data using encryption, biometric authentication, and secure key storage.

 Features

 Encrypted local database (SQLCipher or Encrypted Hive)

 AES-256 encryption for sensitive notes

 Secure key storage (Android Keystore / iOS Keychain)

 Fingerprint / Face ID login

 Auto-lock after 2 minutes of inactivity

 Strict MVVM structure

 Project Structure (MVVM)

 lib/
├── main.dart                  # Entry point (Dependency Injection & Routes)
├── models/                    # Data Layer (POJOs)
│   ├── todo_model.dart        # Task data structure
│   └── user_model.dart        # User profile
├── views/                     # UI Layer (Screens & Widgets ONLY)
│   ├── login_view.dart        # Biometric & Password Login
│   ├── register_view.dart     # Registration with MFA option
│   ├── todo_list_view.dart    # Main Secure Task List
│   └── widgets/               # Reusable secure input fields
├── viewmodels/                # Logic Layer (State Management)
│   ├── auth_viewmodel.dart    # Login, Bio-Auth, Auto-Logout logic
│   └── todo_viewmodel.dart    # CRUD operations with encryption logic
├── services/                  # Data & Security Services
│   ├── encryption_service.dart# AES-256 Encryption/Decryption logic
│   ├── database_service.dart  # SQLCipher or Encrypted Hive Box
│   ├── key_storage_service.dart # FlutterSecureStorage wrapper
│   └── session_service.dart   # Inactivity Timer logic
└── utils/                     # Helpers
    └── constants.dart         # Configs (Timeouts, API Keys)


Flow:

View → ViewModel → Service → Database

Views do NOT directly access the database.


Security Implementation
Encrypted Database

The entire database file is encrypted.

The database key:

Is generated on first launch

Stored using flutter_secure_storage

Never hardcoded

If someone extracts the database file, the contents are unreadable.


