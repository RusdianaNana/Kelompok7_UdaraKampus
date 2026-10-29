import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'model.dart';

class LayananOpenMeteo {
  LayananOpenMeteo(this._klien);
  final http.Client _klien;

  Future<Map<String, dynamic>> ambilJson(Kota kota) async {
    final Uri alamat = Uri.https(
      'air-quality-api.open-meteo.com',
      '/v1/air-quality',
      {
        'latitude': '${kota.lintang}',
        'longitude': '${kota.bujur}',
        'current':
            'us_aqi,pm2_5,pm10,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone',
        'hourly': 'us_aqi,pm2_5',
        'timezone': 'auto', // tanggal mengikuti zona waktu kota itu
        'forecast_days': '7',
      },
    );
    debugPrint('GET $alamat');
    final respons = await _klien.get(alamat).timeout(const Duration(seconds: 15));
    if (respons.statusCode != 200) throw ApiException(respons.statusCode);
    final json = jsonDecode(respons.body);
    if (json is! Map<String, dynamic>) {
      throw const FormatException('Jawaban bukan objek JSON');
    }
    return json;
  }
}

class UdaraRepositori {
  UdaraRepositori(this._layanan);
  final LayananOpenMeteo _layanan;

  Future<DataUdara> ambil(Kota kota) async {
    final json = await _layanan.ambilJson(kota);
    return DataUdara(_saatIni(json), _harian(json));
  }

  // Angka bisa bulat (31) atau desimal (31.4), dan bisa null.
  double? _d(dynamic v) => (v as num?)?.toDouble();

  KualitasUdara _saatIni(Map<String, dynamic> json) {
    if (json case {'current': final Map<String, dynamic> c}) {
      return KualitasUdara(
        aqi: (c['us_aqi'] as num?)?.round(),
        pm25: _d(c['pm2_5']),
        pm10: _d(c['pm10']),
        co: _d(c['carbon_monoxide']),
        no2: _d(c['nitrogen_dioxide']),
        so2: _d(c['sulphur_dioxide']),
        o3: _d(c['ozone']),
      );
    }
    throw const FormatException('Bentuk data saat ini tidak sesuai');
  }

  /// Data per jam (larik sejajar) digabung menjadi data per hari.
  List<PrakiraanHarian> _harian(Map<String, dynamic> json) {
    if (json case {
      'hourly': {
        'time': final List<dynamic> waktu,
        'us_aqi': final List<dynamic> aqi,
        'pm2_5': final List<dynamic> pm25,
      }
    }) {
      final int n = waktu.length;
      if (aqi.length != n || pm25.length != n) {
        throw const FormatException('Panjang data per jam tidak sama');
      }
      final aqiPerHari = <String, List<int>>{};
      final pmPerHari = <String, List<double>>{};
      for (int i = 0; i < n; i++) {
        final String hari = (waktu[i] as String).substring(0, 10);
        aqiPerHari.putIfAbsent(hari, () => []);
        pmPerHari.putIfAbsent(hari, () => []);
        final a = (aqi[i] as num?)?.round();
        final p = (pm25[i] as num?)?.toDouble();
        if (a != null) aqiPerHari[hari]!.add(a);
        if (p != null) pmPerHari[hari]!.add(p);
      }
      return [
        for (final hari in aqiPerHari.keys)
          PrakiraanHarian(
            tanggal: DateTime.parse(hari),
            aqiMaks: aqiPerHari[hari]!.isEmpty
                ? null
                : aqiPerHari[hari]!.reduce((a, b) => a > b ? a : b),
            pm25Rata: pmPerHari[hari]!.isEmpty
                ? null
                : pmPerHari[hari]!.reduce((a, b) => a + b) /
                    pmPerHari[hari]!.length,
          ),
      ];
    }
    throw const FormatException('Bentuk data per jam tidak sesuai');
  }
}
