# Firebase Flutter App Setup

This Flutter project has been configured with Firebase integration including Authentication, Firestore Database, and Firebase Storage.

## 🏗️ Project Structure

```
lib/
├── auth/
│   └── auth_wrapper.dart          # Handles authentication state
├── home/                          # Home-related components (placeholder)
├── models/
│   └── user_model.dart           # User data model
├── services/
│   ├── auth_service.dart         # Firebase Authentication service
│   ├── firestore_service.dart    # Firestore database service
│   └── storage_service.dart      # Firebase Storage service
├── pages/
│   ├── splash_page.dart          # Loading/splash screen
│   ├── login_page.dart           # Login interface
│   ├── home_page.dart            # Main home page
│   └── profile_page.dart         # User profile page
└── main.dart                     # App entry point with Firebase initialization
```

## 🔥 Firebase Services Included

### 1. Authentication Service (`lib/services/auth_service.dart`)
- Email/password authentication
- User registration and login
- Password reset functionality
- Authentication state management

### 2. Firestore Service (`lib/services/firestore_service.dart`)
- CRUD operations for Firestore documents
- Real-time data streaming
- Collection and document management

### 3. Storage Service (`lib/services/storage_service.dart`)
- File upload to Firebase Storage
- File download URL generation
- File deletion and metadata management

## 🚀 Getting Started

### Prerequisites
- Flutter SDK
- Firebase project created at [Firebase Console](https://console.firebase.google.com/)

### Firebase Setup Steps

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Enable Authentication, Firestore, and Storage

2. **Add Firebase to Your Flutter App**
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools
   
   # Login to Firebase
   firebase login
   
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure Firebase for your app
   flutterfire configure
   ```

3. **Enable Authentication**
   - In Firebase Console, go to Authentication > Sign-in method
   - Enable "Email/Password" provider

4. **Set up Firestore**
   - In Firebase Console, go to Firestore Database
   - Create database in test mode (change rules later for production)

5. **Set up Storage**
   - In Firebase Console, go to Storage
   - Get started with default rules

### Running the App

```bash
# Get dependencies
flutter pub get

# Run the app
flutter run
```

## 📱 App Flow

1. **Splash Page** - Shows while checking authentication state
2. **Login Page** - Displayed when user is not authenticated
3. **Home Page** - Main app interface for authenticated users
4. **Profile Page** - User profile management

## 🔒 Authentication Flow

The app uses `AuthWrapper` to manage authentication state:
- Listens to Firebase Auth state changes
- Automatically redirects users based on authentication status
- Shows appropriate pages (Login vs Home)

### Login/Signup Features
- **Unified Interface**: Single page handles both login and signup
- **Email/Password Authentication**: Secure Firebase Authentication
- **Form Validation**: Email format and password length validation
- **Error Handling**: User-friendly error messages
- **Guest Access**: Option to continue without account
- **Loading States**: Visual feedback during authentication

### User Preferences Flow
- **First-time Setup**: New users are guided through preferences
- **Permission Requests**: Location and camera access
- **Language Selection**: Korean, English, Chinese support
- **Currency Selection**: USD, KRW, CNY options
- **Firestore Storage**: All preferences saved to user profile

## 📊 Navigation Routes

- `/splash` - Splash/loading page
- `/login` - Login page
- `/home` - Home page
- `/profile` - Profile page

## 🎨 UI Components

All pages currently show placeholder content with:
- Relevant icons
- Page titles
- Descriptive text
- Basic navigation between pages

## 🔧 Next Steps

1. ✅ Implement actual login/registration forms
2. ✅ Add real data models and Firestore collections
3. ✅ Create proper UI components and styling
4. ✅ Add error handling and validation
5. ✅ Implement file upload functionality
6. ✅ Add user profile management
7. Set up proper Firebase security rules
8. ✅ Add proper logout functionality with AuthService
9. Implement user profile editing
10. ✅ Add more language and currency options
11. ✅ Implement camera and photo functionality
12. ✅ Add location-based item search
13. ✅ Create currency conversion system
14. ✅ Build item submission system

## 📚 Dependencies

- `firebase_core`: ^3.6.0
- `firebase_auth`: ^5.3.1
- `cloud_firestore`: ^5.4.3
- `firebase_storage`: ^12.3.2
- `permission_handler`: ^11.3.1

## 🛡️ Security Notes

- Current setup uses default Firebase rules (test mode)
- Remember to configure proper security rules before production
- Implement proper error handling for production use
- Add input validation for forms
