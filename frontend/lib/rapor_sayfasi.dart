import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ekspertiz_sema.dart';
import 'dart:convert';

class RaporSayfasi extends StatelessWidget {
  final Map<String, dynamic> veri;

  const RaporSayfasi({super.key, required this.veri});

  // --- 🚀 PAYLAŞIM FONKSİYONU (YENİ VERİLER EKLENDİ) ---
  void _raporuPaylas(BuildContext context) {
    try {
      final arac = veri['arac_bilgileri'] ?? {};
      final teknik = veri['teknik_ve_kronik_bilgiler'] ?? {};
      final piyasa = veri['piyasa_analizi'] ?? {};

      String paylasimMetni = """
🚗 *OTO ANALİZ PRO RAPORU* 🚗
---------------------------------------
📌 *Araç:* ${arac['marka'] ?? ''} ${arac['model'] ?? ''} (${arac['yil'] ?? '-'})
🏗️ *Kasa/Motor:* ${arac['kasa_kodu'] ?? '-'} / ${teknik['motor_kodu'] ?? '-'}
💰 *Fiyat:* ${_formatSayi(arac['fiyat'])} TL
🛣️ *KM:* ${_formatSayi(arac['kilometre'])} km

🛠️ *Usta Yorumu:*
"${teknik['yapay_zeka_mekanik_yorumu'] ?? 'Analiz mevcut değil.'}"

💡 _Bu rapor OTO ANALİZ PRO AI tarafından oluşturulmuştur._
""";

      Share.share(paylasimMetni);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Paylaşım başlatılamadı: $e")),
      );
    }
  }

  String _formatSayi(dynamic sayi) {
    if (sayi == null || sayi.toString().isEmpty) return "-";
    String temizSayi = sayi.toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (temizSayi.isEmpty) return sayi.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return temizSayi.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  @override
  Widget build(BuildContext context) {
    final arac = veri['arac_bilgileri'] ?? {};
    final teknik = veri['teknik_ve_kronik_bilgiler'] ?? {};
    final piyasa = veri['piyasa_analizi'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        title: Text(
          "EKSPER RAPORU", 
          style: GoogleFonts.rajdhani(
            color: Colors.black87, 
            fontWeight: FontWeight.bold, 
            fontSize: 20, 
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black87),
            onPressed: () => _raporuPaylas(context),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // 1. ANA ARAÇ KARTI (Kasa Kodu ve Fiyat Sola Yaslı)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 30, offset: const Offset(0, 15))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${arac['marka'] ?? ''} ${arac['model'] ?? ''}".toUpperCase(),
                    style: GoogleFonts.rajdhani(fontSize: 22, fontWeight: FontWeight.bold, height: 1.1, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // 🏗️ YENİ: Kasa Kodu (F30, MK7 vb.)
                      Text(
                        arac['kasa_kodu'] ?? "Genel Analiz",
                        style: const TextStyle(color: Color(0xFF00D2D3), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(width: 12),
                      Flexible( 
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D2D3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (arac['fiyat'].toString().contains("Bilinmiyor") || arac['fiyat'] == null)
                                ? "Fiyat Belirtilmedi"
                                : "${_formatSayi(arac['fiyat'])} TL",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF00B2B2)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFF0F0F0))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ozetHucre("YIL", arac['yil'].toString()),
                      _ozetHucre("KM", _formatSayi(arac['kilometre'])),
                      _ozetHucre("YAKIT", arac['yakit_tipi'] ?? "-"),
                      _ozetHucre("VİTES", arac['vites'] ?? "-"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. MEKANİK VE KRONİK BİLGİLER (Usta Modu)
            _eliteBilgiKarti(
              baslik: "Ustasının Mekanik Analizi",
              icon: Icons.auto_awesome,
              accentColor: Colors.blueAccent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🏗️ YENİ: Motor Kodu ve Şanzıman Detayı
                  _bilgiSatiri("Motor Kodu / Şanzıman", "${teknik['motor_kodu'] ?? '-'} / ${teknik['sanziman_tipi'] ?? '-'}"),
                  
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D2D3).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF00D2D3).withOpacity(0.1)),
                    ),
                    child: Text(
                      teknik['yapay_zeka_mekanik_yorumu'] ?? "Analiz tamamlanıyor...",
                      style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("⚠️ KRONİK RİSKLER & USTA TAVSİYESİ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.redAccent, letterSpacing: 0.5)),
                  const SizedBox(height: 10),
                  ...(teknik['kronik_sorunlar'] as List? ?? []).map((s) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.redAccent),
                          const SizedBox(width: 8),
                          Expanded(child: Text(s, style: const TextStyle(fontSize: 13, color: Colors.black87))),
                        ],
                      ),
                    )),
                  const Divider(height: 30),
                  _bilgiSatiri("Ağır Bakım Tahmini", teknik['agir_bakim_tahmini']),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. PİYASA ANALİZİ
            _eliteBilgiKarti(
              baslik: "Piyasa ve Fiyat",
              icon: Icons.insights,
              accentColor: const Color(0xFF00D2D3),
              child: Column(
                children: [
                  _bilgiSatiri("Satış Hızı (Likidite)", piyasa['ikinci_el_likiditesi']),
                  _bilgiSatiri("Fiyat Değerlendirmesi", piyasa['fiyat_degerlendirmesi']),
                ],
              ),
            ),

            // 4. ÖZET RAPOR (Alt Kısım)
            const SizedBox(height: 20),
            _eliteBilgiKarti(
              baslik: "Eksper Özeti", 
              icon: Icons.description_outlined, 
              accentColor: Colors.orangeAccent, 
              child: Text(
                veri['kapsamli_ekspertiz_raporu'] ?? "-",
                style: const TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
              )
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _ozetHucre(String etiket, String deger) {
    return Column(
      children: [
        Text(etiket, style: GoogleFonts.rajdhani(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(deger, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _bilgiSatiri(String baslik, dynamic icerik) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(baslik.toUpperCase(), style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(
            icerik?.toString() ?? "-", 
            style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.bold)
          ),
        ],
      ),
    );
  }

  Widget _eliteBilgiKarti({required String baslik, required IconData icon, required Color accentColor, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: accentColor),
              const SizedBox(width: 10),
              Expanded(child: Text(baslik, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87))),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}