# Add 2025 Statistical Data Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add 2025 data across all 10 statistical categories in the Lawang app for both new installations and existing users.

**Architecture:** Update default data in source files for new users, create migration service to add 2025 data to existing SharedPreferences installations, update hardcoded references in home screen charts.

**Tech Stack:** Flutter, Dart, SharedPreferences, JSON

---

## Data Categories Summary

The app contains 10 statistical categories with data stored in different patterns:

| Category | Files to Update | Storage Key | Data Range |
|----------|----------------|-------------|------------|
| **Penduduk** | penduduk_screen.dart, admin_penduduk_screen.dart | `penduduk_data`, `age_distribution_data`, `district_density_data` | 2020-2024 |
| **IPM** | ipm_screen.dart, admin_ipm_screen.dart | `ipm_data`, `ipm_komponen_data` | 2020-2024 |
| **Inflasi** | inflasi_screen.dart, admin_inflasi_screen.dart | Hardcoded monthly data | 2019-2024 |
| **Kemiskinan** | kemiskinana_screen.dart, admin_kemiskinan_screen.dart | `kemiskinan_data` | 2020-2024 |
| **Tenaga Kerja** | tenaga_kerja_screen.dart, admin_tenaga_kerja_screen.dart | `tenaga_kerja_*_data` | 2020-2024 |
| **Pendidikan** | pendidikan_screen.dart, education_service.dart, admin_education_screen.dart | `education_data` | 2022-2024 |
| **IPG** | ipg_screen.dart | Hardcoded | 2020-2024 |
| **IDG** | idg_screen.dart, admin_idg_screen.dart | `idg_data` | 2020-2024 |
| **Pertumbuhan Ekonomi** | pertumbuhan_ekonomi_screen.dart, admin_pertumbuhan_ekonomi_screen.dart | `ekonomi_data` | 2020-2024 |
| **SDGs** | sdgs_screen.dart, sdgs_data_service.dart, admin_sdgs_dashboard_screen.dart | `sdgs_kota_data_v2` | 2019-2024 for 35 cities |

---

## Approach Options

### Option 1: Update Source Code Only (Recommended for New Installs)
- **Pros:** Clean, simple, all new users get 2025 data immediately
- **Cons:** Existing users won't see new data until they clear app data
- **Best for:** Initial development, new app installations

### Option 2: Admin Panel Entry (Recommended for Production)
- **Pros:** No code changes, data persists immediately
- **Cons:** Manual entry for each category, tedious
- **Best for:** Production apps with existing user base

### Option 3: Migration Service (Recommended for This Implementation)
- **Pros:** Updates both new and existing installations automatically
- **Cons:** Requires writing migration code
- **Best for:** Comprehensive solution that handles all scenarios

**Chosen Approach:** Option 3 - Migration Service with source code updates

---

## Phase 1: Source Code Updates (New Installs)

### Task 1: Update IPM Data (ipm_screen.dart)

**Files:**
- Modify: `lib/ipm_screen.dart:96-144`

**Step 1: Add 2025 data to _initializeDefaultIpmData**

Add after line 132:
```dart
2025: {
  'uhh': 78.45,  // Update with actual 2025 data
  'rls': 11.15,
  'hls': 15.60,
  'pengeluaran': 17800.00,
  'ipm': 85.80
},
```

**Step 2: Add 2025 data to _initializeDefaultKomponenData**

Add after line 142:
```dart
2025: {'ipmNasional': 75.50, 'ipmJateng': 74.30, 'ipmSemarang': 85.80},
```

**Step 3: Verify chart data in home_screen.dart**

Check `lib/home_screen.dart` around line 935 (StatsCard2) and update static chart data if needed.

---

### Task 2: Update Penduduk Data (penduduk_screen.dart)

**Files:**
- Modify: `lib/penduduk_screen.dart:304-448`

**Step 1: Add 2025 to _getDefaultData**

Add after line 355:
```dart
2025: SemarangData(
    year: 2025,
    population: 1723000,  // Update with actual 2025 data
    malePopulation: 852000,
    femalePopulation: 871000,
    area: 374.0,
    density: 4607,
    districts: 16,
    villages: 177,
    growthRate: 0.82),
```

**Step 2: Add 2025 to _getDefaultAgeData**

