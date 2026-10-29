# 🌿 Udara Kampus

Aplikasi Flutter pemantau **kualitas udara** untuk delapan kota kampus di Indonesia.
Dibuat berdasarkan *Studi Kasus 13: Cuaca Kampus*, dengan data diganti ke **Open-Meteo Air Quality API**.

## 👥 Kelompok 7

| No | Nama | NIM |
|----|------|-----|
| 1 | Rusdiana | 2409106021 |
| 2 | Renaya Putri Alika | 2409106002 |
| 3 | Andi Fachry Alang Tengko | 2409106006 |

## ✨ Fitur

| Bagian | Fitur |
|--------|-------|
| Pilihan kota | *Chip* Jakarta, Bandung, Yogyakarta, Surabaya, Denpasar, Samarinda, Makassar, dan Medan |
| Udara saat ini | US AQI, kategori + saran kesehatan, PM2.5, PM10, CO, NO₂, SO₂, O₃, dan jam diperbarui |
| Prakiraan 7 hari | AQI tertinggi, kategori, dan rata-rata PM2.5 setiap hari |
| Interaksi | Tarik ke bawah untuk menyegarkan; tombol **Coba lagi** saat gagal |
| Tampilan | Tema terang & gelap otomatis, warna kartu mengikuti tingkat polusi |

## 🌐 Sumber data

[Open-Meteo Air Quality API](https://open-meteo.com/en/docs/air-quality-api) (tanpa kunci API, lisensi CC BY 4.0).
Sumber data juga ditulis di bagian bawah halaman aplikasi.

```
GET https://air-quality-api.open-meteo.com/v1/air-quality
    ?latitude=..&longitude=..
    &current=us_aqi,pm2_5,pm10,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone
    &hourly=us_aqi,pm2_5
    &timezone=auto&forecast_days=7
```

Bagian `hourly` berupa **larik sejajar**; *Repository* menggabungkannya menjadi data harian
(AQI maksimum dan rata-rata PM2.5 per hari), dan siap menghadapi nilai `null`.

| US AQI | Kategori |
|--------|----------|
| 0–50 | Baik |
| 51–100 | Sedang |
| 101–150 | Tidak sehat bagi kelompok sensitif |
| 151–200 | Tidak sehat |
| 201–300 | Sangat tidak sehat |
| 301+ | Berbahaya |

## 🏗️ Struktur

```
lib/
├── main.dart               # jalankanUji() lalu runApp
├── model.dart              # Kota, Kategori (enum), KualitasUdara, PrakiraanHarian
├── layanan_open_meteo.dart # LayananOpenMeteo (HTTP) + UdaraRepositori (parsing JSON)
├── udara_view_model.dart   # status memuat-berhasil-gagal, nomor permintaan, pesanRamah
├── tampilan.dart           # View: PilihanKota, RefreshIndicator, kartu, prakiraan
└── uji.dart                # Pemeriksaan dengan MockClient (LULUS/GAGAL di konsol)
```

## ▶️ Cara menjalankan (VS Code)

```bash
flutter create udara_kampus      # buat proyek kosong
# salin folder lib/ dan pubspec.yaml dari repo ini ke dalamnya (timpa)
cd udara_kampus
flutter pub get
flutter run
```

> **Penting untuk APK rilis:** pastikan izin internet ada di
> `android/app/src/main/AndroidManifest.xml`, di atas tag `<application>`:
> `<uses-permission android:name="android.permission.INTERNET"/>`
>
> Membuat APK: `flutter build apk --release`
> (hasil: `build/app/outputs/flutter-apk/app-release.apk`)

## ✅ Uji mandiri

- [ ] Konsol menampilkan sebelas baris `LULUS` sebelum aplikasi tampil.
- [ ] Memilih kota lain menampilkan lingkaran memuat, lalu udara kota itu.
- [ ] Memilih dua kota dengan sangat cepat tidak pernah menampilkan kota yang **pertama** dipilih.
- [ ] Menarik daftar ke bawah menyegarkan data, dan jam "Diperbarui pukul" berubah.
- [ ] Dua baris teratas prakiraan bertuliskan "Hari ini" dan "Besok".
- [ ] Mematikan internet lalu menekan kota lain menampilkan pesan ramah dan tombol **Coba lagi**.
- [ ] Dalam mode gelap, semua teks tetap terbaca.

## 📸 Tampilan aplikasi

| Kota Jakarta | Mode gelap | Gagal terhubung |
|:---:|:---:|:---:|
| ![Jakarta](screenshots/jakarta.png) | ![Gelap](screenshots/gelap.png) | ![Galat](screenshots/galat.png) |

> Letakkan hasil *screenshot* di folder `screenshots/` dengan nama di atas.
