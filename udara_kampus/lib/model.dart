import 'package:flutter/material.dart';

/// Kategori kualitas udara berdasarkan US AQI.
enum Kategori {
  baik('Baik', Color(0xFF2E7D32), Icons.sentiment_very_satisfied,
      'Udara bersih. Aman untuk semua aktivitas luar ruangan.'),
  sedang('Sedang', Color(0xFF9A6700), Icons.sentiment_satisfied,
      'Dapat diterima. Orang yang sangat sensitif sebaiknya mengurangi aktivitas berat.'),
  tidakSehatSensitif('Tidak sehat bagi kelompok sensitif', Color(0xFFE65100),
      Icons.sentiment_neutral,
      'Anak-anak, lansia, dan penderita asma sebaiknya membatasi aktivitas luar ruangan.'),
  tidakSehat('Tidak sehat', Color(0xFFC62828), Icons.sentiment_dissatisfied,
      'Semua orang mulai terdampak. Kurangi aktivitas berat di luar ruangan.'),
  sangatTidakSehat('Sangat tidak sehat', Color(0xFF6A1B9A),
      Icons.sentiment_very_dissatisfied,
      'Hindari aktivitas luar ruangan dan gunakan masker bila harus keluar.'),
  berbahaya('Berbahaya', Color(0xFF7B1F3A), Icons.warning_amber_rounded,
      'Kondisi darurat. Tetap di dalam ruangan dengan jendela tertutup.'),
  tidakDiketahui('Tidak diketahui', Color(0xFF546E7A), Icons.help_outline,
      'Data indeks udara belum tersedia.');

  const Kategori(this.label, this.warna, this.ikon, this.saran);
  final String label;
  final Color warna;
  final IconData ikon;
  final String saran;

  static Kategori dariAqi(int? aqi) {
    return switch (aqi) {
      null => Kategori.tidakDiketahui,
      <= 50 => Kategori.baik,
      <= 100 => Kategori.sedang,
      <= 150 => Kategori.tidakSehatSensitif,
      <= 200 => Kategori.tidakSehat,
      <= 300 => Kategori.sangatTidakSehat,
      _ => Kategori.berbahaya,
    };
  }
}

class Kota {
  const Kota(this.nama, this.lintang, this.bujur);
  final String nama;
  final double lintang;
  final double bujur;
}

const daftarKota = <Kota>[
  Kota('Jakarta', -6.2, 106.85),
  Kota('Bandung', -6.91, 107.61),
  Kota('Yogyakarta', -7.80, 110.36),
  Kota('Surabaya', -7.25, 112.75),
  Kota('Denpasar', -8.65, 115.22),
  Kota('Samarinda', -0.5, 117.15),
  Kota('Makassar', -5.15, 119.43),
  Kota('Medan', 3.59, 98.67),
];

class KualitasUdara {
  const KualitasUdara({
    required this.aqi,
    required this.pm25,
    required this.pm10,
    required this.co,
    required this.no2,
    required this.so2,
    required this.o3,
  });
  final int? aqi;
  final double? pm25, pm10, co, no2, so2, o3;
  Kategori get kategori => Kategori.dariAqi(aqi);
}

class PrakiraanHarian {
  const PrakiraanHarian({
    required this.tanggal,
    required this.aqiMaks,
    required this.pm25Rata,
  });
  final DateTime tanggal;
  final int? aqiMaks;
  final double? pm25Rata;
  Kategori get kategori => Kategori.dariAqi(aqiMaks);
}

class DataUdara {
  const DataUdara(this.saatIni, this.harian);
  final KualitasUdara saatIni;
  final List<PrakiraanHarian> harian;
}

class ApiException implements Exception {
  ApiException(this.kodeStatus);
  final int kodeStatus;
  @override
  String toString() => 'ApiException: kode status $kodeStatus';
}