Add after line 398:
```dart
2025: {
  'usiaMuda': 354000,
  'usiaMudaPercentage': 20.55,
  'usiaProduktif': 1221000,
  'usiaProduktifPercentage': 70.87,
  'usiaTua': 148000,
  'usiaTuaPercentage': 8.59
},
```

**Step 3: Add 2025 to _getDefaultDistrictData**

Add district density data for 2025 after line 448.

**Step 4: Verify chart data in home_screen.dart**

Check StatsCard1 static data around line 880.

---

### Task 3: Update Inflasi Data (inflasi_screen.dart)

**Files:**
- Modify: `lib/inflasi_screen.dart:64-140`

**Step 1: Add 2025 monthly data to monthlyInflationData**

Add after the 2024 entry (around line 140):
```dart
2025: [
  0.25, // Jan
  0.18, // Feb
  0.22, // Mar
  0.15, // Apr
  0.28, // May
  0.31, // Jun
  0.24, // Jul
  0.19, // Aug
  0.21, // Sep
  0.26, // Oct
  0.23, // Nov
  0.29  // Dec
],
```

**Step 2: Update availableYears list**

Find and update availableYears list to include 2025.

---

### Task 4: Update Kemiskinan Data (kemiskinana_screen.dart)

**Files:**
- Modify: `lib/kemiskinana_screen.dart` (find _initializeDefaultData or _loadDefaultData)

**Step 1: Add 2025 poverty data**

Add 2025 entry with poverty statistics (population, percentage, poverty line, etc.).

**Step 2: Verify chart data in home_screen.dart**

Check StatsCard3 static data around line 990.

---

### Task 5: Update Tenaga Kerja Data (tenaga_kerja_screen.dart)

**Files:**
- Modify: `lib/tenaga_kerja_screen.dart:117-210`

**Step 1: Add 2025 to _initializeDefaultYearData**

Add employment data for 2025 (working population, TPAK, TPT, etc.).

**Step 2: Add 2025 to _initializeDefaultIndikatorData**

Add indicator data for 2025.

**Step 3: Add 2025 to _initializeDefaultDistribusiData**

Add sector distribution data for 2025.

**Step 4: Add 2025 to _initializeDefaultJatengData**

Add Central Java comparison data for 2025.

---

### Task 6: Update Pendidikan Data (education_service.dart)

**Files:**
- Modify: `lib/education_service.dart:234-350` (_getDefaultData method)

**Step 1: Add 2025 EducationData entry**

Add after the 2024 entry:
```dart
'2025': EducationData(
  year: '2025',
  angkaMelekHuruf: 97.8,
  rataRataLamaSekolah: 9.5,
  harapanLamaSekolah: 13.8,
  rasioGuruMurid: 14.8,
  tingkatKelulusan: 99.4,
  aksesPendidikanTinggi: 41.0,
  jenjangPendidikan: [
    // Update with actual 2025 data
    JenjangPendidigan(jenjang: 'TK', sekolah: 710, guru: 2500, murid: 30500),
    // ... etc for all education levels
  ],
  // ... other fields
),
```

---

### Task 7: Update SDGs Data (sdgs_data_service.dart)

**Files:**
- Modify: `lib/sdgs_data_service.dart:185-900` (_getDefaultData method)

**Step 1: Add 2025 data to all 35 cities**

For each KotaData entry (35 cities total), add 2025 values to:
- samitasilayak (handwashing)
- tikRemaja (teen ICT)
- tikDewasa (adult ICT)
- aktaLahir (birth certificate)
- apm (participation rate)
- apk (school enrollment)

Example for first city:
```dart
KotaData(
  nama: 'Kab. Cilacap',
  samitasilayak: {
    // ... existing 2019-2024 data ...
    2025: 88.50  // Add 2025
  },
  tikRemaja: {
    // ... existing ...
    2025: 97.00
  },
  // ... etc for all indicators
),
```

---

### Task 8: Update IPG Data (ipg_screen.dart)

**Files:**
- Modify: `lib/ipg_screen.dart` (find default data initialization)

**Step 1: Add 2025 IPG data**

Add Gender Development Index data for 2025.

---

### Task 9: Update IDG Data (idg_screen.dart)

**Files:**
- Modify: `lib/idg_screen.dart` (find default data initialization)

**Step 1: Add 2025 IDG data**

