import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RaporSayfasi extends StatelessWidget {
  final Map<String, dynamic> veri;

  const RaporSayfasi({super.key, required this.veri});

  void _raporuPaylas(BuildContext context) {
    final arac = veri['arac_bilgileri'] ?? {};
    final teknik = veri['teknik_ve_kronik_bilgiler'] ?? {};

    String text = """
🚗 AI OTO ANALİZ RAPORU

Araç: ${arac['marka']} ${arac['model']}
KM: ${_formatSayi(arac['kilometre'])}
Yıl: ${arac['yil']}

AI Yorumu:
${teknik['yapay_zeka_mekanik_yorumu'] ?? "-"}
""";

    Share.share(text);
  }

  String _formatSayi(dynamic sayi) {
    if (sayi == null) return "-";
    String temiz = sayi.toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (temiz.isEmpty) return sayi.toString();
    return temiz.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final arac = veri['arac_bilgileri'] ?? {};
    final teknik = veri['teknik_ve_kronik_bilgiler'] ?? {};
    final piyasa = veri['piyasa_analizi'] ?? {};

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _topBar(context),
                const SizedBox(height: 20),
                _scoreCard(piyasa, teknik),
                const SizedBox(height: 20),
                _carInfo(arac),
                const SizedBox(height: 20),
                _aiComment(teknik),
                const SizedBox(height: 20),
                _riskList(teknik),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔝 TOP BAR
  Widget _topBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white)),
        Text(
          "AI RAPOR",
          style: GoogleFonts.orbitron(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        IconButton(
            onPressed: () => _raporuPaylas(context),
            icon: const Icon(Icons.share, color: Colors.white)),
      ],
    );
  }

  // 🧠 SCORE CARD
  Widget _scoreCard(Map piyasa, Map teknik) {
    String fiyat = piyasa['fiyat_degerlendirmesi']?.toString() ?? "";

    int skor = 70;

    if (fiyat.contains("FIRSAT")) skor += 15;
    if (fiyat.contains("PAHALI")) skor -= 15;
    if ((teknik['kronik_sorunlar'] as List?)?.isNotEmpty ?? false) skor -= 10;

    String karar = skor > 75
        ? "ALINIR"
        : skor > 60
            ? "DİKKATLİ"
            : "UZAK DUR";

    Color renk = skor > 75
        ? Colors.greenAccent
        : skor > 60
            ? Colors.orangeAccent
            : Colors.redAccent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          colors: [Color(0xFF00F5A0), Color(0xFF00D9F5)],
        ),
        boxShadow: [
          BoxShadow(color: Colors.cyan.withOpacity(0.5), blurRadius: 30)
        ],
      ),
      child: Column(
        children: [
          Text("$skor / 100",
              style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: renk,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              karar,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // 🚗 CAR INFO
  Widget _carInfo(Map arac) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${arac['marka']} ${arac['model']}",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(
            "${_formatSayi(arac['kilometre'])} km • ${arac['yil']}",
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  // 🤖 AI COMMENT
  Widget _aiComment(Map teknik) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.smart_toy, color: Colors.cyan),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              teknik['yapay_zeka_mekanik_yorumu'] ??
                  "AI analiz hazırlanıyor...",
              style: const TextStyle(color: Colors.white70),
            ),
          )
        ],
      ),
    );
  }

  // ⚠️ RISK LIST
  Widget _riskList(Map teknik) {
    final liste = teknik['kronik_sorunlar'] as List? ?? [];

    if (liste.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Text(
          "Risk bulunamadı ✅",
          style: TextStyle(color: Colors.greenAccent),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("RİSKLER",
            style: TextStyle(color: Colors.redAccent)),
        const SizedBox(height: 10),
        ...liste.map((e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(e,
                  style: const TextStyle(color: Colors.white)),
            ))
      ],
    );
  }
}