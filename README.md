# Lawang - BPS Statistik Kota Semarang

## Quick Summary
**Project Name**: Lawang (Layanan data Wilayah Semarang)  
**Type**: Hybrid Flutter mobile app + Node.js Express API  
**Purpose**: Statistics information platform for Semarang City (BPS - Indonesian Statistics Agency)  
**Architecture**: Flutter frontend with local storage + optional Node.js backend API  
**Meaning**: Lawang stands for "Layanan data Wilayah Semarang" (Semarang Regional Data Service)

## Tech Stack

### Frontend (Flutter)
- **Language**: Dart 3.0+
- **Framework**: Flutter 3.10+
- **UI**: Material Design
- **State Management**: Provider + GetX
- **Storage**: SharedPreferences (local), Hive
- **Charts**: fl_chart, syncfusion_flutter_charts
- **Networking**: http, dio
- **Video**: video_player (for splash screen animation)

### Backend (Node.js)
- **Runtime**: Node.js v25.1.0
- **Framework**: Express.js
- **Database**: MySQL + Sequelize ORM, Redis caching
- **Auth**: JWT + bcryptjs
- **Security**: Helmet, CORS, rate-limit
- **API Base**: `http://10.0.2.2:3000/api` (Android emulator)

### Platform Support
Android (min SDK 21), iOS (12+), Web, Linux, macOS, Windows

## Project Structure

```
/home/qiu/STARA_BPS_ID/           # Project root
├── lib/                          # Main application code
│   ├── *.dart                    # 47+ screen/service files
│   ├── main.dart                 # App entry point
│   ├── splash_screen.dart        # Animated splash screen
│   ├── home_screen.dart          # Main dashboard
│   └── ...                       # Admin screens, data services
├── android/                      # Android native config
│   └── app/
│       ├── build.gradle.kts      # Build config with signing
│       └── src/main/kotlin/      # MainActivity.kt
├── ios/                          # iOS native config
├── linux/                        # Linux config
├── assets/                       # Static resources
│   ├── images/                   # Logos, icons
│   ├── fonts/                    # Poppins, Montserrat
│   └── animations/               # Splash video (ringan.mp4)
├── pubspec.yaml                  # Flutter dependencies
├── analysis_options.yaml         # Dart lint rules
└── README.md                     # This file
```

## Key Application Features

### 10 Statistical Categories
1. **Penduduk** (Population) - Population statistics
2. **Pertumbuhan Ekonomi** (Economic Growth) - Economic indicators
3. **Inflasi** (Inflation) - Inflation data
4. **Pendidikan** (Education) - Education metrics
5. **Kemiskinan** (Poverty) - Poverty statistics
6. **Tenaga Kerja** (Labor Force) - Employment data
7. **IPM** (Human Development Index) - HDI metrics
8. **IPG** (Gender Development Index) - Gender equality
9. **IDG** (Gender Inequality Index) - Gender disparity
10. **SDGs** (Sustainable Development Goals) - SDG indicators

### User Roles
- **Public Users**: Browse all statistics (read-only)
- **Admin**: Manage data via admin panels (username: `admin`, password: `admin123`)

### Splash Screen
- **Animated logo** using video_player with MP4 animation
- **Audio focus handling**: Uses `mixWithOthers: true` to avoid interrupting calls/music
- **Auto-fallback**: Shows progress spinner if video fails to load
- **Timeout protection**: Maximum 8-second splash duration

## Setup Instructions

### Prerequisites
```bash
# Required
- Flutter SDK 3.10+ 
- Node.js v14+ (currently installed: v25.1.0)
- MySQL 5.7+ (for backend, if using)
- Redis (optional, for caching)
- Android Studio + Android SDK (for Android)
- Xcode (for iOS, macOS only)
```

### Quick Start

```bash
# 1. Navigate to project root
cd /home/qiu/STARA_BPS_ID

# 2. Install Flutter dependencies
flutter pub get

# 3. Install Node.js dependencies (if using backend)
cd backend  # or wherever server.js is located
npm install

# 4. Create .env file for backend (optional)
cat > .env << 'EOF'
PORT=3000
NODE_ENV=development
DB_HOST=localhost
DB_USER=your_mysql_user
DB_PASSWORD=your_mysql_password
DB_NAME=statistik_indonesia
REDIS_HOST=localhost
REDIS_PORT=6379
JWT_SECRET=your_secret_key_here
EOF

# 5. Start backend server (optional)
npm run dev

# 6. Run Flutter app (new terminal)
cd /home/qiu/STARA_BPS_ID
flutter run
```

## Release Build Guide

### Step 1: Generate Release Keystore

Create your release signing key:

```bash
cd /home/qiu/STARA_BPS_ID/android/app
keytool -genkey -v -keystore lawang-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lawang
```

When prompted:
- Enter keystore password (remember this!)
- Enter key password (can be same as keystore)
- Fill in your organization details

### Step 2: Configure Signing

Edit `/home/qiu/STARA_BPS_ID/android/app/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=lawang
storeFile=lawang-release-key.jks
```

⚠️ **IMPORTANT**: Never commit this file to Git! It's already in `.gitignore`.

### Step 3: Update Version

Edit `pubspec.yaml` before each release:

```yaml
version: 1.1.0+2  # versionName+versionCode (increment versionCode!)
```

