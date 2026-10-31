# TAUT — Flutter (Stage 01: Beranda)

Aplikasi aksesibilitas Android untuk INCEPTION 2026 Hackathon,
tim Mardua Holong, Universitas Brawijaya.

## Yang sudah ada di tahap ini

- `lib/main.dart` + `lib/bootstrap/bootstrap.dart` + `lib/app.dart`
  (entry point, bootstrap, root MaterialApp).
- `lib/core/` — tema Senja Lembut (`theme/app_theme.dart`), konstanta,
  konfigurasi environment (Supabase, lewat `--dart-define`), exception,
  router, dan kontrak izin perangkat (masih stub).
- `lib/shared/` — model `LatLng` + 6 widget bersama sesuai arsitektur
  (tombol aksi, badge status, banner berbagi lokasi, placeholder,
  kartu penjelasan izin, gelembung percakapan).
- `lib/features/home/presentation/home_page.dart` — Beranda lengkap:
  sapaan, hero "Mulai Komunikasi", 4 pintasan pastel, ringkasan teman,
  dan kartu sesi berbagi lokasi dengan timer + berhenti sekali ketuk
  + riwayat terakhir berbagi.

Rute selain Beranda masih placeholder yang jujur ("fitur ini belum
dibangun"). Begitu satu fitur selesai, ganti satu case di
`lib/core/routing/app_router.dart` — jangan hapus placeholder sebelum
penggantinya ada.

## Cara menjalankan

```bash
cd app
flutter pub get
flutter run
```

Belum perlu Supabase untuk tahap ini. Saat Supabase dihubungkan nanti:

```bash
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
            --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
```

## Aturan yang tidak boleh dilanggar

- Secret key Supabase (`sb_secret_...`) TIDAK BOLEH masuk aplikasi,
  APK, atau repo — hanya URL + publishable/anon key, data dilindungi RLS.
- Hasil AI yang tidak dikenali (suara/isyarat) TIDAK BOLEH dikarang
  jadi terjemahan — tampilkan bahwa tidak dikenali.
- Jangan pernah klaim faskes ramah disabilitas tanpa data yang bisa
  dipercaya, dan jangan klaim integrasi langsung ke faskes (MVP pakai
  Share Sheet).
- Beranda tidak pakai header bar plum; halaman lain pakai header plum
  full-width (judul kiri + subjudul di bawahnya).
