# PRIVACY_AND_SECURITY.md — Privacy by Design & Security Standards

> **Project**: TAUT  
> **Target Platform**: Android (INCEPTION 2026 Hackathon)  
> **Team**: Mardua Holong

Accessibility applications handle highly sensitive personal information, particularly when serving users with speech and hearing disabilities. TAUT is engineered according to the principles of **Privacy by Design**, **Data Minimization**, and **Least Privilege**.

---

## 1. Audio Processing & Microphone Privacy

1. **Explicit Interaction Only**:
   - The microphone is **only** activated when the hearing user explicitly presses and holds/taps the microphone button.
   - Passive or continuous background listening is strictly forbidden.
2. **Audio Retention**:
   - Raw audio waveforms are processed locally or transiently via Android SpeechRecognizer and are **never** persisted to disk or sent to a private TAUT backend server.
3. **Transparent State**:
   - Visual indicators (pulsing animation and "Mendengarkan..." status) clearly inform users whenever audio is being captured.

---

## 2. Camera Processing & Computer Vision Security

1. **On-Device Feature Extraction**:
   - Camera video frames are processed **100% locally on-device** using the MediaPipe Hand Landmarker framework.
   - Raw video frames, user photos, or face images are **NEVER uploaded** to Supabase or any remote cloud endpoint.
2. **Feature Vector Ephemerality**:
   - Only mathematical landmark coordinate vectors (21 3D points) are evaluated by the local TFLite classification model.
   - Landmark coordinates are discarded from RAM immediately after inference.

---

## 3. Location Sharing & Consent Architecture

1. **Dual-Flow Separation**:
   - **Flow A (Healthcare Sharing)**: Uses native Android Share Sheet (`share_plus`). The app prepares coordinates and a Google Maps link. The user explicitly selects their desired external messaging app. No database record is created.
   - **Flow B (Friend Live Sharing)**: Employs Supabase PostgreSQL and Realtime.
2. **Strict User Consent**:
   - Location coordinates are never transmitted silently. A confirmation dialog displaying the exact coordinates is presented before invoking any share intent.
3. **Foreground Tracking Only**:
   - TAUT only collects location coordinates while the application is in the foreground. No background tracking service or hidden geofencing is implemented.
4. **Session Expiry & Immediate Revocation**:
   - Every live session has a mandatory `expires_at` timestamp (default: 30–60 minutes).
   - The owner can press "Hentikan Berbagi" at any moment to set `revoked_at = now()`, immediately revoking access via RLS.

---

## 4. PostgreSQL Row Level Security (RLS) & Authorization

1. **No Anonymous Access**:
   - Public/anonymous roles cannot read or write to `profiles`, `friendships`, `friend_invites`, or `location_shares`.
2. **Server-Enforced Friendship Check**:
   - Location shares cannot be read or inserted unless a verified bilateral friendship (`status = 'accepted'`) exists in PostgreSQL:
     ```sql
     AND public.are_friends(owner_id, recipient_id)
     ```
3. **Recipient Tamper Prevention**:
   - `UPDATE` policies on `location_shares` restrict write privileges solely to the session owner (`auth.uid() = owner_id`). Recipients can **never** inject coordinates, modify timestamps, or forge location data.

---

## 5. Secret Management & Git Hygiene

1. **Git Exclusions**:
   - `.env`, `.env.*`, `key.properties`, and keystore files (`*.jks`, `*.keystore`) are strictly listed in `.gitignore`.
   - Only `.env.example` with non-sensitive placeholder templates is tracked.
2. **Client-Safe Credentials**:
   - The Flutter mobile client only consumes the Supabase **Publishable Anon Key**.
   - The Supabase **`service_role` secret is NEVER embedded** in mobile source code.
3. **Cryptographic Token Hashing**:
   - Friend invitations generated as tokens are hashed using SHA-256 before insertion into `public.friend_invites`. Leaked database dumps cannot be abused to hijack friend links.

---

## 6. OpenStreetMap & External Services Considerations

1. **Overpass API Rate Limiting**:
   - Queries use a focused bounding radius (10 km) and an explicit timeout (15s).
   - Client-side throttling prevents spamming the public Overpass servers.
2. **Neutral Accessibility Representation**:
   - TAUT never fabricates accessibility claims. A facility is marked disability-friendly only if verified by explicit OpenStreetMap tags (`wheelchair=yes`).
