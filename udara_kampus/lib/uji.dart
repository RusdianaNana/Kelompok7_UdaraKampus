import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'layanan_open_meteo.dart';
import 'model.dart';
import 'udara_view_model.dart';

void _cek(String nama, bool kondisi) =>
    debugPrint('${kondisi ? 'LULUS' : 'GAGAL'}  $nama');

String _jsonContoh() {
  final waktu = [
    for (final d in ['2026-10-15', '2026-10-16'])
      for (int h = 0; h < 24; h++) '${d}T${h.toString().padLeft(2, '0')}:00'
  ];
  final aqi = [for (int i = 0; i < 48; i++) i == 30 ? null : (i < 24 ? 40 + i : 120 + (i - 24))];
  final pm25 = [for (int i = 0; i < 48; i++) i * 0.5];
  return jsonEncode({
    'timezone': 'Asia/Makassar',
    'current': {
      'time': '2026-10-15T14:00',
      'us_aqi': 57,
      'pm2_5': 17.3,
      'pm10': 25,
      'carbon_monoxide': 210.0,
      'nitrogen_dioxide': 8.1,
      'sulphur_dioxide': null,
      'ozone': 60.2,
    },
    'hourly': {'time': waktu, 'us_aqi': aqi, 'pm2_5': pm25},
  });
}

/// Pemeriksaan sebelum aplikasi tampil (memakai MockClient, tanpa internet).
Future<void> jalankanUji() async {
  final klien = MockClient((_) async => http.Response(_jsonContoh(), 200));
  final repo = UdaraRepositori(LayananOpenMeteo(klien));
  final data = await repo.ambil(daftarKota.firstWhere((k) => k.nama == 'Samarinda'));

  _cek('AQI saat ini terbaca (57)', data.saatIni.aqi == 57);
  _cek('Kategori 57 = Sedang', data.saatIni.kategori == Kategori.sedang);
  _cek('Nilai bulat (pm10 25) terbaca double', data.saatIni.pm10 == 25.0);
  _cek('Nilai null (SO2) ditangani', data.saatIni.so2 == null);
  _cek('Data per jam digabung jadi 2 hari', data.harian.length == 2);
  _cek('AQI maks hari pertama 63', data.harian[0].aqiMaks == 63);
  _cek('AQI maks hari kedua 143 (null dilewati)', data.harian[1].aqiMaks == 143);
  _cek('Batas kategori 150 = sensitif', Kategori.dariAqi(150) == Kategori.tidakSehatSensitif);
  _cek('AQI null = tidak diketahui', Kategori.dariAqi(null) == Kategori.tidakDiketahui);

  final klienGalat = MockClient((_) async => http.Response('', 500));
  final vm = UdaraViewModel(UdaraRepositori(LayananOpenMeteo(klienGalat)));
  await vm.muat();
  _cek('Kode 500: status gagal', vm.status == StatusMuat.gagal);
  _cek('Kode 500: pesan ramah', vm.pesanGalat.contains('500'));
  vm.dispose();
}
