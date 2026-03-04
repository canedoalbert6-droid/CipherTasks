CipherTask

A secure encrypted task management mobile application built using Flutter, implementing strict MVVM architecture, encrypted local storage, biometric authentication, and hardware-backed key management.

Features

AES-256 Encryption for sensitive task notes

Encrypted Local Database (SQLCipher / Encrypted Hive)

Biometric Authentication (Fingerprint / Face ID)

Automatic Session Timeout (2 minutes inactivity)

Hardware-Backed Key Storage (flutter_secure_storage)

Secure Key Generation (No hardcoded secrets)

Strict MVVM Architecture

HTTPS Network Communication

Optional OTP (MFA) Support

Architecture

This project strictly follows:

MVVM (Model–View–ViewModel)

Provider for State Management

Service-based security abstraction

Separation of Concerns (UI, Logic, Data)


Project Structure

lib/
├── main.dart
├── models/
│   ├── todo_model.dart
│   └── user_model.dart
├── views/
│   ├── login_view.dart
│   ├── register_view.dart
│   ├── todo_list_view.dart
│   └── widgets/
├── viewmodels/
│   ├── auth_viewmodel.dart
│   └── todo_viewmodel.dart
├── services/
│   ├── encryption_service.dart
│   ├── database_service.dart
│   ├── key_storage_service.dart
│   └── session_service.dart
└── utils/
    └── constants.dart


    Security Features

Database file fully encrypted

AES-256 encryption for sensitive fields

Encryption keys generated at runtime

Keys stored in Android Keystore / iOS Keychain

2-minute inactivity auto-lock

Biometric login enabled only after password authentication

No hardcoded secrets

HTTPS enforced for network calls

Scenario

CipherTask is designed for high-profile executives where:

Extracted database files must remain unreadable

Encryption keys must never exist in plain text

App must auto-lock after inactivity

Biometrics provide secure but convenient access

This follows a Trust No One security model.

| Name | Role                                   |
| ---- | -------------------------------------- |
| Albert Jhun Cañedo | Lead Architect & Database Engineer     |
| Jian Carpio   | Security & Cryptography Lead           |
| David Manayatay   | Authentication & Biometrics Specialist |
| Christian Jay Capuyan   | Backend & Network Engineer             |
| Alyysa Monzon   | UI/UX & Integration Specialist         |

Technologies Used

Flutter

Provider

sqflite_sqlcipher / Hive

encrypt (AES-256)

flutter_secure_storage

local_auth

Firebase Auth (optional)

Technical Requirements Implemented
Database Encryption

Encrypted database file using secure key stored in hardware-backed storage.

AES-256 Field Encryption

Sensitive task notes encrypted before database insertion.

Auto-Logout

2-minute inactivity timer forces reauthentication.

Biometric Authentication

Fingerprint / Face ID supported after initial password login.
