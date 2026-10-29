import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'layanan_open_meteo.dart';
import 'tampilan.dart';
import 'udara_view_model.dart';
import 'uji.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await jalankanUji(); // pemeriksaan sebelum aplikasi tampil
  final repositori = UdaraRepositori(LayananOpenMeteo(http.Client()));
  runApp(
    ChangeNotifierProvider(
      create: (_) => UdaraViewModel(repositori)..muat(),
      child: const UdaraApp(),
    ),
  );
}
