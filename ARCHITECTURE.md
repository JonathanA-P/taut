# ARCHITECTURE.md — TAUT System Architecture & Technical Specifications

> **Project**: TAUT (Aksesibilitas & Komunikasi Inklusif)  
> **Competition**: INCEPTION 2026 Hackathon  
> **Team**: Mardua Holong (Universitas Brawijaya)  
> **Stage**: 01 — Project Foundation & Architecture

---

## 1. System Overview & Context

TAUT is an Android accessibility application designed to bridge communication barriers for Deaf and Hard-of-Hearing individuals (specifically Indonesian Sign Language / BISINDO users) when interacting with hearing peers and accessing nearby emergency healthcare services.

### Core Capabilities
1. **Two-Way Communication**:
   - **Speech-to-Text**: Captures spoken Indonesian (`id-ID`) via native Android speech recognition and presents confirmed, high-contrast text to Deaf users.
   - **Motion-to-Sound**: Captures hand gestures via Android camera, extracts landmark coordinates, classifies gestures using a BISINDO word-level model, and speaks aloud using Text-to-Speech (TTS).
2. **Healthcare Finder**:
   - Locates nearby healthcare facilities (hospitals, clinics, doctors, pharmacies) within a 10 km radius using OpenStreetMap Overpass API and provides external navigation links.
3. **Location Sharing to Healthcare Recipients**:
   - Allows users to share their current location coordinates and Google Maps link via Android Share Sheet (`share_plus`) directly to external channels without requiring database overhead.
4. **Friend-to-Friend Live Location Sharing**:
   - Facilitates real-time, authorized foreground location streaming between verified friends using Supabase PostgreSQL with Row Level Security (RLS) and Supabase Realtime.

---

## 2. System Context Diagram (Mermaid)

```mermaid
flowchart TD
    subgraph Users["Pengguna TAUT"]
        DeafUser["Teman Tuli / BISINDO User"]
        HearingUser["Masyarakat Dengar / Teman"]
    end

    subgraph MobileApp["TAUT Mobile App (Flutter / Android)"]
        CommModule["Modul Komunikasi<br/>(STT & Motion-to-Sound)"]
        HealthModule["Modul Fasilitas Kesehatan<br/>(OSM Overpass Client)"]
        ShareModule["Modul Berbagi Lokasi<br/>(Faskes & Teman)"]
        AuthModule["Modul Otentikasi & Profil"]
    end

    subgraph ExternalServices["Layanan Eksternal & Cloud"]
        Supabase["Supabase Cloud Platform<br/>- PostgreSQL DB<br/>- Row Level Security (RLS)<br/>- Supabase Realtime<br/>- GoTrue Auth"]
        OSM["OpenStreetMap Overpass API<br/>(Layanan Publik Faskes 10km)"]
        AndroidNative["Android OS Platform APIs<br/>- Camera Hardware<br/>- SpeechRecognizer (id-ID)<br/>- Text-to-Speech Engine<br/>- Share Sheet & Geolocator"]
    end

    DeafUser -->|"Isyarat Tangan & Input Teks"| CommModule
    HearingUser -->|"Ucapan Suara (Bahasa Indonesia)"| CommModule
    DeafUser -->|"Cari Bantuan & Lokasi"| HealthModule
    DeafUser -->|"Bagikan Lokasi"| ShareModule

    CommModule <-->|"Kamera & Audio API"| AndroidNative
    HealthModule <-->|"Query Radius 10 km"| OSM
    ShareModule -->|"Android Intent / Share Sheet"| AndroidNative
    ShareModule <-->|"Live Location Stream (WSS)"| Supabase
    AuthModule <-->|"Auth & RLS Queries"| Supabase
```

---

## 3. Component Architecture Diagram (Mermaid)

