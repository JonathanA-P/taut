# TAUT — Aksesibilitas & Komunikasi Inklusif

> **INCEPTION 2026 Hackathon**  
> **Tim**: Mardua Holong (Universitas Brawijaya)  
> **Anggota Tim**:
> 1. **Alfredo Jonathan Purba** — Team Lead, Backend Architect, Database, Supabase & System Integration
> 2. **Adriel Christo Lumbantoruan** — Flutter Frontend, UI/UX, Navigation & Healthcare Finder
> 3. **Roganda Tua Tampubolon** — Communication AI, Speech Recognition, BISINDO Recognition & TTS

---

## 1. Tentang TAUT

**TAUT** adalah aplikasi aksesibilitas bergerak (Android) yang dirancang untuk meruntuhkan batasan komunikasi bagi penyandang disabilitas rungu (khususnya penutur Bahasa Isyarat Indonesia / BISINDO) ketika berinteraksi dengan masyarakat dengar, serta mempermudah pencarian dan pembagian lokasi fasilitas kesehatan terdekat dalam situasi mendesak.

### Empat Kemampuan Utama:

1. **Komunikasi Dua Arah**:
   - **Suara ke Teks (Speech-to-Text)**: Menangkap ucapan bahasa Indonesia dari masyarakat dengar dan menampilkannya sebagai teks visual yang jelas dan terkonfirmasi untuk teman Tuli.
   - **Gerakan ke Suara (Motion-to-Sound)**: Menangkap isyarat tangan BISINDO melalui kamera ponsel, mengekstraksi titik koordinat tangan (landmarks), mengklasifikasikan kosakata BISINDO (Word-Level), dan membacakannya dalam bentuk audio melalui Text-to-Speech (TTS).
2. **Pencari Fasilitas Kesehatan (Healthcare Finder)**:
   - Mencari rumah sakit, klinik, praktik dokter, dan puskesmas dalam radius 10 kilometer berbasis data terbuka OpenStreetMap (Overpass API) dan koordinat GPS perangkat.
3. **Berbagi Lokasi ke Faskes (Healthcare Location Sharing)**:
   - Membagikan koordinat GPS dan tautan Google Maps ke nomor faskes atau pendamping melalui Android Share Sheet secara aman tanpa membebani database.
4. **Berbagi Lokasi Antar Teman (Friend-to-Friend Live Sharing)**:
   - Berbagi pergerakan lokasi langsung (foreground live location) dengan teman terpercaya yang terhubung melalui kode undangan, dilindungi oleh PostgreSQL Row Level Security (RLS) dan Supabase Realtime.

---

## 2. Arsitektur & Teknologi

- **Mobile Platform**: Flutter 3.47.7 / Dart 3.13.5 (Target Platform: Android)
- **Desain & UI**: Material 3 dengan prinsip kontras tinggi dan aksesibilitas ramah disabilitas
- **Backend**: Supabase (PostgreSQL, Row Level Security, Supabase Realtime, GoTrue Auth)
- **Geospasial & Pemetaan**: OpenStreetMap Overpass API & Haversine Formula (Dart stdlib)
- **Kecerdasan Artifisial (AI)**:
  - Android native SpeechRecognizer (`id-ID`)
  - MediaPipe Hand Landmarker + TensorFlow Lite (TFLite)
  - Android Text-to-Speech (`flutter_tts`)

---

## 3. Prasyarat Sistem

- **Flutter SDK**: Versi >= 3.47.0 (Channel Stable)
- **Dart SDK**: Versi >= 3.13.0
- **Java Development Kit**: JDK 17 atau JDK 21+
- **Android SDK**: API Level 34/35/36 (Build Tools & Platform Tools)
- **Gradle**: 9.x (dikelola otomatis oleh Gradle Wrapper `./android/gradlew`)

---

## 4. Panduan Menjalankan Aplikasi (Setup & Run)

### 4.1. Kloning Repositori & Persiapan Lingkungan
```bash
git clone https://github.com/alfredopurba/taut.git
cd taut
```

