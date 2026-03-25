# 📚 PANDUAN LENGKAP BPS DATA UPLOADER

**Versi:** 1.0.0  
**Terakhir Diupdate:** Februari 2024  
**Untuk:** Staff BPS Kota Semarang

---

## 📋 DAFTAR ISI

1. [Gambaran Umum](#gambaran-umum)
2. [Persiapan Awal](#persiapan-awal)
3. [Tutorial Staff - Step by Step](#tutorial-staff)
4. [Format Excel Detail](#format-excel)
5. [Troubleshooting](#troubleshooting)
6. [FAQ](#faq)
7. [Referensi Cepat](#referensi-cepat)

---

## 🎯 GAMBARAN UMUM

### Apa itu BPS Data Uploader?

BPS Data Uploader adalah aplikasi Windows yang memungkinkan staff BPS untuk:
- ✅ Mengisi data statistik menggunakan Excel (format yang familiar)
- ✅ Upload data langsung ke GitHub
- ✅ Update aplikasi mobile BPS secara real-time
- ✅ Tidak perlu nunggu Play Store review (2-7 hari)

### Mengapa menggunakan sistem ini?

| Cara Lama | Cara Baru (Sekarang) |
|-----------|---------------------|
| Developer edit kode | Staff edit Excel |
| Build APK (30 menit) | Save file (5 detik) |
| Upload Play Store | Klik Upload (1 menit) |
| Tunggu review 2-7 hari | **Langsung jadi!** |
| User update manual | **Auto update** |

### Arsitektur Sistem

```
Staff BPS (Windows PC)
    ↓
Excel Template (.xlsx)
    ↓
BPS Data Uploader App (.exe)
    ↓
GitHub Repository (Online)
    ↓
Aplikasi Mobile BPS (Auto-download)
```

---

## 🛠️ PERSIAPAN AWAL

### A. Untuk Developer (Setup Pertama Kali)

#### 1. Install Python (Windows)

**Langkah-langkah:**
1. Buka browser → https://python.org
2. Download Python 3.9 atau lebih baru
3. Jalankan installer
4. **PENTING:** Centang "☑️ Add Python to PATH"
5. Klik "Install Now"
6. Tunggu selesai

**Verifikasi install:**
```bash
# Buka Command Prompt (CMD)
# Ketik:
python --version

# Output harusnya:
# Python 3.9.x (atau lebih baru)
```

#### 2. Install Dependencies

**Langkah-langkah:**
1. Buka folder `bps-data-uploader`
2. Shift + Klik Kanan → "Open PowerShell window here"
3. Ketik perintah:

```bash
pip install -r requirements.txt
```

4. Tunggu proses install (5-10 menit)

**Output yang muncul:**
```
Collecting PyQt6==6.6.1
  Downloading PyQt6-6.6.1-cp39-cp39-win_amd64.whl
...
Successfully installed PyQt6-6.6.1 openpyxl-3.1.2 ...
```

#### 3. Generate Excel Template

**Langkah-langkah:**
```bash
python src/template_generator.py
```

**Output:**
```
Generating BPS Master Data Template...
✅ Template created: BPS_Master_Data_Template.xlsx
   Sheets: 11
   Categories: 10
   Years: 2020, 2021, 2022, 2023, 2024, 2025, 2026
   Cities (SDGs): 35
```

#### 4. Build Executable (Buat .exe)

**Langkah-langkah:**
```bash
./build.sh
```

**Atau manual:**
```bash
pyinstaller --name "BPS_Data_Uploader" --onefile --windowed src/main.py
```

**Output:**
```
✅ Build successful!
📁 Output file: dist/BPS_Data_Uploader.exe
```

**File yang dihasilkan:**
- `BPS_Data_Uploader.exe` (sekitar 50-80 MB)
- `BPS_Master_Data_Template.xlsx`

#### 5. Distribute ke Staff

Copy 2 file ini ke PC staff:
1. `BPS_Data_Uploader.exe`
2. `BPS_Master_Data_Template.xlsx`

---

### B. Untuk Staff (Persiapan Token GitHub)

#### 1. Buat Akun GitHub

**Jika belum punya:**
1. Buka https://github.com
2. Klik "Sign up"
3. Isi email, password, username
4. Verifikasi email
5. Selesaikan setup profil

#### 2. Buat Personal Access Token

**Langkah-langkah Detail:**

**Step 1:** Login ke GitHub
- Buka https://github.com
- Login dengan akun Anda

**Step 2:** Buka Settings
- Klik foto profil (pojok kanan atas)
- Pilih "Settings"

**Step 3:** Developer Settings
- Scroll ke bawah, klik "Developer settings" (di sidebar kiri)

**Step 4:** Personal Access Tokens
- Klik "Personal access tokens"
- Pilih "Tokens (classic)"

**Step 5:** Generate New Token
- Klik tombol "Generate new token (classic)"
- Note: `BPS Data Upload`
- Expiration: Pilih "No expiration" (atau sesuai kebutuhan)

**Step 6:** Pilih Scope
- Scroll ke bagian "Select scopes"
- Centang: ☑️ `repo` (Full control of private repositories)
- (Ini memberikan akses untuk upload file ke repo)

**Step 7:** Generate
- Scroll ke bawah
- Klik "Generate token"

**Step 8:** Copy Token
- **PENTING:** Token hanya muncul sekali!
- Klik icon copy (📋)
- Simpan di tempat aman (Notepad, password manager, dll)
- Format token: `ghp_xxxxxxxxxxxxxxxxxxxx`

**Contoh token:**
```
ghp_aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890
```

⚠️ **PERINGATAN KEAMANAN:**
- Token ini seperti password
- Jangan share ke siapapun
- Jangan upload ke internet
- Simpan di PC lokal saja
- Jika bocor/belum disimpan: Generate ulang

#### 3. Setup Repository (Developer)

**Pastikan repo sudah ada:**
```
https://github.com/ZekeHyperByte/bps-semarang-data
```

**Struktur repo harusnya:**
```
bps-semarang-data/
├── data/
│   ├── pertumbuhan_ekonomi.json
│   ├── inflasi.json
│   ├── tenaga_kerja.json
│   ├── kemiskinan.json
│   ├── penduduk.json
│   ├── pendidikan.json
│   ├── ipm.json
│   ├── ipg.json
│   ├── idg.json
│   └── sdgs.json
├── version.txt
└── README.md
```

---

## 👨‍💼 TUTORIAL STAFF - STEP BY STEP

### Skenario: Update Data Februari 2024

#### Step 1: Buka Excel Template

**Langkah-langkah:**
1. Buka folder tempat Anda menyimpan file
2. Double-click `BPS_Master_Data_Template.xlsx`
3. Microsoft Excel akan terbuka

**Yang Anda lihat:**
- 11 sheet tabs di bagian bawah
- Sheet "Petunjuk" terbuka pertama kali

#### Step 2: Pilih Sheet yang Akan Diupdate

**Contoh:** Update data Inflasi dan SDGs

**Untuk Inflasi:**
1. Klik tab "📉 Inflasi" di bagian bawah
2. Anda akan melihat tabel dengan kolom tahun

**Tampilan:**
```
| Komponen                    | 2020 | 2021 | 2022 | 2023 | 2024 | 2025 |
|-----------------------------|------|------|------|------|------|------|
| Inflasi Umum (%)            |      |      |      |      |      |      |
| Inflasi Inti (%)            |      |      |      |      |      |      |
| ...                         |      |      |      |      |      |      |
```

**Untuk SDGs:**
1. Klik tab "🎯 SDGs"
2. Tabel besar dengan 35 kota muncul

**Tampilan:**
```
| Kota/Kabupaten   | Indikator      | 2020 | 2021 | 2022 | 2023 | 2024 |
|------------------|----------------|------|------|------|------|------|
| Kab. Cilacap     | Samitasilayak  |      |      |      |      |      |
|                  | TIK Remaja     |      |      |      |      |      |
|                  | TIK Dewasa     |      |      |      |      |      |
|                  | ...            |      |      |      |      |      |
| Kab. Banyumas    | Samitasilayak  |      |      |      |      |      |
|                  | ...            |      |      |      |      |      |
```

#### Step 3: Isi Data

**Cara mengisi:**
1. Klik sel yang ingin diisi (contoh: kolom 2024, baris Inflasi Umum)
2. Ketik angka (contoh: `4.25`)
3. Tekan Tab atau Enter untuk pindah sel
4. Ulangi untuk semua data

**Tips:**
- Gunakan titik (.) untuk desimal, bukan koma (,)
  - ✅ Benar: `4.25`
  - ❌ Salah: `4,25`
- Kosongkan sel yang tidak ada datanya
- Untuk ribuan, tulis langsung angkanya (tidak perlu koma)
  - Contoh: 1650000 (bukan 1,650,000)

**Contoh pengisian Inflasi:**
```
| Komponen                    | 2020 | 2021 | 2022 | 2023 | 2024 |
|-----------------------------|------|------|------|------|------|
| Inflasi Umum (%)            | 3.2  | 4.1  | 5.8  | 3.5  | 4.25 |
| Inflasi Inti (%)            | 2.8  | 3.5  | 4.2  | 3.1  | 3.85 |
| ...                         | ...  | ...  | ...  | ...  | ...  |
```

**Contoh pengisian SDGs (beberapa kota):**
```
| Kota/Kabupaten   | Indikator      | 2022  | 2023  | 2024  |
|------------------|----------------|-------|-------|-------|
| Kab. Cilacap     | Samitasilayak  | 78.73 | 80.18 | 87.02 |
|                  | TIK Remaja     | 96.20 | 97.35 | 96.56 |
| Kab. Banyumas    | Samitasilayak  | 81.35 | 85.11 | 87.69 |
|                  | TIK Remaja     | 98.10 | 97.46 | 98.90 |
```

#### Step 4: Simpan File

**Cara menyimpan:**
1. Tekan `Ctrl + S` (keyboard shortcut)
2. Atau klik File → Save
3. Tunggu sampai icon save hilang dari title bar

**Verifikasi:**
- Pastikan tidak ada tanda "*" di title bar Excel
- Title seharusnya: `BPS_Master_Data_Template.xlsx - Saved`

#### Step 5: Jalankan BPS Data Uploader

**Langkah-langkah:**
1. Minimize atau tutup Excel
2. Buka folder tempat `BPS_Data_Uploader.exe` disimpan
3. Double-click `BPS_Data_Uploader.exe`
4. Aplikasi akan terbuka

**Tampilan aplikasi:**
```
┌──────────────────────────────────────────────────────────┐
│  📊 BPS DATA UPLOADER                                    │
│  Upload Data Statistik ke GitHub                         │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  Langkah 1: Pilih File Excel                             │
│  ┌──────────────────────────────────────────────────┐   │
│  │ Belum ada file dipilih                    [Browse]│   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ...                                                     │
└──────────────────────────────────────────────────────────┘
```

#### Step 6: Pilih File Excel

**Langkah-langkah:**
1. Klik tombol "📁 Browse..." (warna hijau)
2. File dialog akan muncul
3. Navigasi ke folder tempat Excel disimpan
4. Pilih `BPS_Master_Data_Template.xlsx`
5. Klik "Open"

**Yang terjadi:**
- Nama file muncul di sebelah kiri
- Warna teks berubah jadi hijau
- Checkbox kategori aktif
- Preview data muncul di panel kanan

#### Step 7: Pilih Kategori

**Langkah-langkah:**
1. Lihat bagian "Langkah 2: Pilih Kategori"
2. Anda akan melihat 10 checkbox:
   - ☑️ 📈 Pertumbuhan Ekonomi
   - ☑️ 📉 Inflasi
   - ☑️ 👷 Tenaga Kerja
   - ... (dan seterusnya)

3. Defaultnya semua tercentang
4. **Jika hanya update beberapa kategori:**
   - Klik "Batal Pilih Semua"
   - Centang hanya yang diupdate
   - Contoh: Hanya centang "📉 Inflasi" dan "🎯 SDGs"

**Contoh hanya update Inflasi dan SDGs:**
```
☐ 📈 Pertumbuhan Ekonomi
☑️ 📉 Inflasi              ← Diupdate
☐ 👷 Tenaga Kerja
☐ 🏠 Kemiskinan
☐ 👥 Penduduk
☐ 🎓 Pendidikan
☐ 📊 IPM
☐ 👫 IPG
☐ ⚖️ IDG
☑️ 🎯 SDGs                ← Diupdate
```

#### Step 8: Validasi Data

**Langkah-langkah:**
1. Klik tombol "✅ Validasi Data" (warna biru)
2. Tunggu proses validasi (5-10 detik)

**Hasil validasi:**

**Jika Valid ✅**
```
Log:
[14:30:15] 🔍 Memvalidasi data...
[14:30:16] ✅ pertumbuhan_ekonomi: Valid
[14:30:16] ✅ inflasi: Valid
[14:30:16] ✅ tenaga_kerja: Valid
[14:30:16] ✅ kemiskinan: Valid
[14:30:16] ✅ penduduk: Valid
[14:30:16] ✅ pendidikan: Valid
[14:30:16] ✅ ipm: Valid
[14:30:16] ✅ ipg: Valid
[14:30:16] ✅ idg: Valid
[14:30:17] ✅ sdgs: Valid
```

Popup muncul: "✅ Semua data valid!"

**Jika Ada Warning ⚠️**
```
[14:30:16] ✅ inflasi: Valid
[14:30:16] ⚠️ sdgs: Valid
[14:30:16]    ⚠️ Kab. Pekalongan - APK 2024: Value 157.63 seems very high
```

Warning masih bisa dilanjutkan, tapi periksa dulu.

**Jika Ada Error ❌**
```
[14:30:16] ❌ inflasi: Error
[14:30:16]    - Inflasi Umum 2024: Negative value (-2.5)
```

Popup muncul: "❌ Ada error pada data. Periksa log."

**Action:** Perbaiki di Excel, save, lalu validasi ulang.

#### Step 9: Masukkan GitHub Token

**Langkah-langkah:**
1. Scroll ke bagian "Langkah 4: Upload ke GitHub"
2. Lihat field "GitHub Token:"
3. Paste token yang sudah dibuat
   - Buka Notepad tempat menyimpan token
   - Copy token (Ctrl+C)
   - Klik field GitHub Token
   - Paste (Ctrl+V)

**Tampilan:**
```
GitHub Token: [********************************]
```

(Karakter disembunyikan untuk keamanan)

#### Step 10: Pesan Commit

**Langkah-langkah:**
1. Lihat field "Pesan Commit:"
2. Defaultnya: `Update data Februari 2024`
3. Bisa diubah sesuai kebutuhan

**Contoh pesan:**
- `Update data Februari 2024`
- `Revisi data kemiskinan 2024`
- `Tambah data SDGs tahun 2025`
- `Update inflasi Januari-Maret 2024`

**Tips:** Tulis pesan yang deskriptif agar mudah tracking perubahan.

#### Step 11: Upload ke GitHub

**Langkah-langkah:**
1. Klik tombol "🚀 Upload ke GitHub" (warna orange)
2. Konfirmasi dialog muncul

**Tampilan konfirmasi:**
```
Konfirmasi Upload

Anda akan mengupload 2 kategori ke GitHub.

Kategori: inflasi, sdgs
Pesan: Update data Februari 2024

Lanjutkan?

[Yes] [No]
```

3. Klik "Yes"
4. Tunggu proses upload (30 detik - 2 menit)

**Progress yang terlihat:**
```
[14:35:20] 🚀 Memulai upload ke GitHub...
[14:35:20] 🔒 Lock dibuat, memulai upload...
[14:35:21] Uploading inflasi (1/2)...
[14:35:25] ✅ inflasi: Uploaded successfully
[14:35:25] Uploading sdgs (2/2)...
[14:35:45] ✅ sdgs: Uploaded successfully
[14:35:45] 🔒 Lock dihapus.
```

**Progress bar:**
- Bergerak selama upload
- Hilang setelah selesai

#### Step 12: Selesai!

**Jika Sukses ✅**

Popup muncul:
```
Sukses

✅ Berhasil mengupload 2/2 kategori!
```

Log:
```
[14:35:45] ✅ Berhasil mengupload 2/2 kategori!
```

**Status:**
- Progress bar hilang
- Log menunjukkan semua sukses
- Data sudah di GitHub!

**Jika Gagal ❌**

Popup muncul:
```
Error

❌ Upload failed: Authentication error
```

**Kemungkinan penyebab:**
- Token salah/expired
- Tidak ada internet
- Repository tidak ditemukan

**Action:** Periksa token, cek koneksi internet, coba lagi.

#### Step 13: Verifikasi di GitHub (Opsional)

**Cara cek:**
1. Buka browser
2. Buka https://github.com/ZekeHyperByte/bps-semarang-data
3. Lihat file di folder `data/`
4. Cek `version.txt` - harusnya sudah terupdate
5. Cek timestamp commit terbaru

**Contoh yang benar:**
```
Latest commit: 2 minutes ago
Update data Februari 2024 - inflasi
```

#### Step 14: Tunggu Aplikasi Mobile Update

**Timeline:**
- **Immediate:** Data sudah di GitHub ✅
- **1-5 menit:** Aplikasi mobile akan fetch data baru (saat user buka app)
- **User experience:** Data otomatis terupdate tanpa update app!

**Tidak perlu:**
- ❌ Upload ke Play Store
- ❌ Tunggu review 2-7 hari
- ❌ User download update

---

## 📊 FORMAT EXCEL DETAIL

### Sheet 1: Petunjuk
- Panduan penggunaan
- Keterangan warna
- Daftar kategori

### Sheet 2: Pertumbuhan Ekonomi

**Struktur:**
| Indikator | 2020 | 2021 | 2022 | 2023 | 2024 | 2025 | 2026 |
|-----------|------|------|------|------|------|------|------|
| Pertumbuhan Ekonomi (%) | | | | | | | |
| Kontribusi PDRB (%) | | | | | | | |
| Sektor Perdagangan (%) | | | | | | | |
| PDRB Per Kapita (Juta Rupiah) | | | | | | | |
| Rank di Jawa Tengah | | | | | | | |
| TPT Nasional (%) | | | | | | | |

**Keterangan:**
- Rank: Angka 1-35 (atau 0 jika tidak ada)
- Persentase: Format desimal (contoh: 5.62)

### Sheet 3: Inflasi

**Struktur:**
| Komponen | 2020 | 2021 | 2022 | 2023 | 2024 | 2025 | 2026 |
|----------|------|------|------|------|------|------|------|
| Inflasi Umum (%) | | | | | | | |
| Inflasi Inti (%) | | | | | | | |
| IHK (Indeks) | | | | | | | |
| Makanan, Minuman & Tembakau | | | | | | | |
| Pakaian & Alas Kaki | | | | | | | |
| Perumahan & Fasilitas | | | | | | | |
| Perlengkapan & Perawatan Rumah | | | | | | | |
| Kesehatan | | | | | | | |
| Transportasi | | | | | | | |
| Informasi, Komunikasi & Keuangan | | | | | | | |
| Rekreasi, Olahraga & Budaya | | | | | | | |
| Pendidikan | | | | | | | |
| Penyediaan Makanan & Minuman | | | | | | | |
| Perawatan Pribadi & Jasa Lainnya | | | | | | | |

### Sheet 4-10: Format Serupa

Setiap sheet memiliki pola yang sama:
- Kolom 1: Nama indikator
- Kolom 2-8: Tahun 2020-2026

### Sheet 11: SDGs (Special Format)

**Struktur:**
```
| Kota/Kabupaten | Indikator | 2020 | 2021 | 2022 | 2023 | 2024 | 2025 | 2026 |
|----------------|-----------|------|------|------|------|------|------|------|
| Kab. Cilacap | Samitasilayak (%) | | | | | | | |
| | TIK Remaja (%) | | | | | | | |
| | TIK Dewasa (%) | | | | | | | |
| | Akta Lahir (%) | | | | | | | |
| | APM (%) | | | | | | | |
| | APK (%) | | | | | | | |
| Kab. Banyumas | Samitasilayak (%) | | | | | | | |
| | ... | | | | | | | |
```

**Total:** 35 kota × 6 indikator = 210 baris

**Daftar 35 Kota/Kabupaten:**
1. Kab. Cilacap
2. Kab. Banyumas
3. Kab. Purbalingga
4. Kab. Banjarnegara
5. Kab. Kebumen
6. Kab. Purworejo
7. Kab. Wonosobo
8. Kab. Magelang
9. Kab. Boyolali
10. Kab. Klaten
11. Kab. Sukoharjo
12. Kab. Wonogiri
13. Kab. Karanganyar
14. Kab. Sragen
15. Kab. Grobogan
16. Kab. Blora
17. Kab. Rembang
18. Kab. Pati
19. Kab. Kudus
20. Kab. Jepara
21. Kab. Demak
22. Kab. Semarang
23. Kab. Temanggung
24. Kab. Kendal
25. Kab. Batang
26. Kab. Pekalongan
27. Kab. Pemalang
28. Kab. Tegal
29. Kab. Brebes
30. Kota Magelang
31. Kota Surakarta
32. Kota Salatiga
33. Kota Semarang
34. Kota Pekalongan
35. Kota Tegal

---

## 🔧 TROUBLESHOOTING

### Masalah 1: "Module not found"

**Pesan Error:**
```
ModuleNotFoundError: No module named 'PyQt6'
```

**Penyebab:** Dependencies belum terinstall

**Solusi:**
```bash
pip install -r requirements.txt
```

### Masalah 2: "GitHub authentication failed"

**Pesan Error:**
```
❌ Authentication failed: Bad credentials
```

**Penyebab:**
- Token salah
- Token expired
- Token tidak punya akses repo

**Solusi:**
1. Periksa token di https://github.com/settings/tokens
2. Pastikan token masih aktif (not expired)
3. Pastikan scope "repo" terchecklist
4. Generate token baru jika perlu
5. Copy token baru ke aplikasi

### Masalah 3: "Upload locked"

**Pesan Error:**
```
⚠️ Upload sedang berlangsung oleh PC-STAFF-01 - Windows. Silakan tunggu.
```

**Penyebab:**
- Staff lain sedang upload
- Upload sebelumnya crash/tidak selesai

**Solusi:**

**Option A: Tunggu (Recommended)**
- Tunggu 10 menit
- Lock akan auto-expire
- Coba upload lagi

**Option B: Hapus Lock Manual (Jika yakin tidak ada yang upload)**
1. Buka https://github.com/ZekeHyperByte/bps-semarang-data
2. Cari file `.upload_lock`
3. Klik file → Delete
4. Commit message: "Remove stale lock"
5. Coba upload lagi

### Masalah 4: "Excel file not readable"

**Pesan Error:**
```
❌ Error: File is not a valid Excel file
```

**Penyebab:**
- File corrupt
- Format bukan .xlsx
- File masih terbuka di Excel (locked)

**Solusi:**
1. Tutup Excel
2. Pastikan file extension .xlsx (bukan .xls)
3. Coba buka file dengan Excel
4. Jika bisa dibuka: File → Save As → Pilih format .xlsx
5. Jika tidak bisa dibuka: Generate template baru

### Masalah 5: "Validasi gagal untuk [kategori]"

**Pesan Error:**
```
❌ inflasi: Error
   - Inflasi Umum 2024: Negative value (-2.5)
```

**Penyebab:** Ada error dalam data

**Solusi:**
1. Catat indikator dan tahun yang error
2. Buka Excel
3. Cari sel yang bermasalah
4. Perbaiki nilai
5. Save
6. Validasi ulang

**Validasi yang dilakukan:**
- ❌ Nilai negatif (error)
- ⚠️ Persentase > 100% (warning)
- ⚠️ Nilai > 150 (warning)

### Masalah 6: Aplikasi tidak terbuka

**Gejala:** Double-click .exe tapi tidak muncul

**Penyebab:**
- Antivirus blocking
- Windows Defender blocking
- File corrupt

**Solusi:**
1. Cek antivirus → Add exception untuk BPS_Data_Uploader.exe
2. Windows Security → Virus & threat protection → Exclusions
3. Rebuild executable: `./build.sh`

### Masalah 7: "No such file or directory"

**Pesan Error:**
```
FileNotFoundError: [Errno 2] No such file or directory: 'BPS_Master_Data_Template.xlsx'
```

**Penyebab:** File Excel dipindah/dihapus

**Solusi:**
1. Browse ulang file Excel
2. Pastikan file ada di lokasi yang benar
3. Jika tidak ada: Generate template baru

---

## ❓ FAQ

### Q1: Apakah bisa upload sebagian kategori saja?

**A:** Ya! Pada Step 7, centang hanya kategori yang ingin diupdate. Kategori lainnya tidak akan terupload.

### Q2: Apakah bisa update data tahun lalu?

**A:** Ya! Isi data di kolom tahun yang sesuai. Sistem mendukung update data historis.

### Q3: Bagaimana jika ada data yang salah setelah upload?

**A:**
1. Perbaiki di Excel
2. Upload ulang ke GitHub
3. Aplikasi mobile akan otomatis update dalam 1-5 menit

### Q4: Apakah bisa upload dari laptop yang berbeda?

**A:** Ya! Asalkan:
- Ada file Excel yang sama/terbaru
- Ada aplikasi BPS_Data_Uploader.exe
- Ada GitHub Token yang valid

### Q5: Berapa lama data terupdate di aplikasi mobile?

**A:**
- **Immediate:** Data di GitHub terupdate
- **1-5 menit:** Aplikasi mobile fetch data baru (saat user buka app)
- **Real-time:** Jika user sudah buka app, pull-to-refresh untuk update

### Q6: Apakah perlu internet untuk menggunakan aplikasi?

**A:**
- **Edit Excel:** Tidak perlu internet
- **Upload ke GitHub:** Perlu internet
- **Aplikasi mobile fetch data:** Perlu internet (pertama kali), setelahnya bisa offline

### Q7: Apakah data bisa hilang?

**A:** Tidak, karena:
- GitHub menyimpan history semua perubahan
- Bisa rollback ke versi sebelumnya
- Setiap upload membuat commit baru
- Data tersimpan di cloud (GitHub)

### Q8: Bagaimana jika lupa GitHub Token?

**A:**
1. Buka GitHub.com → Settings → Developer settings
2. Tokens (classic)
3. Generate token baru
4. Simpan dengan aman
5. Token lama bisa di-delete

### Q9: Apakah bisa upload bersamaan dari 2 PC?

**A:** Tidak bisa simultan. Lock system akan:
- PC pertama: Upload berhasil
- PC kedua: Muncul pesan "Upload sedang berlangsung, silakan tunggu"
- PC kedua harus tunggu 10 menit atau sampai PC pertama selesai

### Q10: Bagaimana cara tahu versi data terbaru?

**A:**
1. Buka https://github.com/ZekeHyperByte/bps-semarang-data
2. Lihat file `version.txt`
3. Format: `2024.02.20-143022`
4. Atau lihat latest commit timestamp

---

## 📚 REFERENSI CEPAT

### Keyboard Shortcuts

| Shortcut | Fungsi |
|----------|--------|
| `Ctrl + S` | Save Excel file |
| `Ctrl + C` | Copy |
| `Ctrl + V` | Paste |
| `Tab` | Pindah ke sel berikutnya (Excel) |
| `Enter` | Konfirmasi dialog (Uploader) |
| `Esc` | Cancel/Batal |

### Format Angka

| Tipe Data | Contoh Benar | Contoh Salah |
|-----------|--------------|--------------|
| Persentase | `5.62` | `5,62` atau `5.62%` |
| Ribuan | `1650` | `1,650` atau `1.650` |
| Desimal | `87.02` | `87,02` |
| Index | `0.59` | `0,59` |

### Frekuensi Update per Kategori

| Kategori | Frekuensi | Keterangan |
|----------|-----------|------------|
| Inflasi | Bulanan | Update setiap bulan |
| Tenaga Kerja | Triwulanan | Q1, Q2, Q3, Q4 |
| Pertumbuhan Ekonomi | Triwulanan | Q1, Q2, Q3, Q4 |
| Lainnya | Tahunan | Update 1x per tahun |

### Contact Support

**Jika ada masalah:**
1. Cek log aplikasi
2. Screenshot error
3. Hubungi tim IT BPS
4. Sertakan: pesan error, langkah yang dilakukan, file Excel (jika perlu)

---

## 📝 CHECKLIST STAFF

Sebelum upload, pastikan:

- [ ] Excel file sudah diisi dengan benar
- [ ] Tidak ada nilai negatif (untuk indikator positif)
- [ ] Format angka menggunakan titik (.) bukan koma (,)
- [ ] File sudah di-save (Ctrl+S)
- [ ] Sudah memilih kategori yang benar
- [ ] Validasi data berhasil
- [ ] GitHub Token sudah dimasukkan
- [ ] Pesan commit sudah sesuai
- [ ] Koneksi internet stabil
- [ ] Tidak ada staff lain yang sedang upload

---

**Selamat menggunakan BPS Data Uploader! 🎉**

**Versi:** 1.0.0  
**Dokumen ini diupdate:** Februari 2024  
**Untuk update dokumentasi:** Hubungi tim IT BPS
