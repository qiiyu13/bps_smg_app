# Lawang - BPS Statistik Kota Semarang

## Quick Summary
**Project Name**: Lawang (Layanan data Wilayah Semarang)  
**Type**: Flutter mobile app (offline-first)  
**Purpose**: Statistics information platform for Semarang City (BPS - Indonesian Statistics Agency)  
**Architecture**: Flutter mobile app with local storage - works completely offline  

## Tech Stack

### Flutter
- Dart 3.0+, Flutter 3.10+
- Material Design
- SharedPreferences for local storage
- fl_chart for data visualization
- video_player for splash screen animation

### Platform Support
Android (min SDK 21), iOS (12+), Web, Linux, macOS, Windows

## 10 Statistical Categories

| Group | Categories |
|-------|-----------|
| **Economic** | Pertumbuhan Ekonomi, Inflasi, Tenaga Kerja, Kemiskinan, Pengangguran |
| **Social** | Penduduk, Pendidikan |
| **Development** | IPM, IPG, IDG, SDGs |

## Data Architecture

Data flows through a GitHub-as-database pipeline:
```
BPS Excel files → tools/bps-data-uploader (Python) → GitHub repo → SharedPreferences cache → Flutter screens
```
The app works completely offline after initial sync. All data is fetched from GitHub on first launch then cached.

## Setup

```bash
flutter pub get
flutter run
```

## Build Commands

```bash
# Development
flutter run

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle --release

# Lint & typecheck
flutter analyze
```

## Release Build Guide

### Generate Keystore
```bash
cd android/app
keytool -genkey -v -keystore lawang-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias lawang
```

### Signing Config
Create `android/app/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=lawang
storeFile=lawang-release-key.jks
```

### Build Release
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Key Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | Entry point, routes, ImageCache config |
| `lib/home_screen.dart` | Main dashboard with 10+ category cards and PageView snapshots |
| `lib/splash_screen.dart` | Video splash with fallback |
| `lib/profile_screen.dart` | User profile and contact info |
| `lib/services/github_data_service.dart` | GitHub data sync service |
| `lib/home_snapshot_data.dart` | Snapshot card data loading |
| `lib/app_theme.dart` | BPS color palette, decorations, shadows |
| `lib/responsive_sizing.dart` | Responsive sizing across screen widths |
| `lib/number_format_utils.dart` | Number formatting utilities |

## Performance Features

- ImageCache limits (50 images, 16MB)
- SharedPreferences singleton cache
- Image pre-caching during splash screen
- RepaintBoundary on chart widgets
- AutomaticKeepAliveClientMixin on PageView child screens
- ProGuard minification for release builds
- Compressed assets (PNG at mobile resolution)

---

**Lawang** - Layanan data Wilayah Semarang  
BPS Kota Semarang © 2026
