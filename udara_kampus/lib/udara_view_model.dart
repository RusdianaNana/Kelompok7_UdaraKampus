import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'layanan_open_meteo.dart';
import 'model.dart';

enum StatusMuat { memuat, berhasil, gagal }

String pesanRamah(Object galat) {
  return switch (galat) {
    SocketException() || http.ClientException() =>
      'Tidak dapat terhubung. Periksa koneksi internet Anda.',
    TimeoutException() => 'Server terlalu lama menjawab. Coba lagi sebentar lagi.',
    ApiException(:final kodeStatus) =>
      'Layanan sedang bermasalah (kode $kodeStatus). Coba lagi nanti.',
    FormatException() => 'Data dari server tidak dapat dibaca.',
    _ => 'Terjadi kesalahan tak terduga.',
  };
}

class UdaraViewModel extends ChangeNotifier {
  UdaraViewModel(this._repositori);
  final UdaraRepositori _repositori;

  Kota _kota = daftarKota.first;
  StatusMuat _status = StatusMuat.memuat;
  DataUdara? _data;
  DateTime? _diperbarui;
  String _pesanGalat = '';
  int _nomorPermintaan = 0;
  bool _sudahDibuang = false;

  Kota get kota => _kota;
  StatusMuat get status => _status;
  DataUdara? get data => _data;
  DateTime? get diperbarui => _diperbarui;
  String get pesanGalat => _pesanGalat;

  Future<void> muat({bool tampilkanMemuat = true}) async {
    final int nomor = ++_nomorPermintaan;
    if (tampilkanMemuat) {
      _status = StatusMuat.memuat;
      notifyListeners();
    }
    try {
      final DataUdara data = await _repositori.ambil(_kota);
      if (_sudahDibuang || nomor != _nomorPermintaan) {
        return; // jawaban terlambat (kota sudah diganti)
      }
      _data = data;
      _diperbarui = DateTime.now();
      _status = StatusMuat.berhasil;
    } catch (galat) {
      if (_sudahDibuang || nomor != _nomorPermintaan) {
        return;
      }
      debugPrint('Galat saat memuat udara: $galat');
      _pesanGalat = pesanRamah(galat);
      _status = StatusMuat.gagal;
    }
    notifyListeners();
  }

  Future<void> segarkan() => muat(tampilkanMemuat: false);

  void pilihKota(Kota kota) {
    if (kota == _kota) {
      return;
    }
    _kota = kota;
    muat();
  }

  @override
  void dispose() {
    _sudahDibuang = true;
    super.dispose();
  }
}