Add Gender Inequality Index data for 2025.

---

### Task 10: Update Pertumbuhan Ekonomi Data (pertumbuhan_ekonomi_screen.dart)

**Files:**
- Modify: `lib/pertumbuhan_ekonomi_screen.dart` (find default data initialization)

**Step 1: Add 2025 economic growth data**

Add GDP growth data for 2025.

---

### Task 11: Update Home Screen Chart Data (home_screen.dart)

**Files:**
- Modify: `lib/home_screen.dart` (StatsCard1-4 static data)

**Step 1: Update StatsCard1 (Penduduk)**

Around line 880, update `_chartData` to include 2025 value.

**Step 2: Update StatsCard2 (IPM)**

Around line 935, update `_chartData` to include 2025 value.

**Step 3: Update StatsCard3 (Kemiskinan)**

Around line 990, update `_chartData` to include 2025 value.

**Step 4: Update StatsCard4 (Inflasi)**

Around line 1045, update `_chartData` to include 2025 value.

---

## Phase 2: Admin Screen Updates

### Task 12: Update Admin IPM Screen (admin_ipm_screen.dart)

**Files:**
- Modify: `lib/admin_ipm_screen.dart:123-180`

**Step 1: Add 2025 to _initializeDefaultIpmData and _initializeDefaultKomponenData**

Mirror the changes from ipm_screen.dart.

---

### Task 13: Update Admin Penduduk Screen (admin_penduduk_screen.dart)

**Files:**
- Modify: `lib/admin_penduduk_screen.dart:142-280`

**Step 1: Add 2025 to all _initializeDefault* methods**

Mirror the changes from penduduk_screen.dart.

---

### Task 14: Update Admin Inflasi Screen (admin_inflasi_screen.dart)

**Files:**
- Modify: `lib/admin_inflasi_screen.dart` (find default data)

**Step 1: Add 2025 monthly inflation data**

Mirror the changes from inflasi_screen.dart.

---

### Task 15: Update Admin Kemiskinan Screen (admin_kemiskinan_screen.dart)

**Files:**
- Modify: `lib/admin_kemiskinan_screen.dart` (find default data)

**Step 1: Add 2025 poverty data**

Mirror the changes from kemiskinana_screen.dart.

---

### Task 16: Update Admin Tenaga Kerja Screen (admin_tenaga_kerja_screen.dart)

**Files:**
- Modify: `lib/admin_tenaga_kerja_screen.dart:147-280`

**Step 1: Add 2025 to all _initializeDefault* methods**

Mirror the changes from tenaga_kerja_screen.dart.

---

### Task 17: Update Admin Education Screen (admin_education_screen.dart)

**Files:**
- Modify: `lib/admin_education_screen.dart` (find default data)

**Step 1: Add 2025 education data**

Mirror the changes from education_service.dart.

---

### Task 18: Update Admin IDG Screen (admin_idg_screen.dart)

**Files:**
- Modify: `lib/admin_idg_screen.dart:118-200`

**Step 1: Add 2025 IDG data**

Mirror the changes from idg_screen.dart.

---

### Task 19: Update Admin Pertumbuhan Ekonomi Screen (admin_pertumbuhan_ekonomi_screen.dart)

**Files:**
- Modify: `lib/admin_pertumbuhan_ekonomi_screen.dart` (find default data)

**Step 1: Add 2025 economic data**

Mirror the changes from pertumbuhan_ekonomi_screen.dart.

---

### Task 20: Update Admin SDGs Dashboard Screen (admin_sdgs_dashboard_screen.dart)

**Files:**
- Modify: `lib/admin_sdgs_dashboard_screen.dart` (find default data)

**Step 1: Add 2025 SDGs data for all 35 cities**

Mirror the changes from sdgs_data_service.dart.

---

## Phase 3: Migration Service (Existing Users)

### Task 21: Create Data Migration Service

**Files:**
- Create: `lib/services/data_migration_service.dart`

