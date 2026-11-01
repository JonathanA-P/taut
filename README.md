# TAUT — Ruang untuk Saling Memahami

**Aplikasi Aksesibilitas Komunikasi Dua Arah (BISINDO & Suara), Pencarian Fasilitas Kesehatan, dan Berbagi Lokasi Berbasis Persetujuan**  
Dikembangkan oleh **Tim Mardua Holong** — Universitas Brawijaya untuk **INCEPTION 2026 Hackathon**.

---

## Unduhan Langsung & Tautan Pengumpulan

- **Executable APK (Android ARM64 Release):** [Unduh `app-release.apk`](https://github.com/JonathanA-P/taut/raw/main/build/app/outputs/flutter-apk/app-release.apk)
- **GitHub Release (`submission-24h`):** [https://github.com/JonathanA-P/taut/releases/tag/submission-24h](https://github.com/JonathanA-P/taut/releases/tag/submission-24h)
- **Repository GitHub (Public):** [https://github.com/JonathanA-P/taut](https://github.com/JonathanA-P/taut)

---

## 1. Gambaran Umum Produk

**TAUT** adalah ruang komunikasi inklusif yang menjembatani interaksi harian antara **Teman Tuli/Disabilitas Wicara** dan **Teman Dengar**, sekaligus mempermudah akses ke fasilitas kesehatan terdekat serta berbagi lokasi darurat/harian dengan kerabat secara aman dan berbasis persetujuan (*consent-first*).

### Fitur Utama

1. **Komunikasi Dua Arah (Isyarat BISINDO ↔ Suara & Teks)**
   - **Isyarat ke Suara (*Motion-to-Sound*):** Deteksi bahasa isyarat BISINDO (*Kata*, *Abjad A–Z*, dan *Angka*) secara *on-device* menggunakan kamera dan model TensorFlow Lite (`bisindo_model.tflite`), dilengkapi penyusun kalimat otomatis dan *Text-to-Speech* (TTS) Bahasa Indonesia.
   - **Ucapan ke Teks (*Speech-to-Text*):** Transkripsi suara lawan bicara secara *real-time* menjadi teks berukuran jelas dan mudah dibaca di layar, disertai balasan cepat (*quick replies*).
   - **Ruangan Obrolan Jarak Jauh (*Communication Room*):** Pembuatan dan penggabungan ruang obrolan menggunakan kode unik (`TAUT-XXXX`) atau QR dengan kapasitas hingga 10 peserta dan pengaturan persetujuan *host* (*auto-accept* / manual).

2. **Pencari Fasilitas Kesehatan (*Healthcare Finder*) & Peta Interaktif**
   - Peta interaktif berbasis `flutter_map` & OpenStreetMap yang mendeteksi posisi GPS pengguna secara otomatis.
   - *Live scraping* fasilitas kesehatan terdekat (Rumah Sakit, Puskesmas, Klinik, Apotek) secara *real-time* melalui **OpenStreetMap Overpass API** dan pencarian alamat global melalui **Nominatim Geocoding API**.
   - Navigasi rute langsung dan fitur berbagi lokasi darurat ke fasilitas kesehatan.

3. **Berbagi Lokasi Berbasis Persetujuan (*Consent-First Location Sharing*)**
   - Manajemen daftar teman terhubung menggunakan *username* unik (`@handle`) yang tersinkronisasi dengan Supabase.
   - Berbagi lokasi *real-time* dengan batas waktu otomatis (*time-boxed*: 15 menit, 1 jam, 4 jam) yang dapat dihentikan kapan saja dalam satu ketukan.
   - Persetujuan eksplisit (*Setuju* / *Tolak*) untuk setiap sesi berbagi lokasi yang masuk.

4. **Autentikasi Berlapis (Email, Google OAuth, & Verifikasi OTP 6-Digit)**
   - Pendaftaran dan masuk menggunakan Email & Kata Sandi maupun **Google OAuth SSO** (`io.supabase.taut://login-callback`) dengan pemilihan akun Google.
   - Verifikasi keamanan **Kode OTP 6-Digit** yang dikirimkan melalui SMTP ke email pengguna sebelum mengakses ruang akun.
   - **Mode Tamu (*Guest Mode*):** Memungkinkan pengguna langsung menggunakan fitur darurat (Komunikasi Dua Arah & Pencari Faskes) tanpa wajib membuat akun terlebih dahulu.

---

## 2. Arsitektur & Teknologi

```text
lib/
├── app.dart                  # Konfigurasi MaterialApp & routing utama
├── main.dart                 # Entry point aplikasi
├── bootstrap/                # Inisialisasi Supabase, environment, & orientasi perangkat
├── core/                     # Tema visual, konstanta, router, error handling, & layanan izin
├── shared/                   # State aplikasi terpusat (TautAppState), model data, & komponen UI modular
└── features/
    ├── auth/                 # Welcome, Onboarding, Register, Login, Google OAuth, OTP 6-Digit, & Profil
    ├── home/                 # Beranda & navigasi shell bawah (HomeShellScreen)
    ├── communication/        # Hub Komunikasi, Speech-to-Text, Motion-to-Sound (TFLite BISINDO), & Room
    ├── healthcare/           # Pencari Faskes (Overpass & Nominatim API) & peta interaktif
    ├── location_sharing/     # Berbagi lokasi real-time berbatas waktu & ke Faskes
    ├── friends/              # Daftar teman, permintaan pertemanan, & peta lokasi teman
    └── privacy/              # Pusat kendali privasi & izin perangkat
```

- **Frontend & Mobile Framework:** Flutter (Dart SDK `^3.11.0`, Material 3)
- **Backend & Database:** Supabase (PostgreSQL dengan *Row Level Security* / RLS, Supabase Auth, SMTP OTP, & Realtime)
- **On-Device Machine Learning:** TensorFlow Lite (`tflite_flutter`) untuk inferensi gerakan tangan dan *landmark* BISINDO secara lokal di perangkat tanpa mengirim video mentah ke server.
- **Peta & Geospasial:** `flutter_map`, `latlong2`, `geolocator`, OpenStreetMap Tile Server, Overpass API, dan Nominatim API.

---

## 3. Cara Menjalankan Proyek dari Source Code

### Prasyarat
- Flutter SDK `>= 3.11.0`
- Android SDK (`compileSdk 36`, Java 17)
- Proyek Supabase aktif (opsional untuk Mode Tamu; wajib untuk Autentikasi, OTP, Teman, dan Berbagi Lokasi)

### Langkah Menjalankan

1. **Clone repositori dan unduh dependensi:**
   ```bash
   git clone https://github.com/JonathanA-P/taut.git
   cd taut
   flutter pub get
   ```

2. **Siapkan konfigurasi `.env` (salin dari `.env.example`):**
   ```bash
   cp .env.example .env
   ```
   Isi `SUPABASE_URL` dan `SUPABASE_PUBLISHABLE_KEY` pada file `.env`. *(Catatan: File `android/app/build.gradle.kts` secara otomatis menyuntikkan variabel `.env` ke dalam `dart-defines` saat proses build).*

3. **Jalankan aplikasi di perangkat atau emulator:**
   ```bash
   flutter run --dart-define-from-file=.env
   ```

4. **Jalankan pengujian otomatis (Unit & Widget Tests):**
   ```bash
   flutter analyze
   flutter test
   ```

5. **Build Release APK:**
   ```bash
   flutter build apk --release --target-platform android-arm64 --dart-define-from-file=.env
   ```

---

## 4. AI Use and Third-Party Declaration

Bagian ini mendeklarasikan secara transparan seluruh penggunaan kecerdasan buatan (AI), model *Machine Learning*, layanan pihak ketiga, API eksternal, dan pustaka *open-source* di dalam proyek **TAUT**.

### A. Penggunaan AI dalam Pengembangan (*AI-Assisted Development*)

Selama siklus pengembangan 24 jam hackathon, tim menggunakan bantuan *AI Coding Assistants* (**Google Gemini / Antigravity** dan **Claude**) sebagai *pair-programming assistant* dengan cakupan berikut:
- **Perancangan Arsitektur & Skema Database:** Membantu menyusun migrasi SQL Supabase (`supabase/migrations/`), kebijakan *Row Level Security* (RLS), serta kontrak repositori Dart.
- **Implementasi UI/UX & Widget Flutter:** Membantu mengimplementasikan komponen antarmuka sesuai desain tim, pembuatan ilustrasi vektor kustom (`CustomPainter`), serta integrasi alur navigasi.
- **Debugging & Pengujian Otomatis:** Membantu menulis dan memverifikasi *widget test* dan *unit test* (`test/`), serta mendiagnosis integrasi OAuth deep-linking dan konfigurasi Gradle.
- **Verifikasi Manusia:** Seluruh kode, logika bisnis, desain produk, konfigurasi keamanan, dan pengujian perangkat fisik ditinjau, diuji, dan divalidasi langsung oleh anggota **Tim Mardua Holong**.

### B. Model AI & Machine Learning di Dalam Aplikasi (*In-App / Runtime AI*)

1. **Model Deteksi Isyarat BISINDO (`assets/models/bisindo_model.tflite` & `hand_landmark_full.tflite`)**
   - **Fungsi:** Mengenali gerakan isyarat tangan BISINDO (*Kata*, *Abjad*, *Angka*) secara *real-time* dari *stream* kamera perangkat.
   - **Eksekusi:** Berjalan **100% *on-device*** menggunakan runtime `tflite_flutter`. Tidak ada rekaman gambar atau video kamera pengguna yang dikirim ke server eksternal demi menjaga privasi pengguna.
2. **Layanan Pengenalan Ucapan & Sintesis Suara Sistem (*On-Device / Platform STT & TTS*)**
   - **Fungsi:** Mengubah ucapan lawan bicara menjadi teks (`speech_to_text`) dan menyuarakan kalimat isyarat pengguna menjadi audio Bahasa Indonesia (`flutter_tts`) menggunakan mesin pengenalan suara bawaan sistem operasi Android.

### C. Layanan Eksternal & API Pihak Ketiga (*Third-Party Services & APIs*)

| Layanan / API | Penyedia | Kegunaan dalam Aplikasi | Lisensi / Ketentuan |
| :--- | :--- | :--- | :--- |
| **Supabase (Auth, Database, Storage)** | Supabase Inc. | Autentikasi pengguna (Email, Google OAuth, OTP), penyimpanan profil, relasi pertemanan, ruangan komunikasi, dan sesi berbagi lokasi dengan proteksi RLS. | Open Source / Free Tier Cloud |
| **Google OAuth 2.0** | Google Cloud Platform | Masuk dan daftar akun menggunakan identitas akun Google pengguna. | Google APIs Terms of Service |
| **OpenStreetMap Tile Server** | OpenStreetMap Contributors | Menampilkan peta visual interaktif pada fitur Pencari Faskes dan Berbagi Lokasi. | ODbL (Open Database License) |
| **Overpass API** | OpenStreetMap Overpass | Mengambil data fasilitas kesehatan nyata (Rumah Sakit, Puskesmas, Klinik, Apotek) di sekitar titik GPS pengguna secara *real-time*. | ODbL / Public API |
| **Nominatim API** | OpenStreetMap Nominatim | Pencarian alamat/wilayah (*geocoding*) untuk mencari fasilitas kesehatan di kota atau area tertentu. | ODbL / Nominatim Usage Policy |

### D. Pustaka Pihak Ketiga Utama (*Third-Party Open-Source Packages*)

Seluruh pustaka pihak ketiga dikelola melalui `pubspec.yaml` dari repositori resmi `pub.dev`:

- **`supabase_flutter` (`^2.9.0`):** SDK klien resmi Supabase untuk autentikasi, database PostgreSQL, dan *realtime subscription* (Lisensi MIT).
- **`tflite_flutter` (`^0.12.1`):** Binding TensorFlow Lite untuk inferensi model bahasa isyarat BISINDO di perangkat (Lisensi Apache-2.0).
- **`camera` (`^0.11.0+2`):** Akses pratinjau dan *frame stream* kamera perangkat untuk fitur Isyarat ke Suara (Lisensi BSD-3-Clause).
- **`speech_to_text` (`^7.0.0`):** Integrasi pengenalan ucapan ke teks untuk fitur Ucapan ke Teks (Lisensi BSD-3-Clause).
- **`flutter_tts` (`^4.2.0`):** Sintesis teks ke suara Bahasa Indonesia untuk menyuarakan hasil terjemahan isyarat (Lisensi MIT).
- **`flutter_map` (`^8.1.1`) & `latlong2` (`^0.9.1`):** Rendering peta interaktif OpenStreetMap dan perhitungan jarak koordinat geospasial (Lisensi BSD-3-Clause / Apache-2.0).
- **`geolocator` (`^14.0.0`) & `permission_handler` (`^12.0.0+1`):** Pembacaan posisi GPS perangkat dan pengelolaan izin akses kamera, mikrofon, serta lokasi (Lisensi MIT).
- **`image_picker` (`^1.1.2`), `share_plus` (`^12.0.0`), `url_launcher` (`^6.3.1`), `http` (`^1.2.2`):** Pemilihan foto profil lokal, pembagian tautan lokasi via *native share sheet*, pembukaan navigasi peta eksternal, dan pemanggilan HTTP REST API (Lisensi BSD-3-Clause / Apache-2.0).

---

## 5. Prinsip Keamanan & Privasi

- **Tanpa *Secret Key* di Klien:** Hanya `SUPABASE_URL` dan `SUPABASE_PUBLISHABLE_KEY` yang digunakan pada aplikasi klien; seluruh tabel dilindungi oleh *Row Level Security* (RLS) di sisi PostgreSQL. File `.env` dikecualikan secara ketat melalui `.gitignore`.
- **Inferensi Kamera Lokal:** Kamera hanya digunakan saat pengguna mengaktifkan fitur Isyarat ke Suara dan diproses secara lokal di memori perangkat.
- **Lokasi Berbasis Persetujuan & Waktu Terbatas:** Pengguna memegang kendali penuh atas siapa yang dapat melihat lokasi mereka dan dapat menghentikan sesi berbagi kapan saja.
