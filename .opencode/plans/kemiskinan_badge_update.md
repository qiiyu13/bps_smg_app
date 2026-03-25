# Plan: Update Kemiskinan Badge Style

## Goal
Update the delta indicator badge in kemiskinana_screen.dart to match the home_screen.dart pill style.

## Changes Required

### File: lib/kemiskinana_screen.dart
**Location:** Lines 1402-1435 (Badge section in _PovertyTrendChart widget)

**Current Style:**
- Light tinted background: `(isPositive ? _bpsGreen : _bpsRed).withOpacity(0.15)`
- Colored text/icon on light background
- Border radius: 20
- No shadow
- Padding: 12/16 horizontal, 8/10 vertical
- Icon size: 16/18
- Text size: 13/15

**Target Style (matching home_screen.dart):**
- Solid background color: `isPositive ? _bpsGreen : _bpsRed`
- White text and icons
- Border radius: 12
- Add shadow with opacity 0.3, blur 8, offset (0, 2)
- Slightly smaller padding: 10/12 horizontal, 6/8 vertical
- Slightly smaller icon: 14/16
- Slightly smaller text: 12/13 with letterSpacing 0.2

**Logic:**
- Keep: Green = Menurun (decrease is good for poverty)
- Keep: Red = Meningkat (increase is bad for poverty)
- Keep: "Menurun"/"Meningkat" text (don't change to percentage)
- Keep: Position on right side of indicator card

## Implementation Steps
1. Read the current badge implementation
2. Update decoration to use solid colors and add boxShadow
3. Update icon and text colors to white
4. Adjust border radius, padding, and sizes
5. Test the changes

## Notes
- This applies to both poverty trend charts (Jumlah Penduduk Miskin and Persentase Kemiskinan)
- The badge only appears when comparing years (selectedYear != baseYear)