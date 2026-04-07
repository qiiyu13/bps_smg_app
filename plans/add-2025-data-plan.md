# 2025 Data Update Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Update Flutter app with 2025 data from new Excel files and update SDGs indicators

**Architecture:** The app uses hardcoded default data in each screen's `_initializeDefault*()` methods. Data is stored in SharedPreferences. Updates require adding 2025 entries to these default data methods and updating available year lists.

**Tech Stack:** Flutter, Dart, SharedPreferences

---

## Data Summary (Extracted from Excel)

### IPM 2025 Data
| Indicator | Value |
|-----------|-------|
| UHH | 78.72 |
| RLS | 11.11 |
| HLS | 15.58 |
| Pengeluaran | 17402.00 (juta rupiah) |
| IPM | 85.80 |
| IPM Nasional | 75.90 |
| IPM Jawa Tengah | 74.77 |

### Pertumbuhan Ekonomi 2025
- New sheet "2025" added with full data for all districts
- Additional data columns (Kontribusi PDRB) added to existing years

### SDGs 2025
- Existing indicators: cucitangan, TIK (remaja/dewasa), akta lahir, APM APK
- Data available through 2024 in new Excel sheets (2025 not yet available)
- Need to verify/update existing years with new data

### Pengangguran 2025 (Kota Semarang)
| Indicator | Value |
|-----------|-------|
| TPAK | 72.60 |
| TPT | 5.65 |

### Tenaga Kerja 2025 (Kota Semarang)
| Indicator | Value |
|-----------|-------|
| Angkatan Kerja | 994,994 |
| Bekerja | 938,766 |
| Pengangguran | 56,228 |
| TPAK | 72.60 |
| TPT | 5.65 |

---

## Task 1: Update IPM Screen with 2025 Data

**Files:**
- Modify: `lib/ipm_screen.dart:97-145`

**Step 1: Update _initializeDefaultIpmData()**

Add 2025 entry after 2024:

```dart
2025: {
  'uhh': 78.72,
  'rls': 11.11,
  'hls': 15.58,
  'pengeluaran': 17402.00,
  'ipm': 85.80
},
```

**Step 2: Update _initializeDefaultKomponenData()**

Add 2025 entry:

```dart
2025: {'ipmNasional': 75.90, 'ipmJateng': 74.77, 'ipmSemarang': 85.80},
```

---

## Task 2: Update Pertumbuhan Ekonomi Screen

**Files:**
- Modify: `lib/pertumbuhan_ekonomi_screen.dart` (find _initializeDefault or year list)
- Modify: `lib/admin_pertumbuhan_ekonomi_screen.dart` (find _initializeDefault or year list)

**Step 1: Add 2025 to available years**

Search for `availableYears` or similar list and add 2025.

---

## Task 3: Update Tenaga Kerja Screen with 2025 Data

**Files:**
- Modify: `lib/tenaga_kerja_screen.dart:118-200`

**Step 1: Update _initializeDefaultYearData()**

Add 2025 entry for TPAK/TPT data:

```dart
2025: {'tpak': 72.60, 'tpt': 5.65},
```

**Step 2: Update _initializeDefaultIndikatorData()**

Add 2025 for indicators like:
- Bekerja: 938766
- Pengangguran: 56228
- Angkatan Kerja: 994994

---

## Task 4: Update SDGs Data Service with New Data

**Files:**
- Modify: `lib/sdgs_data_service.dart:185-500` (in _getDefaultData method)

**Step 1: Update existing city data**

The SDGs Excel files have updated data for years 2019-2024. Update the `_getDefaultData()` method with the latest values from the new Excel files:

From `SDGs/SDGs 2024 ke kako(1).xlsx`:

### Cucitangan (Sample - Kota Semarang):
- 2024: 91.50 (verify from Excel)

### TIK Remaja (Sample - Kota Semarang):
- 2024: 98.90 (verify from Excel)

### Akta Lahir (Sample - Kota Semarang):
- 2024: 95.01 (verify from Excel)

### APM APK (Sample - Kota Semarang):
- 2024: 100.00 (verify from Excel)

Note: The app already has SDGs category. This task is to update the default data values with any corrections from the new Excel files.

---

## Task 5: Verify All Screens

**Step 1: Build the app**

Run: `flutter build apk --debug`

**Step 2: Test navigation**

Verify all categories still work after updates.

---

## Execution Notes

1. Most screens use SharedPreferences for data storage - users who already have the app will need to clear data or the update will need to force refresh
2. Admin screens don't need updates (per user request)
3. No new categories to add - just updating existing data with 2025 values
4. Verify row counts in Excel match what's being added to default data

---

**Plan complete.**
