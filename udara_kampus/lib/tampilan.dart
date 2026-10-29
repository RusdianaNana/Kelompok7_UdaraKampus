import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'model.dart';
import 'udara_view_model.dart';

class UdaraApp extends StatelessWidget {
  const UdaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Udara Kampus',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.light),
      darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.teal,
          brightness: Brightness.dark),
      home: const HalamanUtama(),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Udara Kampus')),
      body: const Column(
        children: [PilihanKota(), Expanded(child: IsiHalaman())],
      ),
    );
  }
}

class PilihanKota extends StatelessWidget {
  const PilihanKota({super.key});

  @override
  Widget build(BuildContext context) {
    // Hanya dibangun ulang saat kota berganti.
    final Kota dipilih = context.select((UdaraViewModel vm) => vm.kota);
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: daftarKota.length,
separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final Kota kota = daftarKota[i];
          return ChoiceChip(
            label: Text(kota.nama),
            selected: kota == dipilih,
            onSelected: (_) => context.read<UdaraViewModel>().pilihKota(kota),
          );
        },
      ),
    );
  }
}

class IsiHalaman extends StatelessWidget {
  const IsiHalaman({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UdaraViewModel>();
    return switch (vm.status) {
      StatusMuat.memuat => const Center(child: CircularProgressIndicator()),
      StatusMuat.gagal => TampilanGalat(pesan: vm.pesanGalat),
      StatusMuat.berhasil => RefreshIndicator(
          onRefresh: () => context.read<UdaraViewModel>().segarkan(),
          child: IsiUdara(
              kota: vm.kota, data: vm.data!, diperbarui: vm.diperbarui!),
        ),
    };
  }
}

class TampilanGalat extends StatelessWidget {
  const TampilanGalat({super.key, required this.pesan});
  final String pesan;

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off,
                size: 72, color: warna.error, semanticLabel: 'Gagal memuat'),
            const SizedBox(height: 16),
            Text(pesan, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.read<UdaraViewModel>().muat(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba lagi'),
            ),
          ],
        ),
      ),
    );
  }
}

String _jam(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';

String _angka(double? v) => v == null ? '-' : v.toStringAsFixed(1);

class IsiUdara extends StatelessWidget {
  const IsiUdara(
      {super.key,
      required this.kota,
      required this.data,
      required this.diperbarui});
  final Kota kota;
  final DataUdara data;
  final DateTime diperbarui;

  @override
  Widget build(BuildContext context) {
    final u = data.saatIni;
    final teks = Theme.of(context).textTheme;
    return ListView(
      // Selalu bisa ditarik walau isinya pendek.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _KartuUtama(kota: kota, udara: u, diperbarui: diperbarui),
        const SizedBox(height: 20),
        Text('Detail polutan', style: teks.titleMedium),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.25,
          children: [
            _Polutan('PM2.5', _angka(u.pm25), 'µg/m³'),
            _Polutan('PM10', _angka(u.pm10), 'µg/m³'),
            _Polutan('CO', _angka(u.co), 'µg/m³'),
            _Polutan('NO₂', _angka(u.no2), 'µg/m³'),
            _Polutan('SO₂', _angka(u.so2), 'µg/m³'),
            _Polutan('O₃', _angka(u.o3), 'µg/m³'),
          ],
        ),
        const SizedBox(height: 20),
        Text('Prakiraan 7 hari', style: teks.titleMedium),
        const SizedBox(height: 8),
        for (int i = 0; i < data.harian.length; i++)
          _BarisHari(indeks: i, hari: data.harian[i]),
        const SizedBox(height: 16),
        Text(
          'Sumber data: Open-Meteo Air Quality API (CC BY 4.0). '
          'Indeks memakai skala US AQI; nilai harian adalah AQI tertinggi dalam sehari.',
          style: teks.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _KartuUtama extends StatelessWidget {
  const _KartuUtama(
      {required this.kota, required this.udara, required this.diperbarui});
  final Kota kota;
  final KualitasUdara udara;
  final DateTime diperbarui;

  @override
  Widget build(BuildContext context) {
    final k = udara.kategori;
    const putih = Colors.white;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [k.warna, Color.lerp(k.warna, Colors.black, 0.35)!],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(kota.nama,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(color: putih)),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(k.ikon, size: 64, color: putih, semanticLabel: k.label),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${udara.aqi ?? '-'}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: putih, fontWeight: FontWeight.bold)),
                  const Text('US AQI', style: TextStyle(color: putih)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(k.label,
              style: const TextStyle(
                  color: putih, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(k.saran, style: const TextStyle(color: putih)),
          const SizedBox(height: 12),
          Text('Diperbarui pukul ${_jam(diperbarui)}',
              style: const TextStyle(color: putih, fontSize: 12)),
        ],
      ),
    );
  }
}

class _Polutan extends StatelessWidget {
  const _Polutan(this.nama, this.nilai, this.satuan);
  final String nama, nilai, satuan;

  @override
  Widget build(BuildContext context) {
    final w = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: w.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(nama, style: TextStyle(color: w.onSurfaceVariant)),
          const SizedBox(height: 4),
          Text(nilai,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          Text(satuan, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _BarisHari extends StatelessWidget {
  const _BarisHari({required this.indeks, required this.hari});
  final int indeks;
  final PrakiraanHarian hari;

  static const _nama = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  Widget build(BuildContext context) {
    final k = hari.kategori;
    final judul = switch (indeks) {
      0 => 'Hari ini',
      1 => 'Besok',
      _ => _nama[hari.tanggal.weekday - 1],
    };
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ListTile(
        leading: Icon(k.ikon, color: k.warna, semanticLabel: k.label),
        title: Text(judul),
        subtitle: Text('${k.label} · PM2.5 rata-rata ${_angka(hari.pm25Rata)}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
              color: k.warna, borderRadius: BorderRadius.circular(20)),
          child: Text('AQI ${hari.aqiMaks ?? '-'}',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