**Rules:**
- Always increment `versionCode` (+1, +2, +3...)
- Android requires higher versionCode for updates
- Use same keystore for all releases

### Step 4: Build Release APK

```bash
cd /home/qiu/STARA_BPS_ID
flutter build apk --release
```

**Output**: `build/app/outputs/flutter-apk/app-release.apk`

### Step 5: Install/Update

**Fresh install:**
```bash
adb install build/app/outputs/flutter-apk/app-release.apk
```

**Update over existing:**
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

### Important Notes

- **Keep your keystore safe**: If you lose `lawang-release-key.jks`, you cannot update the app on Play Store
- **Same keystore for all releases**: Using different keystores breaks update capability
- **Version code must increase**: Android rejects APKs with same/lower versionCode
- **Never lose passwords**: Without them, the keystore is useless

## Critical Files Reference

### For UI Changes
| Task | Files to Check |
|------|---------------|
| Home screen | `lib/home_screen.dart`, `lib/admin_home_screen.dart` |
| Splash screen | `lib/splash_screen.dart` |
| Login/Auth | `lib/login_admin.dart` |
| Population stats | `lib/penduduk_screen.dart`, `lib/admin_penduduk_screen.dart` |
| Inflation stats | `lib/inflasi_screen.dart`, `lib/admin_inflasi_screen.dart` |
| Education stats | `lib/pendidikan_screen.dart`, `lib/admin_education_screen.dart` |
| SDGs dashboard | `lib/sdgs_screen.dart`, `lib/admin_sdgs_dashboard_screen.dart` |
| Economic growth | `lib/pertumbuhan_ekonomi_screen.dart`, `lib/admin_pertumbuhan_ekonomi_screen.dart` |

### For Data/State Management
| Task | Files to Check |
|------|---------------|
| Education data | `lib/education_data.dart`, `lib/education_service.dart` |
| SDGs data | `lib/sdgs_data_service.dart` |
| Statistics data | `lib/statistics_data.dart` |
| SharedPreferences | Check individual screen files |

### For Platform Config
| Task | Files to Check |
|------|---------------|
| Android config | `android/app/build.gradle.kts` |
| iOS config | `ios/Runner/Info.plist` |
| Signing config | `android/app/key.properties` |
| Flutter dependencies | `pubspec.yaml` |
| Gradle properties | `android/gradle.properties` |

## Data Architecture

### Storage Pattern
- **Primary**: SharedPreferences (local storage)
- **Backend**: Optional MySQL database (configured but using sample data)
- **Structure**: Year-based data (2020-2024) per category

### Data Flow
1. App initializes with default data on first run
2. Data persists in SharedPreferences
3. Admin updates through admin panels
4. Changes saved locally and reflected immediately
5. Backend API available but app works offline-first

### Key Data Models
- **EducationData**: Literacy rates, schooling years, enrollment
- **KotaData** (SDGs): City-based SDG indicators
- **IPM**: Human Development Index metrics
- Year-based structure across all categories

## Common Tasks

### Add New Statistical Category
1. Create screen file: `lib/new_category_screen.dart`
2. Create admin screen: `lib/admin_new_category_screen.dart`
3. Create data service: `lib/new_category_data.dart`
4. Add navigation from `home_screen.dart`
5. Add admin navigation from `admin_home_screen.dart`
6. Update assets in `pubspec.yaml` if needed

### Modify Chart/Visualization
- Check screen file for category (e.g., `penduduk_screen.dart`)
- Charts use `fl_chart` package
- Look for `LineChart`, `BarChart`, or `PieChart` widgets

### Update API Endpoint
1. Modify route file in backend routes folder
2. Restart backend: `npm run dev`
3. Update API service in relevant dart file

### Change Admin Credentials
- File: `lib/login_admin.dart`
- Find hardcoded check and update

### Add New Dependency
```bash
# Flutter
cd /home/qiu/STARA_BPS_ID
flutter pub add package_name

# Node.js (if using backend)
npm install package-name
```

## Build Commands

```bash
# Development
flutter run

# Android APK (debug)
flutter build apk

# Android APK (release)
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle

# iOS
flutter build ios

# Web
flutter build web

# Run tests
flutter test
```

## Dependencies Count
- **Flutter**: 37 runtime + 7 dev packages
- **Node.js**: 15 runtime + 3 dev packages (backend optional)

## Additional Notes
- App works offline-first with local storage
- Backend is optional but provides additional features
- Charts require data for years 2020-2024
- Material Design with custom fonts (Poppins, Montserrat)
- Splash screen uses MP4 video with audio focus handling
- Includes admin CRUD functionality for all categories
- Release builds require proper keystore configuration

## Troubleshooting

### App crashes on launch
- Check MainActivity.kt package matches applicationId in build.gradle.kts
- Run `flutter clean && flutter pub get`

### Video splash screen stuck
- Check `mixWithOthers: true` in splash_screen.dart
- Video will auto-fallback to spinner after 3 seconds if stuck

### Cannot update installed app
- Ensure using same keystore (`lawang-release-key.jks`)
- Ensure versionCode is higher than installed version
- Check app signing config in build.gradle.kts

### Build fails with resource errors
- Ensure all mipmap files are lowercase (`lawang.png`, not `Lawang.png`)
- Run `flutter clean` before building

---
**Lawang** - Layanan data Wilayah Semarang  
BPS Kota Semarang © 2024