### 4.2. Konfigurasi Variabel Lingkungan (`.env`)
Salin file konfigurasi dari template:
```bash
cp .env.example .env
```
Isi nilai variabel `SUPABASE_URL` dan `SUPABASE_PUBLISHABLE_KEY` sesuai proyek Supabase tim Anda.  
*(Catatan: Aplikasi tetap dapat dikompilasi dan dijalankan dalam mode fondasi tanpa kredensial aktif).*

### 4.3. Mengunduh Dependensi & Analisis Kode
```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

### 4.4. Menjalankan di Perangkat Android atau Emulator
Pastikan perangkat Android atau emulator terdeteksi:
```bash
flutter devices
flutter run
```

Untuk membangun file APK rilis debug:
```bash
flutter build apk --debug
```
File APK biner akan tersedia di: `build/app/outputs/flutter-apk/app-debug.apk`.

---

## 5. Struktur Direktori Proyek

```text
lib/
├── app.dart                   # Root MaterialApp & konfigurasi tema
├── bootstrap/                 # Inisialisasi error catching & binding
├── core/
│   ├── config/                # Environment variables & konfigurasi aplikasi
│   ├── constants/             # Warna semantik M3, rute, & konstanta
│   ├── errors/                # Hierarki AppException & Failure
│   ├── permissions/           # Abstraksi perizinan kamera/mikrofon/GPS
│   ├── routing/               # Router navigasi deklaratif
│   ├── theme/                 # Tema Material 3 aksesibel
│   └── utils/                 # Haversine distance calculator (stdlib)
├── features/
│   ├── auth/                  # Otentikasi Supabase & Profil (Alfredo)
│   ├── communication/         # Speech-to-Text & Motion-to-Sound BISINDO (Roganda)
│   ├── friends/               # Manajemen teman & kode undangan (Alfredo)
│   ├── healthcare/            # Pencari faskes OpenStreetMap 10 km (Adriel)
│   ├── home/                  # Bottom navigation shell (4 tab utama)
│   ├── location_sharing/      # Berbagi lokasi faskes & antar teman (Adriel & Alfredo)
│   └── privacy/               # Kebijakan privasi & keamanan data
└── shared/
    ├── models/                # User profile shared model
    └── widgets/               # Loading, Error, AppCard, AppButton, StatusBadge
```

---

## 6. Status Implementasi (Stage 01 — Project Foundation)

- [x] Audit menyeluruh lingkungan dan dependensi Flutter / Android
- [x] Skrip migrasi PostgreSQL dan arsitektur keamanan Row Level Security (`supabase/migrations/`)
- [x] Kontrak integrasi (`INTEGRATION_CONTRACTS.md`) untuk 3 pengembang
- [x] Kerangka navigasi dan placeholder layar dapat diarungi (navigable)
- [x] Pemisahan tegas alur berbagi lokasi faskes vs antar teman
- [x] Pengujian unit Haversine dan smoke test navigasi lulus (`flutter test`)
- [x] Kompilasi debug Android APK berhasil (`flutter build apk --debug`)
- [x] Aturan persistent AI coding agents (`AGENTS.md`)
- [ ] *Tahap 02: Implementasi fungsional fitur paralel oleh Alfredo, Adriel, dan Roganda*

---

## 7. Dokumentasi Lengkap
- [Arsitektur Sistem (ARCHITECTURE.md)](ARCHITECTURE.md)
- [Desain Basis Data & RLS (DATABASE_DESIGN.md)](DATABASE_DESIGN.md)
- [Kontrak Integrasi Layanan (INTEGRATION_CONTRACTS.md)](INTEGRATION_CONTRACTS.md)
- [Privasi & Keamanan (PRIVACY_AND_SECURITY.md)](PRIVACY_AND_SECURITY.md)
- [Alur Kerja Git & Percabangan (DEVELOPMENT_WORKFLOW.md)](DEVELOPMENT_WORKFLOW.md)
- [Rencana Implementasi & Milestones (IMPLEMENTATION_PLAN.md)](IMPLEMENTATION_PLAN.md)
- [Aturan Persistent Coding Agents (AGENTS.md)](AGENTS.md)
