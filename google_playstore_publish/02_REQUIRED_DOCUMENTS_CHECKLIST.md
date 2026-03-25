# Daftar Dokumen Wajib untuk Publikasi Aplikasi Lawang di Google Play Store

**Tanggal Pembuatan:** 25 Maret 2026  
**Versi:** 1.0  
**Status:** [ ] Belum Lengkap | [✓] Sedang Diproses | [✓] Selesai

---

## 🏛️ DOKUMEN PEMERINTAHAN (WAJIB)

### Akun Google Play Developer
| No | Dokumen | Status | Catatan |
|----|---------|--------|---------|
| 1 | Email resmi BPS (@bps.go.id) | [ ] | Untuk registrasi akun developer |
| 2 | KTP/Identitas resmi admin akun | [ ] | Verifikasi identitas pribadi |
| 3 | Surat keterangan aktif sebagai ASN/pegawai | [ ] | Dari BPS untuk admin akun |
| 4 | Surat kuasa/otorisasi dari BPS | [ ] | Resmi mengizinkan publikasi aplikasi |
| 5 | Dokumen legal BPS (Akta pendirian/peraturan) | [ ] | Untuk verifikasi organisasi |
| 6 | D-U-N-S Number (opsional untuk pemerintah) | [ ] | Atau kontak Google untuk pengecualian |

**Status Akun:** [ ] Belum dibuat | [ ] Sedang verifikasi | [ ] Aktif

---

## 📱 ASET APLIKASI (WAJIB)

### Aset Visual
| No | Item | Spesifikasi | Status | File/Path |
|----|------|-------------|--------|-----------|
| 1 | Screenshot HP (min 2, max 8) | JPEG/PNG, 16:9 atau 9:16, min 320px | [ ] | `assets/screenshots/phone/` |
| 2 | Screenshot Tablet 7-inch | JPEG/PNG, 16:9 atau 9:16 | [ ] | `assets/screenshots/tablet7/` |
| 3 | Screenshot Tablet 10-inch | JPEG/PNG, 16:9 atau 9:16 | [ ] | `assets/screenshots/tablet10/` |
| 4 | Feature Graphic | 1024 x 500px, JPEG/PNG | [ ] | `assets/feature_graphic.png` |
| 5 | High-res Icon | 512 x 512px, PNG 32-bit | [ ] | Sudah ada: `assets/images/logo.png` |
| 6 | App Icon | Adaptive icons | [✓] | Sudah dikonfigurasi di AndroidManifest |

### Metadata Aplikasi
| No | Item | Status | Konten |
|----|------|--------|--------|
| 1 | Nama Aplikasi | [✓] | "Lawang" |
| 2 | Judul Pendek | [ ] | Maks 30 karakter |
| 3 | Deskripsi Singkat | [ ] | Maks 80 karakter |
| 4 | Deskripsi Lengkap | [ ] | Maks 4000 karakter |
| 5 | Kategori Aplikasi | [ ] | Pilih: Productivity/Reference |
| 6 | Email Dukungan | [ ] | Email BPS resmi |
| 7 | Nomor Telepon Dukungan | [ ] | Nomor BPS resmi |
| 8 | Website | [ ] | https://www.bps.go.id |

---

## 📋 KEBIJAKAN DAN KEAMANAN (WAJIB)

| No | Item | Status | Lokasi |
|----|------|--------|--------|
| 1 | Privacy Policy (dalam bahasa) | [ ] | Dihosting di bps.go.id |
| 2 | URL Privacy Policy | [ ] | [https://www.bps.go.id/privacy-policy/lawang] |
| 3 | Data Safety Section (di Play Console) | [ ] | Diisi saat submit |
| 4 | Government App Declaration | [ ] | Centang di Play Console |
| 5 | Content Rating Questionnaire | [ ] | Diisi di Play Console |
| 6 | Target Audience Declaration | [ ] | 13+ tahun (default) |

---

## 🔐 TEKNIS & KEAMANAN

| No | Item | Status | Catatan |
|----|------|--------|---------|
| 1 | Keystore (upload-keystore.jks) | [✓] | Sudah ada di `android/app/` |
| 2 | Key Properties | [✓] | Sudah dikonfigurasi |
| 3 | Build Release Configuration | [✓] | Sudah di `build.gradle.kts` |
| 4 | Target SDK Version | [ ] | Pastikan API 34 atau terbaru |
| 5 | Min SDK Version | [✓] | API 21 (dari config) |
| 6 | App Bundle (AAB) | [ ] | Generate saat release |
| 7 | Test Build | [ ] | Test release build berjalan |

---

## 🧪 TESTING & QA

| No | Item | Status | Catatan |
|----|------|--------|---------|
| 1 | Release Build Successful | [ ] | `flutter build appbundle` |
| 2 | No Debug/Logging Code | [ ] | Hapus print statements |
| 3 | No Hardcoded API Keys | [ ] | Periksa semua API keys |
| 4 | Demo Account (jika perlu) | [ ] | Untuk reviewer Google |
| 5 | Testing Instructions | [ ] | Dokumentasi cara pakai |
| 6 | Device Testing | [ ] | Test di berbagai device |

---

## 📊 STATUS KESELURUHAN

**Dokumen Pemerintahan:** [ ] 0/6 selesai  
**Aset Aplikasi:** [ ] 0/8 selesai  
**Kebijakan & Keamanan:** [ ] 0/6 selesai  
**Teknis:** [✓] 3/7 selesai  
**Testing:** [ ] 0/6 selesai

**TOTAL PROGRESS:** [ ] 3/33 (9%)

---

## ✅ CHECKLIST AKHIR SEBELUM SUBMIT

- [ ] Semua screenshot berkualitas baik
- [ ] Privacy Policy sudah dihosting di domain BPS
- [ ] Tidak ada konten placeholder/test
- [ ] Semua link berfungsi (website, email, support)
- [ ] App bundle berhasil dibuat
- [ ] Sudah test di device fisik
- [ ] Government declaration sudah dicentang
- [ ] Data safety section sudah lengkap
- [ ] Konten rating sudah diisi
- [ ] Siap untuk review!

---

## 📞 KONTAK TIM

**PIC Publikasi:** [Nama]  
**Email:** [email@bps.go.id]  
**Telepon:** [Nomor]  
**Unit:** [Unit/Subdit terkait]

---

**Catatan:** Tandai dengan [✓] saat item selesai. Update checklist ini secara berkala.
