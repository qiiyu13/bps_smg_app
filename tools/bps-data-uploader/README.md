# 📊 BPS Data Uploader

Aplikasi desktop untuk upload data statistik BPS ke GitHub secara mudah.

## 🎯 Fitur Utama

- ✅ **Excel Template** - Format Excel yang familiar untuk BPS staff
- ✅ **Validasi Data** - Deteksi error sebelum upload
- ✅ **Preview Data** - Lihat data sebelum upload
- ✅ **Lock System** - Mencegah upload bersamaan
- ✅ **10 Kategori** - Semua kategori statistik BPS
- ✅ **Auto Versioning** - Versi otomatis dengan timestamp

## 📁 Struktur File

```
bps-data-uploader/
├── src/
│   ├── main.py                 # Aplikasi GUI utama
│   ├── template_generator.py   # Generator Excel template
│   ├── excel_reader.py         # Reader untuk Excel BPS
│   └── github_publisher.py     # Upload ke GitHub
├── requirements.txt            # Dependencies
├── build.sh                    # Script build .exe
└── README.md                   # Dokumentasi ini
```

## 🚀 Cara Menggunakan

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Generate Excel Template

```bash
python src/template_generator.py
```

Ini akan membuat file `BPS_Master_Data_Template.xlsx` dengan 10 sheet kategori.

### 3. Jalankan Aplikasi

```bash
python src/main.py
```

### 4. Build Executable (Windows)

```bash
./build.sh
```

Atau manual dengan PyInstaller:
```bash
pyinstaller --name "BPS_Data_Uploader" --onefile --windowed src/main.py
```

## 📋 Workflow BPS Staff

```
1. Buka BPS_Master_Data_Template.xlsx
2. Isi data pada kolom tahun yang sesuai
3. Simpan file (Ctrl+S)
4. Jalankan BPS_Data_Uploader.exe
5. Pilih file Excel
6. Pilih kategori yang akan diupload
7. Klik "Validasi Data"
8. Masukkan GitHub Token
9. Klik "Upload ke GitHub"
10. Selesai! ✅
```

## 🔐 GitHub Token

Staff perlu membuat **Personal Access Token** dari GitHub:

1. Login ke GitHub.com
2. Settings → Developer settings → Personal access tokens → Tokens (classic)
3. Generate new token (classic)
4. Beri nama: "BPS Data Upload"
5. Centang: `repo` (full control)
6. Generate dan copy token
7. Paste ke aplikasi BPS Data Uploader

**Token harus disimpan dengan aman!**

## 📊 Kategori Data

| Sheet | Kategori | Frekuensi |
|-------|----------|-----------|
| Pertumbuhan_Ekonomi | Pertumbuhan Ekonomi | Triwulanan |
| Inflasi | Inflasi | Bulanan |
| Tenaga_Kerja | Ketenagakerjaan | Triwulanan |
| Kemiskinan | Kemiskinan | Tahunan |
| Penduduk | Penduduk | Tahunan |
| Pendidikan | Pendidikan | Tahunan |
| IPM | Indeks Pembangunan Manusia | Tahunan |
| IPG | Indeks Pembangunan Gender | Tahunan |
| IDG | Indeks Ketimpangan Gender | Tahunan |
| SDGs | Sustainable Development Goals | Tahunan |

## 🛠️ Technical Details

### Stack
- **GUI**: PyQt6
- **Excel**: openpyxl, pandas
- **GitHub**: PyGithub
- **Build**: PyInstaller

### Lock System
- File `.upload_lock` dibuat di GitHub saat upload berlangsung
- Lock auto-expire setelah 10 menit
- Staff lain akan lihat pesan: "Upload sedang berlangsung..."

### Versioning
- Format: `YYYY.MM.DD-HHMMSS`
- Contoh: `2024.02.20-143022`
- Disimpan di `version.txt`

## 📝 Excel Format

### Format Umum (Semua kategori kecuali SDGs)
```
| Indikator          | 2020  | 2021  | 2022  | 2023  | 2024  |
|--------------------|-------|-------|-------|-------|-------|
| Jumlah Penduduk    | 1650  | 1670  | 1690  | 1710  | 1730  |
| Persentase         | 4.5   | 4.3   | 4.1   | 3.9   | 3.7   |
```

### Format SDGs (35 Kota)
```
| Kota            | Indikator      | 2020  | 2021  | 2022  |
|-----------------|----------------|-------|-------|-------|
| Kab. Cilacap    | Samitasilayak  | 81.07 | 75.59 | 78.73 |
|                 | TIK Remaja     | 95.60 | 93.99 | 96.20 |
| Kab. Banyumas   | Samitasilayak  | 85.81 | 86.79 | 81.35 |
```

## ⚠️ Validasi

Aplikasi akan memvalidasi:
- ✅ Nilai negatif (error)
- ✅ Persentase > 100% (warning)
- ✅ Nilai > 150 (warning)
- ✅ Format angka

## 🔧 Troubleshooting

### "Module not found"
```bash
pip install -r requirements.txt
```

### "GitHub authentication failed"
- Periksa GitHub Token
- Pastikan token masih aktif
- Pastikan token punya akses `repo`

### "Upload locked"
- Tunggu 10 menit (lock auto-expire)
- Atau hapus file `.upload_lock` manual di GitHub

### "Excel file not readable"
- Pastikan file .xlsx (bukan .xls)
- Pastikan tidak corrupt
- Coba buka dan save ulang dengan Excel

## 📞 Support

Hubungi tim IT BPS jika ada kendala.

## 📄 License

Internal BPS use only.

---

**Dibuat untuk:** BPS Kota Semarang  
**Versi:** 1.0.0  
**Tanggal:** Februari 2024
