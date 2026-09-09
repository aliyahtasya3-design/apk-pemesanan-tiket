import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

// ==========================================
// 1. CUSTOM EXCEPTION
// ==========================================
class TiketHabisException implements Exception {
  final String message;
  TiketHabisException([this.message = 'Maaf, stok tiket ini telah habis!']);

  @override
  String toString() => message;
}

// ==========================================
// 2. MIXIN
// ==========================================
mixin BisaDiskon {
  double hitungHargaDiskon(double harga, double persen) {
    return harga - (harga * (persen / 100));
  }
}

// ==========================================
// 3. OOP CLASS (ABSTRACT & SUBCLASSES)
// ==========================================
abstract class Tiket {
  final String nama;
  final double harga;
  final String waktuBerangkat;
  final String waktuTiba;
  final String rute;

  Tiket({
    required this.nama,
    required this.harga,
    required this.waktuBerangkat,
    required this.waktuTiba,
    required this.rute,
  });

  // Abstract Method
  String deskripsi();
}

class TiketEkonomi extends Tiket {
  TiketEkonomi({
    required String nama,
    required double harga,
    required String waktuBerangkat,
    required String waktuTiba,
    required String rute,
  }) : super(
          nama: nama,
          harga: harga,
          waktuBerangkat: waktuBerangkat,
          waktuTiba: waktuTiba,
          rute: rute,
        );

  @override
  String deskripsi() => 'Ekonomi • Non-Refundable • Bagasi 7kg';
}

class TiketVIP extends Tiket with BisaDiskon {
  final double diskonPersen;

  TiketVIP({
    required String nama,
    required double harga,
    required String waktuBerangkat,
    required String waktuTiba,
    required String rute,
    this.diskonPersen = 15.0,
  }) : super(
          nama: nama,
          harga: harga,
          waktuBerangkat: waktuBerangkat,
          waktuTiba: waktuTiba,
          rute: rute,
        );

  double get hargaSetelahDiskon => hitungHargaDiskon(harga, diskonPersen);

  @override
  String deskripsi() => 'Ekssekutif • Reclining Seat • Bagasi 20kg + Meals';
}

// ==========================================
// 4. ASYNC SERVICES
// ==========================================
Future<List<Tiket>> ambilDaftarTiket() async {
  await Future.delayed(const Duration(seconds: 2)); // Simulasi delay API

  return [
    TiketVIP(
      nama: 'Argo Parahyangan',
      harga: 180000,
      waktuBerangkat: '08:30',
      waktuTiba: '11:00',
      rute: 'Gambir (GMR) ➔ Bandung (BD)',
      diskonPersen: 20,
    ),
    TiketEkonomi(
      nama: 'Malabar',
      harga: 90000,
      waktuBerangkat: '10:15',
      waktuTiba: '13:05',
      rute: 'Gambir (GMR) ➔ Bandung (BD)',
    ),
    TiketVIP(
      nama: 'Turangga',
      harga: 250000,
      waktuBerangkat: '09:45',
      waktuTiba: '12:30',
      rute: 'Jakarta ➔ Yogyakarta',
      diskonPersen: 15,
    ),
    TiketEkonomi(
      nama: 'Taksaka',
      harga: 120000,
      waktuBerangkat: '07:00',
      waktuTiba: '13:15',
      rute: 'Jakarta ➔ Surabaya',
    ),
  ];
}

Future<String> pesanTiket(Tiket tiket) async {
  await Future.delayed(const Duration(seconds: 2)); // Simulasi payment gateway

  // Simulasi error acak (50% kegagalan)
  bool isSuccess = Random().nextBool();
  if (!isSuccess) {
    throw TiketHabisException('Tiket ${tiket.nama} gagal dipesan (Stok Habis)!');
  }

  return 'Pemesanan ${tiket.nama} Berhasil!';
}

// ==========================================
// 5. MAIN APP WIDGET
// ==========================================
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Tiket Online',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        useMaterial3: true,
      ),
      home: const TiketHomePage(),
    );
  }
}

