# AGENTS.md — Persistent Operational Directives for Coding Agents

This repository is maintained by **Team Mardua Holong (INCEPTION 2026 Hackathon)** for the **TAUT** project.
All AI coding agents, subagents, and automated assistants operating within this repository **MUST STRICTLY COMPLY** with the following rules:

---

## 1. Feature Ownership & Team Boundaries
Each feature module is explicitly owned by a team member. Coding agents working on behalf of a member must only modify that member's feature domain unless explicit cross-module contract changes have been approved:

| Team Member | Role | Assigned Modules & Branches |
| :--- | :--- | :--- |
| **Alfredo Jonathan Purba** | Team Lead, Backend & Database Architect | `features/auth/`, `features/friends/`, `features/location_sharing/` (friend live sharing), `supabase/migrations/`<br>Branches: `feature/supabase-auth-friends`, `feature/friend-location-sharing` |
| **Adriel Christo Lumbantoruan** | Frontend, Navigation & Healthcare Lead | `features/healthcare/`, `features/location_sharing/` (healthcare share sheet), `features/home/`, App Shell UI<br>Branches: `feature/app-shell-ui`, `feature/healthcare-finder`, `feature/share-location-faskes` |
| **Roganda Tua Tampubolon** | Communication AI & Vision Lead | `features/communication/speech_to_text/`, `features/communication/motion_to_sound/`, ML models & TTS<br>Branches: `feature/speech-to-text`, `feature/motion-to-sound` |

---

## 2. Mandatory Rules of Engagement

1. **Maintain Working Modules**:
   - Never overwrite or refactor a functioning module without explicit authorization and verified test coverage.
   - Do not make breaking changes to `lib/core/` or `lib/shared/` without consensus.

2. **Strict Adherence to Integration Contracts**:
   - Do not alter function signatures or return types defined in `INTEGRATION_CONTRACTS.md` unilaterally.
   - If a contract change is necessary, update the contract file and notify all feature owners before writing code.

3. **No Fake AI or Fabricated Predictions**:
   - **DO NOT** hardcode mock sign language translations or simulated speech transcripts that pretend to be a real AI model.
   - Unrecognized gestures or low-confidence inferences **MUST** return `GestureResult.unknown()`.
   - MediaPipe Hand Landmarker is an input feature extractor, NOT a BISINDO translation model.
   - Do not claim sentence translation when isolated word or alphabet models are used.

4. **Security & Git Hygiene (Strict)**:
   - **NEVER** commit or stage `.env`, `.env.*` (except `.env.example`), private keys, or service_role tokens.
   - Always verify `git status` before committing.
   - All sensitive tables must have PostgreSQL Row Level Security (RLS) enabled.
   - UI code must NEVER make direct SQL queries or bypass Supabase RLS.

5. **Verification Before Completion**:
   - Before submitting changes, always execute:
     ```bash
     dart format .
     flutter analyze
     flutter test
     ```
   - Ensure all tests pass with zero warnings or errors.

6. **Documentation Synchronization**:
   - Any architectural modification, schema migration, or API contract adjustment must be immediately reflected in the relevant documentation (`ARCHITECTURE.md`, `DATABASE_DESIGN.md`, `INTEGRATION_CONTRACTS.md`).

7. **Scoped Minimal Diffs (Ponytail Principle)**:
   - Apply the ladder: do not introduce unnecessary dependencies, complex abstractions, or code generators.
   - Write the cleanest, most maintainable code that solves the specific requirement.
