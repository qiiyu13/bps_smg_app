# AGENTS.md - Lawang (STARA_BPS_ID)

## Project Identity
Flutter offline-first statistics app for Semarang City BPS (Badan Pusat Statistik). Package name: `lawang`.

## Commands
- **Get dependencies:** `flutter pub get`
- **Analyze (lint + typecheck):** `flutter analyze` — always run this after changes; strict rules in `analysis_options.yaml`
- **Run (debug):** `flutter run`
- **Build APK (release):** `flutter build apk --release`
- **Build appbundle (Play Store):** `flutter build appbundle --release`

## Testing
- There is no test suite. The `test/` directory was removed (it contained a broken Flutter template importing `package:aespa_rnr/main.dart`).

## Architecture

### Data Pipeline (GitHub-as-Database)
```
BPS Excel files → tools/bps-data-uploader (Python/PyQt5) → GitHub repo → SharedPreferences cache → Flutter screens
```
The app works **completely offline** after initial sync. All data is fetched from GitHub on first launch then cached. Look at `lib/services/github_data_service.dart` and `lib/home_snapshot_data.dart` for the data flow.

### State Management
Simple `setState` and `SharedPreferences`. No Provider, GetX, or other state management libraries are used.

### Key Files
- `lib/main.dart` — Entry point, locks portrait orientation, defines routes, configures ImageCache
- `lib/home_screen.dart` — The largest file; hosts all 10 statistics category cards in a PageView
- `lib/profile_screen.dart` — User profile and contact info
- `lib/services/` — GitHub data sync services
- `lib/app_theme.dart` — BPS theme constants (colors, decorations, shadows, text styles)
- `lib/responsive_sizing.dart` — Shared responsive sizing utility
- `lib/number_format_utils.dart` — Number formatting used across all screens

### 10 Statistical Categories (3 groups)
- **Economic:** Pertumbuhan Ekonomi, Inflasi, Tenaga Kerja, Kemiskinan, Pengangguran
- **Social:** Penduduk, Pendidikan
- **Development:** IPM, IPG, IDG, SDGs

## Conventions
- **Offline-first:** Always use SharedPreferences for caching. Network calls are for initialization only.
- **Performance patterns:** Use `RepaintBoundary` around chart widgets and `AutomaticKeepAliveClientMixin` on PageView child screens.
- **Responsive sizing:** Use `ResponsiveSizing(context)` from `lib/responsive_sizing.dart` — never hardcode pixel sizes.
- **Number formatting:** Import from `lib/number_format_utils.dart` for all number displays.
- **BPS colors:** Import from `lib/app_theme.dart` — do NOT define private `_bps*` color constants in screen files.
- **Lint rules:** `prefer_final_locals`, `prefer_const_constructors`, `use_super_parameters`, and ~50 more — see `analysis_options.yaml`.

## Knowledge Graph
A pre-built knowledge graph exists at `graphify-out/`. Read `graphify-out/GRAPH_REPORT.md` for god nodes and community hubs before making architectural changes.

## Deployment
See `DEPLOYMENT_PLAN.md` for Google Play Store deployment steps. See `PERFORMANCE_OPTIMIZATIONS.md` for documented performance work.