```mermaid
flowchart TD
    subgraph PresentationLayer["Presentation Layer (Flutter UI / Material 3)"]
        HomeShell["HomeShellScreen (4 Bottom Tabs)"]
        CommHub["CommunicationHubScreen"]
        STTView["SpeechToTextScreen"]
        MTSView["MotionToSoundScreen"]
        HealthView["HealthcareFinderScreen"]
        ShareView["LocationSharingScreen"]
        FriendView["FriendsPlaceholderScreen"]
        ProfileView["ProfileScreen & PrivacyPolicyScreen"]
    end

    subgraph CoreFoundation["Core & Shared Foundation"]
        Theme["AppTheme (M3)"]
        Router["AppRouter"]
        DistCalc["DistanceCalculator (Haversine stdlib)"]
        PermService["PermissionService"]
        Config["AppConfig & Env"]
    end

    subgraph DomainLayer["Domain Layer (Contracts & Entities)"]
        AuthRepo["AuthRepository Contract"]
        FriendRepo["FriendsRepository Contract"]
        LocRepo["LocationSharingRepository Contract"]
        HealthRepo["HealthcareRepository Contract"]
        HealthShare["HealthcareShareService Contract"]
        SpeechSvc["SpeechService Contract"]
        BisindoSvc["BisindoRecognitionService Contract"]
        TtsSvc["TtsService Contract"]
    end

    subgraph DataLayer["Data Layer (Repositories & API Sources)"]
        AuthImpl["AuthRepositoryImpl (Supabase GoTrue)"]
        FriendImpl["FriendsRepositoryImpl (Postgres RLS)"]
        LocImpl["LocationSharingRepositoryImpl (Supabase Realtime)"]
        HealthImpl["HealthcareRepositoryImpl (HTTP Client)"]
        OSMService["OsmOverpassService (QL Builder)"]
        HealthShareImpl["HealthcareShareServiceImpl (share_plus)"]
        SpeechImpl["SpeechServiceImpl (Android SpeechRecognizer)"]
        BisindoImpl["BisindoRecognitionServiceImpl (TFLite)"]
        TtsImpl["TtsServiceImpl (flutter_tts)"]
    end

    HomeShell --> CommHub & HealthView & ShareView & ProfileView
    CommHub --> STTView & MTSView
    ShareView --> FriendView

    STTView -.-> SpeechSvc
    MTSView -.-> BisindoSvc & TtsSvc
    HealthView -.-> HealthRepo
    ShareView -.-> HealthShare & LocRepo
    FriendView -.-> FriendRepo

    SpeechSvc <|-- SpeechImpl
    BisindoSvc <|-- BisindoImpl
    TtsSvc <|-- TtsImpl
    HealthRepo <|-- HealthImpl
    HealthImpl --> OSMService & DistCalc
    HealthShare <|-- HealthShareImpl
    LocRepo <|-- LocImpl
    FriendRepo <|-- FriendImpl
    AuthRepo <|-- AuthImpl
```

---

## 4. Feature Flow Architectures

### 4.1. Speech-to-Text Flow (Indonesian Speech Recognition)

```mermaid
sequenceDiagram
    autonumber
    actor Speaker as Masyarakat Dengar
    participant UI as SpeechToTextScreen
    participant Service as SpeechService
    participant Android as Android SpeechRecognizer (id-ID)
    actor Deaf as Teman Tuli

    Speaker->>UI: Tekan tombol Mikrofon (Eksplisit)
    UI->>Service: startListening(language: 'id-ID')
    Service->>Android: Buka audio stream & inisiasi recognizer
    Android-->>Service: Emisi transkripsi parsial
    Service-->>UI: Update recognizedText secara real-time
    Speaker->>UI: Selesai bicara / Tekan berhenti
    UI->>Service: stopListening()
    Service->>Android: Finalisasi buffer audio
    Android-->>Service: Teks final bahasa Indonesia
    Service-->>UI: Emisi status isFinal = true
    UI->>Speaker: Pratinjau & opsi koreksi teks
    Speaker->>UI: Tekan "Konfirmasi Pesan"
    UI->>Deaf: Tampilkan kartu pesan teks visual besar & jelas
```

### 4.2. Motion-to-Sound Flow (BISINDO to TTS)

```mermaid
sequenceDiagram
    autonumber
    actor Signer as Pengguna BISINDO
    participant Cam as Android Camera
    participant MP as MediaPipe Hand Landmarker
    participant AI as BISINDO TFLite Classifier
    participant TTS as Text-to-Speech Engine
    actor Listener as Lawan Bicara

    Signer->>Cam: Peragakan isyarat tangan BISINDO
    Cam->>MP: Kirim frame video mentah (on-device)
    MP->>MP: Ekstraksi 21 koordinat 3D per tangan
    MP->>AI: Kirim vektor fitur landmark normalisasi
    AI->>AI: Evaluasi matriks bobot & hitung confidence
    alt Confidence >= 0.70 & Kategori Valid
        AI-->>TTS: Terjemahkan kata (e.g. "TERIMA KASIH")
        TTS->>Listener: Ucapkan audio bahasa Indonesia
    else Confidence < 0.70 atau Gerakan Tidak Terdaftar
        AI-->>Signer: Kembalikan GestureResult.unknown()
        Note over Signer,Listener: Tidak ada fabrikasi terjemahan palsu
    end
```

### 4.3. Healthcare Finder Flow (OSM Overpass 10 km Radius)

