import 'package:flutter/material.dart';
import 'ekspertiz_sema.dart';

class RaporSayfasi extends StatelessWidget {
  final Map<String, dynamic> veri;

  const RaporSayfasi({super.key, required this.veri});

  @override
  Widget build(BuildContext context) {
    final arac = veri['arac_bilgileri'] ?? {};
    final teknik = veri['teknik_ve_kronik_bilgiler'] ?? {};
    final ekspertiz = veri['ekspertiz_durumu'] ?? {};
    final piyasa = veri['piyasa_analizi'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Araç Analiz Raporu", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 18)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // 1. ANA ÖZET KARTI
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DÜZELTİLEN BAŞLIK VE FİYAT BÖLÜMÜ
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${arac['marka']} ${arac['model']}".toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.w900, 
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            arac['kasa_kodu'] ?? "",
                            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            "${arac['fiyat']} TL",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFFEEEEEE))),

                  // Temel Bilgiler (Grid)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ozetHucre("YIL", arac['yil'].toString()),
                      _ozetHucre("KM", arac['kilometre'].toString()),
                      _ozetHucre("YAKIT", arac['yakit_tipi'] ?? "-"),
                      _ozetHucre("VİTES", arac['vites'] ?? "-"),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Ekspertiz Durumu (Boya/Değişen Widget'ın)
                  EkspertizSema(
                    boyali: ekspertiz['boyali_parcalar'] ?? [],
                    degisen: ekspertiz['degisen_parcalar'] ?? [],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. TEKNİK VE KRONİK BİLGİLER KARTI
          _sadeBilgiKarti(
  baslik: "Teknik & Kronik Analiz",
  icon: Icons.settings_suggest,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _bilgiSatiri("Motor Kodu", teknik['motor_kodu']),
      _bilgiSatiri("Şanzıman", teknik['sanziman_tipi']),
      
      // YENİ: YAPAY ZEKA MEKANİK YORUMU
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.auto_awesome, size: 14, color: Colors.blueAccent),
                SizedBox(width: 6),
                Text("AI MEKANİK YORUMU", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              teknik['yapay_zeka_mekanik_yorumu'] ?? "Bu kombinasyon hakkında detaylı analiz yapılıyor...",
              style: const TextStyle(fontSize: 13, height: 1.4, fontStyle: FontStyle.italic, color: Colors.black87),
            ),
          ],
        ),
      ),
      
      const SizedBox(height: 20),
      const Text("⚠️ KRONİK SORUNLAR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.redAccent)),
      const SizedBox(height: 8),
      ...(teknik['kronik_sorunlar'] as List? ?? []).map((s) => 
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text("• $s", style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4)),
        )),
      const Divider(height: 32),
      _bilgiSatiri("Ağır Bakım Tahmini", teknik['agir_bakim_tahmini']),
    ],
  ),
),

            // 3. PİYASA ANALİZİ KARTI
            _sadeBilgiKarti(
              baslik: "Piyasa Analizi",
              icon: Icons.analytics_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bilgiSatiri("Satış Hızı", piyasa['ikinci_el_likiditesi']),
                  _bilgiSatiri("Fiyat Değerlendirmesi", piyasa['fiyat_degerlendirmesi'], altBilgi: true),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _ozetHucre(String etiket, String deger) {
    return Column(
      children: [
        Text(etiket, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(deger, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // YENİLENEN DİKEY BİLGİ SATIRI (Başlık üstte, Metin altta)
  Widget _bilgiSatiri(String sol, dynamic sag, {bool altBilgi = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            sol.toUpperCase(),
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sag?.toString() ?? "-",
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: altBilgi ? FontWeight.normal : FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sadeBilgiKarti({required String baslik, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.black54),
              const SizedBox(width: 8),
              Text(baslik, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}