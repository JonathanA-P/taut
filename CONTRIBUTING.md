# CONTRIBUTING.md — Developer Contribution Guidelines

Welcome to the **TAUT** repository!
This project is built by **Team Mardua Holong (INCEPTION 2026 Hackathon)**.

To maintain rapid development velocity and avoid code regressions across our three-person team, follow these guidelines:

---

## 1. Getting Started

1. Clone the repository and switch to `develop`:
   ```bash
   git checkout develop
   ```
2. Copy environment variables:
   ```bash
   cp .env.example .env
   ```
   *Never commit `.env` to Git!*
3. Fetch dependencies and verify toolchain:
   ```bash
   flutter pub get
   flutter analyze
   flutter test
   ```

---

## 2. Working on Features

1. Branch out from `develop` using your designated feature branch name:
   ```bash
   git checkout -b feature/<your-assigned-feature>
   ```
2. Check `INTEGRATION_CONTRACTS.md` before implementing or altering any public interfaces.
3. Keep changes tightly focused on your assigned module. Do not touch unrelated features.

---

## 3. Pre-Commit Quality Checks

Always run:
```bash
dart format .
flutter analyze
flutter test
```
Resolve any warnings or errors before committing.

---

## 4. Code Standards (Ponytail Principles)
- Prioritize native platform and Flutter standard library features over external packages.
- Zero boilerplate: do not introduce heavy code-generation libraries unless explicitly approved by the Team Lead.
- Write clean, accessible, high-contrast Material 3 UI with descriptive Indonesian labels.
