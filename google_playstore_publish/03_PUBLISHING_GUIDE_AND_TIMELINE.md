# Panduan Lengkap Publikasi Aplikasi Lawang ke Google Play Store

**Versi:** 1.0  
**Tanggal:** 25 Maret 2026  
**Estimasi Total Waktu:** 4-8 minggu

---

## 📋 RINGKASAN PROSES

Publikasi aplikasi pemerintah ke Google Play Store melibatkan beberapa tahap:
1. Persiapan Dokumen & Aset (2-3 minggu)
2. Registrasi Akun Developer (1-2 minggu)
3. Konfigurasi Play Console (3-5 hari)
4. Submit & Review (3-7 hari)
5. Publikasi (1 hari)

---

## FASE 1: PERSIAPAN DOKUMEN & ASET (Minggu 1-2)

### Target: Lengkapi semua dokumen dan aset visual

#### Minggu 1: Dokumen Pemerintahan
**Hari 1-2: Administrasi BPS**
- [ ] Ajukan permohonan surat kuasa/otorisasi publikasi aplikasi
- [ ] Koordinasi dengan Subbag Umum/Bagren untuk dokumen legal BPS
- [ ] Siapkan KTP dan surat keterangan ASN untuk admin akun

**Hari 3-5: Privacy Policy**
- [ ] Finalisasi draft privacy policy (sudah dibuat di folder ini)
- [ ] Koordinasi dengan BPS untuk review kebijakan
- [ ] Request BPS IT untuk hosting privacy policy di bps.go.id
  - URL target: `https://www.bps.go.id/privacy-policy/lawang`
  - Format: HTML atau link ke PDF

**Dokumen Output:**
- Surat kuasa dari BPS
- Dokumen legal organisasi
- Privacy Policy yang dihosting

#### Minggu 2: Aset Visual & Metadata
**Hari 1-2: Screenshot**
- [ ] Ambil screenshot aplikasi di berbagai fitur utama
- [ ] Buat variasi untuk HP, tablet 7", dan tablet 10"
- [ ] Edit jika perlu (tambahkan label/teks penjelas)

**Hari 3-4: Feature Graphic**
- [ ] Desain feature graphic 1024x500px
- [ ] Sertakan branding BPS
- [ ] Gunakan tagline yang jelas

**Hari 5: Metadata**
- [ ] Tulis deskripsi singkat (80 karakter)
- [ ] Tulis deskripsi lengkap (4000 karakter)
- [ ] Siapkan informasi kontak dukungan

**Deliverables:**
- Screenshot (min 2, maks 8 per device type)
- Feature graphic
- Deskripsi aplikasi
- Informasi kontak

---

## FASE 2: REGISTRASI AKUN DEVELOPER (Minggu 3)

### Target: Akun developer aktif dan terverifikasi

#### Hari 1-3: Pendaftaran Akun
**Langkah-langkah:**

1. **Akses Google Play Console**
   - URL: https://play.google.com/console
   - Login menggunakan email resmi BPS (@bps.go.id)

2. **Pilih Tipe Akun: ORGANIZATION** ⚠️
   - WAJIB pilih Organization (bukan Personal)
   - Karena ini aplikasi pemerintah

3. **Isi Informasi Developer:**
   - Nama legal: "Badan Pusat Statistik Republik Indonesia"
   - Alamat: Alamat lengkap kantor pusat BPS
   - Nomor telepon: Nomor resmi BPS
   - Email kontak: Email resmi BPS

4. **Pembayaran:**
   - Biaya registrasi: $25 USD (one-time)
   - Metode: Kartu kredit/debit atau metode lain yang tersedia

#### Hari 4-7: Verifikasi Identitas

**Verifikasi yang Diperlukan:**

1. **Verifikasi Email & Telepon**
   - Email: Verifikasi melalui kode 6 digit
   - Telepon: Verifikasi melalui SMS atau panggilan suara

2. **Verifikasi Identitas Pribadi** (Admin Akun)
   - Unggah KTP atau paspor
   - Foto selfie dengan KTP
   - Tunggu verifikasi (1-3 hari kerja)

3. **Verifikasi Organisasi**
   - Unggah dokumen legal BPS
   - Surat kuasa/otorisasi
   - Tunggu verifikasi (2-5 hari kerja)

4. **D-U-N-S Number** (Opsional)
   - Untuk pemerintah, bisa request pengecualian
   - Hubungi Google Support jika diminta
   - Gunakan form: https://support.google.com/googleplay/android-developer/contact/kyd