**Step 1: Create migration service**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class DataMigrationService {
  static const String _migrationVersionKey = 'data_migration_version';
  static const int _targetVersion = 2025; // Update this each year

  static Future<void> migrateTo2025() async {
    final prefs = await SharedPreferences.getInstance();
    final currentVersion = prefs.getInt(_migrationVersionKey) ?? 2024;
    
    if (currentVersion >= _targetVersion) {
      print('Data already at version $_targetVersion');
      return;
    }

    print('Migrating data from $currentVersion to $_targetVersion...');
    
    await _migratePendudukData(prefs);
    await _migrateIpmData(prefs);
    await _migrateInflasiData(prefs);
    await _migrateKemiskinanData(prefs);
    await _migrateTenagaKerjaData(prefs);
    await _migrateEducationData(prefs);
    await _migrateSDGsData(prefs);
    await _migrateIDGData(prefs);
    await _migrateEkonomiData(prefs);
    
    await prefs.setInt(_migrationVersionKey, _targetVersion);
    print('Migration to $_targetVersion completed successfully!');
  }

  static Future<void> _migratePendudukData(SharedPreferences prefs) async {
    // Add 2025 population data
    final savedData = prefs.getString('penduduk_data');
    if (savedData != null) {
      final data = json.decode(savedData) as Map<String, dynamic>;
      if (!data.containsKey('2025')) {
        data['2025'] = {
          'population': 1723000,
          'malePopulation': 852000,
          'femalePopulation': 871000,
          'area': 374.0,
          'density': 4607,
          'districts': 16,
          'villages': 177,
          'growthRate': 0.82
        };
        await prefs.setString('penduduk_data', json.encode(data));
        print('✓ Penduduk data migrated');
      }
    }
    
    // Migrate age data
    final ageData = prefs.getString('age_distribution_data');
    if (ageData != null) {
      final data = json.decode(ageData) as Map<String, dynamic>;
      if (!data.containsKey('2025')) {
        data['2025'] = {
          'usiaMuda': 354000,
          'usiaMudaPercentage': 20.55,
          'usiaProduktif': 1221000,
          'usiaProduktifPercentage': 70.87,
          'usiaTua': 148000,
          'usiaTuaPercentage': 8.59
        };
        await prefs.setString('age_distribution_data', json.encode(data));
      }
    }
  }

  static Future<void> _migrateIpmData(SharedPreferences prefs) async {
    final savedData = prefs.getString('ipm_data');
    if (savedData != null) {
      final data = json.decode(savedData) as Map<String, dynamic>;
      if (!data.containsKey('2025')) {
        data['2025'] = {
          'uhh': 78.45,
          'rls': 11.15,
          'hls': 15.60,
          'pengeluaran': 17800.00,
          'ipm': 85.80
        };
        await prefs.setString('ipm_data', json.encode(data));
        print('✓ IPM data migrated');
      }
    }
    
    final komponenData = prefs.getString('ipm_komponen_data');
    if (komponenData != null) {
      final data = json.decode(komponenData) as Map<String, dynamic>;
      if (!data.containsKey('2025')) {
        data['2025'] = {
          'ipmNasional': 75.50,
          'ipmJateng': 74.30,
          'ipmSemarang': 85.80
        };
        await prefs.setString('ipm_komponen_data', json.encode(data));
      }
    }
  }

  // ... similar methods for other categories
  static Future<void> _migrateInflasiData(SharedPreferences prefs) async {
    // Inflasi is hardcoded in most screens, but if stored in prefs, migrate it
  }

  static Future<void> _migrateKemiskinanData(SharedPreferences prefs) async {
    final savedData = prefs.getString('kemiskinan_data');
    if (savedData != null) {
      final data = json.decode(savedData) as Map<String, dynamic>;
      if (!data.containsKey('2025')) {
        // Add 2025 kemiskinan data
        data['2025'] = {
          'pendudukMiskin': '69.300',
          'pendudukMiskinValue': 69300.0,
          'persentase': '4.02',
          'persentaseValue': 4.02,
          // ... other fields
        };
        await prefs.setString('kemiskinan_data', json.encode(data));
        print('✓ Kemiskinan data migrated');
      }
    }
  }

  static Future<void> _migrateTenagaKerjaData(SharedPreferences prefs) async {
    // Migrate tenaga kerja data
  }

  static Future<void> _migrateEducationData(SharedPreferences prefs) async {
    // Migrate education data
  }

  static Future<void> _migrateSDGsData(SharedPreferences prefs) async {
    // Migrate SDGs data for 35 cities
  }

  static Future<void> _migrateIDGData(SharedPreferences prefs) async {
    // Migrate IDG data
  }

  static Future<void> _migrateEkonomiData(SharedPreferences prefs) async {
    // Migrate economic growth data
  }
}
```

---

### Task 22: Integrate Migration Service

**Files:**
- Modify: `lib/main.dart:20-50` (AppInitializer)

**Step 1: Call migration in AppInitializer**

```dart
Future<void> _initializeApp() async {
  try {
    print("🚀 Inisialisasi aplikasi...");
    
    // Run data migration for existing users
    await DataMigrationService.migrateTo2025();
    
  } catch (e, s) {
    print("❌ Error saat inisialisasi: $e");
    print(s);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
```

**Step 2: Add import**

```dart
import 'services/data_migration_service.dart';
```

---

## Phase 4: Testing

### Task 23: Test Fresh Installation

**Step 1: Clean build and run**

```bash
cd /home/qiu/STARA_BPS_ID
flutter clean
flutter pub get
flutter run
```

**Step 2: Verify all categories show 2025 data**

- Check each category screen has 2025 in year selector
- Verify data displays correctly
- Check charts show 2025 data point

---

### Task 24: Test Existing Installation (Migration)

**Step 1: Install old version first**

Build and install app without 2025 data changes.

**Step 2: Update to new version**

Install updated app with 2025 data.

**Step 3: Verify migration worked**

- Check that 2024 data is preserved
- Verify 2025 data was added
- Confirm no data loss occurred

---

### Task 25: Test Admin Screens

**Step 1: Login as admin**

- Username: `admin`
- Password: `admin123`

**Step 2: Verify admin can edit 2025 data**

- Check each admin screen can view and edit 2025 data
- Test save functionality
- Verify changes persist after app restart

---

## Implementation Checklist

### Phase 1: Source Code Updates
- [ ] Task 1: IPM data (ipm_screen.dart)
- [ ] Task 2: Penduduk data (penduduk_screen.dart)
- [ ] Task 3: Inflasi data (inflasi_screen.dart)
- [ ] Task 4: Kemiskinan data (kemiskinana_screen.dart)
- [ ] Task 5: Tenaga Kerja data (tenaga_kerja_screen.dart)
- [ ] Task 6: Pendidikan data (education_service.dart)
- [ ] Task 7: SDGs data (sdgs_data_service.dart) - 35 cities
- [ ] Task 8: IPG data (ipg_screen.dart)
- [ ] Task 9: IDG data (idg_screen.dart)
- [ ] Task 10: Pertumbuhan Ekonomi data (pertumbuhan_ekonomi_screen.dart)
- [ ] Task 11: Home screen charts (home_screen.dart)

### Phase 2: Admin Screen Updates
- [ ] Task 12: Admin IPM screen
- [ ] Task 13: Admin Penduduk screen
- [ ] Task 14: Admin Inflasi screen
- [ ] Task 15: Admin Kemiskinan screen
- [ ] Task 16: Admin Tenaga Kerja screen
- [ ] Task 17: Admin Education screen
- [ ] Task 18: Admin IDG screen
- [ ] Task 19: Admin Pertumbuhan Ekonomi screen
- [ ] Task 20: Admin SDGs screen

### Phase 3: Migration
- [ ] Task 21: Create migration service
- [ ] Task 22: Integrate migration in main.dart

### Phase 4: Testing
- [ ] Task 23: Test fresh installation
- [ ] Task 24: Test migration
- [ ] Task 25: Test admin functionality

---

## Notes for Implementation

1. **Data Values:** All 2025 values in this plan are placeholders. Replace with actual BPS Semarang 2025 statistics before deployment.

2. **Testing Strategy:** Test on both Android and iOS if possible. Use `flutter run --release` for final testing.

3. **Backup:** Before running migration on production devices, ensure you have data backup strategy.

4. **Version Update:** Consider updating app version in `pubspec.yaml` (e.g., 0.14.0+4) for this data update.

5. **Performance:** Migration runs only once per device. The migration version check prevents unnecessary re-runs.

6. **Future Years:** This pattern can be reused for 2026, 2027, etc. Just:
   - Update default data in all files
   - Update migration service with new year
   - Increment `_targetVersion`
   - Test thoroughly

---

**Plan saved to:** `plans/add-2025-data-plan.md`