// ==========================================
// 6. UI HOME PAGE
// ==========================================
class TiketHomePage extends StatefulWidget {
  const TiketHomePage({super.key});

  @override
  State<TiketHomePage> createState() => _TiketHomePageState();
}

class _TiketHomePageState extends State<TiketHomePage> {
  late Future<List<Tiket>> _futureTiket;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _futureTiket = ambilDaftarTiket();
  }

  // Stream Timer untuk Hitung Mundur Promo (Bonus)
  Stream<int> promoTimerStream() async* {
    for (int i = 300; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      yield i;
    }
  }

  // Handling Try / Catch / Finally saat Pemesanan
  Future<void> _prosesPemesanan(Tiket tiket) async {
    setState(() => _isProcessing = true);

    String message = '';
    Color bannerColor = Colors.green;

    try {
      message = await pesanTiket(tiket);
    } on TiketHabisException catch (e) {
      message = e.message;
      bannerColor = Colors.red;
    } catch (e) {
      message = 'Terjadi kesalahan sistem: $e';
      bannerColor = Colors.orange;
    } finally {
      setState(() => _isProcessing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: bannerColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D47A1),
        title: const Text('Aplikasi Tiket Online', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: const [
          Icon(Icons.notifications_none, color: Colors.white),
          SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // BANNER PROMO & STREAMBUILDER (BONUS)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF0D47A1),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Halo, Aliyah 👋', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade800,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_offer, color: Colors.amber, size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Diskon Spesial s/d 20%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                StreamBuilder<int>(
                                  stream: promoTimerStream(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) return const Text('Loading timer...', style: TextStyle(color: Colors.white70));
                                    final s = snapshot.data!;
                                    final m = (s / 60).floor();
                                    final rs = s % 60;
                                    return Text(
                                      'Waktu tersisa promo: ${m.toString().padLeft(2, '0')}:${rs.toString().padLeft(2, '0')}',
                                      style: const TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // FUTUREBUILDER (DAFTAR TIKET)
              Expanded(
                child: FutureBuilder<List<Tiket>>(
                  future: _futureTiket,
                  builder: (context, snapshot) {
                    // 1. Loading State
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('Mencari jadwal tiket...'),
                          ],
                        ),
                      );
                    }

                    // 2. Error State
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 48),
                            Text('Gagal memuat: ${snapshot.error}'),
                            ElevatedButton(
                              onPressed: () => setState(() => _futureTiket = ambilDaftarTiket()),
                              child: const Text('Coba Lagi'),
                            )
                          ],
                        ),
                      );
                    }

                    // 3. Data Loaded State
                    final listTiket = snapshot.data ?? [];
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: listTiket.length,
                      itemBuilder: (context, index) {
                        final tiket = listTiket[index];
                        final isVip = tiket is TiketVIP;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(tiket.nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isVip ? Colors.blue.shade100 : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isVip ? 'Eksekutif' : 'Ekonomi',
                                        style: TextStyle(
                                          color: isVip ? Colors.blue.shade900 : Colors.black87,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(tiket.rute, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text('${tiket.waktuBerangkat} ➔ ${tiket.waktuTiba}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (isVip) ...[
                                          Text(
                                            'Rp ${tiket.harga.toInt()}',
                                            style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12),
                                          ),
                                          Text(
                                            'Rp ${(tiket as TiketVIP).hargaSetelahDiskon.toInt()}',
                                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ] else ...[
                                          Text(
                                            'Rp ${tiket.harga.toInt()}',
                                            style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                        ]
                                      ],
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0D47A1),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: _isProcessing ? null : () => _prosesPemesanan(tiket),
                                      child: const Text('Pesan'),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // OVERLAY LOADING SAAT MEMPROSES PEMESANAN (Perbaikan dilakukan di sini)
          if (_isProcessing)
            Container(
              color: Colors.black45,
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Memproses Pembayaran...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}