```mermaid
sequenceDiagram
    autonumber
    actor User as Pengguna TAUT
    participant UI as HealthcareFinderScreen
    participant Repo as HealthcareRepository
    participant GPS as Geolocator API
    participant OSM as OpenStreetMap Overpass API
    participant Nav as External Map Application

    User->>UI: Tekan "Cari Fasilitas Kesehatan"
    UI->>Repo: getCurrentLocation()
    Repo->>GPS: Request GPS fix (Fine / Coarse Location)
    GPS-->>Repo: Titik koordinat (lat, lon)
    UI->>Repo: searchNearby(lat, lon, radius: 10000m)
    Repo->>OSM: HTTP POST query Overpass QL (10 km radius)
    OSM-->>Repo: JSON response (nodes & ways with center)
    Repo->>Repo: Normalisasi entitas & hitung jarak (Haversine)
    Repo->>Repo: Filter duplikat & urutkan dari terdekat
    Repo-->>UI: List<HealthcareFacility> tersortir
    UI->>User: Tampilkan daftar faskes, jarak, & alamat
    User->>UI: Pilih faskes & tekan "Rute / Navigasi"
    UI->>Nav: Buka geo: URI / Google Maps navigation
```

### 4.4. Friend-to-Friend Location Sharing Sequence (Supabase Realtime)

```mermaid
sequenceDiagram
    autonumber
    actor Owner as Pemilik Lokasi (Teman A)
    participant AppA as TAUT App (A)
    participant Supabase as Supabase (PostgreSQL + RLS)
    participant Realtime as Supabase Realtime Channel
    participant AppB as TAUT App (B)
    actor Recipient as Penerima (Teman B)

    Owner->>AppA: Inisiasi sesi berbagi lokasi (Pilih durasi, misal 30 menit)
    AppA->>Supabase: INSERT INTO location_shares (owner_id, recipient_id, expires_at)
    Note over Supabase: RLS memvalidasi pertemanan aktif (are_friends)
    Supabase-->>AppA: Session ID terverifikasi
    AppB->>Realtime: Langganan perubahan (Postgres Changes: location_shares)
    
    loop Setiap interval GPS (10 detik) selama aktif
        AppA->>Supabase: UPDATE location_shares SET lat, lon WHERE id = session_id
        Note over Supabase: RLS hanya mengizinkan update dari auth.uid() = owner_id
        Supabase->>Realtime: Broadcast update koordinat
        Realtime->>AppB: Notifikasi titik koordinat terbaru
        AppB->>Recipient: Render pergerakan posisi Teman A pada peta
    end

    alt Pemilik mencabut sesi (Revocation)
        Owner->>AppA: Tekan "Hentikan Berbagi"
        AppA->>Supabase: UPDATE location_shares SET revoked_at = now()
        Supabase->>Realtime: Broadcast event pencabutan
        Realtime->>AppB: Akses ditutup seketika oleh RLS
    else Batas waktu habis (Expiration)
        Note over Supabase: expires_at < now() -> Kebijakan RLS otomatis menolak query SELECT
        AppB->>Recipient: Sesi berakhir secara otomatis
    end
```

---

## 5. Technology Decisions & Rationale

| Layer | Chosen Technology | Justification / Trade-off |
| :--- | :--- | :--- |
| **Mobile Framework** | Flutter 3.47.7 (Dart 3.13.5) | Cross-platform Material 3 accessibility widgets, native Android channel performance, zero build-generator drag. |
| **State Management** | Native `ChangeNotifier` / `ValueNotifier` + `ListenableBuilder` | Zero external dependency weight, no code generators (`freezed`/`build_runner`), eliminating cross-developer merge conflicts. |
| **Backend & Auth** | Supabase Cloud (PostgreSQL + RLS) | Built-in authentication, instant WebSocket Realtime sync, row-level declarative security, eliminate redundant custom Node.js servers. |
| **Geospatial Distance** | Native Dart Haversine formula (`DistanceCalculator`) | Standard library `dart:math`, eliminates unneeded external mapping plugins for raw distance calculation. |
| **Healthcare Source** | OpenStreetMap Overpass API | Open, free, globally accessible, no proprietary billing or vendor lock-in for hackathon demonstration. |
| **Speech Pipeline** | Android native SpeechRecognizer (`id-ID`) | Low latency, native Indonesian language acoustic models pre-installed on Android devices. |
| **Vision Inference** | MediaPipe Landmarker + TFLite | Isolates computer vision extraction from classification logic; allows word-level BISINDO model swapping without touching the UI. |

---

## 6. Architecture Limitations & Operational Boundaries

1. **Healthcare Accessibility Metadata**:
   OpenStreetMap tags rarely document wheelchair ramps, sign language interpreters, or physical disability access. TAUT strictly marks accessibility as unverified unless `wheelchair=yes` is explicitly tagged.
2. **BISINDO Vocabulary Scope**:
   TAUT Stage 01/02 targets an isolated word-level vocabulary (8–20 emergency and daily communication words). It is **not** an open-ended sentence translator.
3. **Location Tracking Mode**:
   Only **foreground** location updates are supported in the MVP. Stealth or background geofencing is deliberately omitted for battery efficiency, privacy protection, and hackathon scope containment.