**Timeline Verifikasi:**
- Email/Telepon: Instan - 1 hari
- Identitas Pribadi: 1-3 hari
- Organisasi: 2-5 hari

**Total:** 3-7 hari kerja

---

## FASE 3: KONFIGURASI PLAY CONSOLE (Minggu 4)

### Target: Aplikasi siap untuk review

#### Hari 1: Buat Aplikasi Baru

1. **Klik "Create App"**
2. **Isi Informasi Dasar:**
   - Nama aplikasi: "Lawang"
   - Bahasa default: Indonesia
   - App atau Game: App
   - Gratis atau Berbayar: Gratis

#### Hari 2: Setup Store Listing

**Main Store Listing:**
- [ ] Nama aplikasi: "Lawang"
- [ ] Deskripsi singkat: [80 karakter]
- [ ] Deskripsi lengkap: [4000 karakter]
- [ ] Screenshot HP: Upload 2-8 gambar
- [ ] Screenshot Tablet 7": Upload jika ada
- [ ] Screenshot Tablet 10": Upload jika ada
- [ ] Feature Graphic: Upload 1024x500px
- [ ] Icon: Upload 512x512px

**Contact Details:**
- [ ] Website: https://www.bps.go.id
- [ ] Email: [email dukungan BPS]
- [ ] Telepon: [nomor BPS]

#### Hari 3: App Content (Konten Penting!)

**1. Privacy Policy**
- [ ] Masukkan URL privacy policy: `https://www.bps.go.id/privacy-policy/lawang`

**2. Data Safety** ⚠️ WAJIB
- [ ] Klik "Data Safety"
- [ ] Jawab pertanyaan:
  - Apakah mengumpulkan data? → Ya
  - Jenis data apa? → Info perangkat, lokasi (opsional)
  - Apakah dibagikan ke pihak ketiga? → Tidak
  - Apakah data dienkripsi? → Ya
  - Dapatkah pengguna meminta penghapusan? → Ya (hapus aplikasi)

**3. Government Apps Declaration** ⚠️ WAJIB
- [ ] Buka "App content" → "Government apps"
- [ ] Centang: "This app is developed by or on behalf of a government entity"
- [ ] Pilih tipe: "National/Regional government"

**4. App Access**
- [ ] Pilih: "All functionality is available without special access"
- [ ] Atau berikan demo account jika ada fitur yang memerlukan login

**5. Content Rating**
- [ ] Isi kuesioner content rating
- [ ] Untuk aplikasi statistik: Paling rendah "Everyone"
- [ ] Dapatkan rating: PEGI 3, ESRB E, dll.

**6. Target Audience**
- [ ] Pilih: "13 and over" atau "18 and over"
- [ ] Aplikasi statistik umumnya untuk 13+

**7. News Apps** (Opsional)
- [ ] Jika aplikasi berisi berita/artikel, declare sebagai news app

**8. COVID-19 Apps** (Tidak perlu)
- [ ] Lewati jika tidak terkait COVID-19

**9. Financial Features** (Tidak perlu)
- [ ] Lewati jika tidak ada fitur keuangan

#### Hari 4-5: Upload Aplikasi

