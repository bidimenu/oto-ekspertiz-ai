import 'package:flutter/material.dart';
import 'ekspertiz_sema.dart';

class RaporSayfasi extends StatelessWidget {
  final Map<String, dynamic> veri;

  const RaporSayfasi({super.key, required this.veri});

  // Fiyatı 5.000.000 şeklinde formatlayan yardımcı fonksiyon
  String formatPrice(dynamic price) {
    if (price == null) return "-";
    String priceStr = price.toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (priceStr.isEmpty) return "-";
    
    final buffer = StringBuffer();
    for (int i = 0; i < priceStr.length; i++) {
      if (i > 0 && (priceStr.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(priceStr[i]);
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive ölçüler
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    final arac = veri['arac_bilgileri'] ?? {};
    final teknik = veri['teknik_ve_kronik_bilgiler'] ?? {};
    final ekspertiz = veri['ekspertiz_durumu'] ?? {};
    final piyasa = veri['piyasa_analizi'] ?? {};

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("ARAÇ ANALİZ RAPORU", 
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 14, letterSpacing: 1.2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // 1. ANA KART: BAŞLIK, FİYAT VE ÖZET
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // STİLİZE MARKA & MODEL
                  Text(
                    arac['marka']?.toString().toUpperCase() ?? "",
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.w800, 
                      color: Colors.blueAccent.withOpacity(0.8), 
                      letterSpacing: 2
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    arac['model']?.toString() ?? "",
                    style: TextStyle(
                      fontSize: isSmallScreen ? 20 : 24, 
                      fontWeight: FontWeight.w900, 
                      color: Colors.black, 
                      letterSpacing: -0.5
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // FİYAT VE KASA KODU SATIRI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        arac['kasa_kodu'] ?? "",
                        style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D6A4F).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Text("FİYAT: ", 
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2D6A4F))),
                            Text(
                              "${formatPrice(arac['fiyat'])} TL",
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2D6A4F)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Color(0xFFEEEEEE))),

                  // TEMEL BİLGİLER (RESPONSIVE GRID)
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    childAspectRatio: 1.1,
                    children: [
                      _ozetHucre("YIL", arac['yil'].toString()),
                      _ozetHucre("KM", arac['kilometre'].toString()),
                      _ozetHucre("YAKIT", arac['yakit_tipi'] ?? "-"),
                      _ozetHucre("VİTES", arac['vites'] ?? "-"),
                    ],
                  ),

                  const SizedBox(height: 24),
                  EkspertizSema(
                    boyali: ekspertiz['boyali_parcalar'] ?? [],
                    degisen: ekspertiz['degisen_parcalar'] ?? [],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. TEKNİK ANALİZ VE AI YORUMU
            _sadeBilgiKarti(
              baslik: "Teknik & Kronik Analiz",
              icon: Icons.settings_suggest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bilgiSatiri("Motor Kodu", teknik['motor_kodu']),
                  _bilgiSatiri("Şanzıman", teknik['sanziman_tipi']),
                  
                  // AI MEKANİK YORUMU KUTUSU
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.blue.shade50, Colors.white]),
                      borderRadius: BorderRadius.circular(15),
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
                        const SizedBox(height: 8),
                        Text(
                          teknik['yapay_zeka_mekanik_yorumu'] ?? "-",
                          style: const TextStyle(fontSize: 13, height: 1.5, fontStyle: FontStyle.italic, color: Colors.black87),
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

            const SizedBox(height: 16),

            // 3. PİYASA ANALİZİ
            _sadeBilgiKarti(
              baslik: "Piyasa Analizi",
              icon: Icons.analytics_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bilgiSatiri("Satış Hızı", piyasa['ikinci_el_likiditesi']),
                  _bilgiSatiri("Fiyat Değerlendirmesi", piyasa['fiyat_degerlendirmesi']),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- YARDIMCI BİLEŞENLER ---

  Widget _ozetHucre(String etiket, String deger) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(etiket, style: TextStyle(color: Colors.grey[500], fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Text(deger, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _bilgiSatiri(String baslik, dynamic icerik) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(baslik.toUpperCase(),
            style: TextStyle(color: Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 6),
          Text(icerik?.toString() ?? "-",
            style: const TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _sadeBilgiKarti({required String baslik, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: Colors.black54),
            const SizedBox(width: 8),
            Text(baslik, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}