**1. Generate App Bundle**
```bash
flutter clean
flutter pub get
flutter build appbundle
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

**2. Upload ke Play Console**
- [ ] Buka "Production" → "Create new release"
- [ ] Upload file `.aab`
- [ ] Tunggu pemrosesan (5-30 menit)

**3. Isi Release Notes**
```
Versi 1.0.0:
- Peluncuran pertama aplikasi Lawang
- Fitur statistik regional
- Peta interaktif
- Data PDRB dan kemiskinan
```

---

## FASE 4: SUBMIT & REVIEW (Minggu 4-5)

### Target: Aplikasi dalam antrian review

#### Review Process

**Setelah Submit:**
1. **Review Otomatis** (1-2 jam)
   - Scan malware
   - Check policy violations
   - Validasi keystore

2. **Review Manual** (3-7 hari)
   - Reviewer Google memeriksa aplikasi
   - Verifikasi government declaration
   - Check privacy policy compliance
   - Test functionality

3. **Government App Verification** (Additional)
   - Google mungkin kontak BPS untuk verifikasi
   - Pastikan email BPS aktif dan responsif
   - Siapkan dokumen jika diminta

#### Possible Outcomes:

✅ **Approved**
- Aplikasi lolos review
- Siap dipublikasikan
- Bisa publish langsung atau jadwalkan

⚠️ **Rejected dengan Revisi**
- Reviewer menemukan masalah
- Perbaiki sesuai instruksi
- Submit ulang
- Estimasi tambahan: 3-7 hari

❌ **Rejected**
- Pelanggaran policy yang serius
- Butuh perubahan signifikan
- Submit ulang dari awal

**Tips:**
- Jawab cepat jika reviewer ada pertanyaan
- Sediakan demo account jika diminta
- Dokumentasi lengkap membantu

---

## FASE 5: PUBLIKASI (Minggu 5)

### Target: Aplikasi live di Play Store

#### Setelah Approved:

**Opsi 1: Publish Sekarang**
- Klik "Start rollout to Production"
- Aplikasi live dalam 1-2 jam
- Tersedia di seluruh dunia

**Opsi 2: Scheduled Release**
- Pilih tanggal dan waktu publish
- Aplikasi akan otomatis live
- Berguna untuk peluncuran bersamaan dengan event

**Opsi 3: Staged Rollout** (Disarankan)
- Rilis ke % kecil pengguna dulu (misal: 10%)
- Monitor crash reports dan feedback
- Tingkatkan ke 50%, lalu 100%
- Minimalkan risiko jika ada bug

#### Post-Publish:

1. **Verifikasi Aplikasi**
   - [ ] Cari "Lawang" di Play Store
   - [ ] Verifikasi semua metadata benar
   - [ ] Test install di device
   - [ ] Cek semua screenshot muncul

2. **Setup Monitoring**
   - [ ] Enable crash reporting
   - [ ] Setup Google Analytics (opsional)
   - [ ] Pantau rating dan review

3. **Response ke Review**
   - [ ] Balas review pengguna
   - [ ] Fix bug yang dilaporkan
   - [ ] Update aplikasi jika perlu

---

## 📅 TIMELINE RINGKASAN

| Fase | Kegiatan | Estimasi Waktu | Cumulative |
|------|----------|----------------|------------|
| 1 | Persiapan Dokumen & Aset | 2 minggu | 2 minggu |
| 2 | Registrasi Akun Developer | 1 minggu | 3 minggu |
| 3 | Konfigurasi Play Console | 5 hari | 4 minggu |
| 4 | Submit & Review | 1 minggu | 5 minggu |
| 5 | Publikasi | 1 hari | 5+ minggu |

**Estimasi Total:** 4-6 minggu (jika lancar)  
**Estimasi dengan buffer:** 6-8 minggu (jika ada revisi)

---

## ⚠️ HAL-HAL PENTING

### Prioritas Tinggi:
1. ✅ Akun harus tipe **ORGANIZATION**
2. ✅ Centang **Government App Declaration**
3. ✅ Privacy Policy dihosting di domain **.go.id**
4. ✅ Semua screenshot berkualitas baik
5. ✅ Tidak ada placeholder/test content

### Common Rejection Reasons:
- ❌ Privacy policy tidak sesuai
- ❌ Screenshot tidak relevan/blur
- ❌ Metadata tidak lengkap
- ❌ App crash atau force close
- ❌ Pelanggaran hak cipta
- ❌ Misleading claims

### Kontak Penting:

**Google Play Developer Support:**
- URL: https://support.google.com/googleplay/android-developer/contact/kyd
- Untuk pemerintah: Sertakan dokumen otorisasi

**BPS IT Team:**
- Koordinasi untuk hosting privacy policy
- Verifikasi domain bps.go.id

---

## 📚 RESOURCE TAMBAHAN

- **Google Play Policy:** https://play.google.com/about/developer-content-policy/
- **Developer Agreement:** https://play.google.com/intl/en_us/about/developer-distribution-agreement.html
- **Government Apps Policy:** https://support.google.com/googleplay/android-developer/answer/9514050
- **D-U-N-S Lookup:** https://service.dnb.com/home

---

## ✅ FINAL CHECKLIST

Sebelum submit, pastikan:
- [ ] Semua dokumen legal BPS lengkap
- [ ] Privacy Policy dihosting di domain resmi
- [ ] Akun developer terverifikasi (Organization)
- [ ] Semua screenshot dan aset visual siap
- [ ] App bundle berhasil di-generate
- [ ] Release notes sudah ditulis
- [ ] Government app declaration dicentang
- [ ] Data safety section lengkap
- [ ] Contact information valid
- [ ] Demo account siap (jika diperlukan)

**Ready to publish! 🚀**

---

**Dibuat oleh:** [Nama Tim/Individual]  
**Tanggal Update:** 25 Maret 2026  
**Versi Dokumen:** 1.0
