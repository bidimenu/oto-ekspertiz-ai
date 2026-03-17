import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'ekspertiz_sema.dart';
import 'dart:convert'; // 🚀 BU SATIRI EKLE!

class RaporSayfasi extends StatelessWidget {
  final Map<String, dynamic> veri;

  const RaporSayfasi({super.key, required this.veri});

  void _raporuPaylas(BuildContext context) {
    try {
      final arac = veri['arac_bilgileri'] ?? {};
      final teknik = veri['teknik_ve_kronik_bilgiler'] ?? {};
      final piyasa = veri['piyasa_analizi'] ?? {};
      final guven = veri['guven_skoru'] ?? '-';

      String paylasimMetni = """
🚗 *OTO ANALİZ PRO RAPORU* 🚗
---------------------------------------
📌 *Araç:* ${arac['marka'] ?? ''} ${arac['model'] ?? ''} (${arac['yil'] ?? '-'})
💰 *Fiyat:* ${_formatSayi(arac['fiyat'])} TL
🛣️ *KM:* ${_formatSayi(arac['kilometre'])} km

🎯 *Yapay Zeka Güven Skoru:* $guven

🛠️ *Yapay Zeka Mekanik Yorumu:*
"${teknik['yapay_zeka_mekanik_yorumu'] ?? 'Analiz mevcut değil.'}"

📊 *Piyasa Değerlendirmesi:*
• Likidite: ${piyasa['ikinci_el_likiditesi'] ?? '-'}
• Fiyat Durumu: ${piyasa['fiyat_degerlendirmesi'] ?? '-'}

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
    // Eğer gelen veri sayı değilse (örn: "Bilinmiyor" metniyse) temizle
    String temizSayi = sayi.toString().replaceAll(RegExp(r'[^0-9]'), '');
    if (temizSayi.isEmpty) return sayi.toString();
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return temizSayi.replaceAllMapped(reg, (Match m) => '${m[1]}.');
  }

  int _parseSkor(dynamic skorVerisi) {
    if (skorVerisi == null) return 0;
    String str = skorVerisi.toString();
    final RegExp regExp = RegExp(r'\d+'); 
    final match = regExp.firstMatch(str);
    if (match != null) {
      return int.tryParse(match.group(0)!) ?? 0;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {

    print("GELEN TÜM VERİ: ${jsonEncode(veri)}");

    final arac = veri['arac_bilgileri'] ?? {};
    final teknik = veri['teknik_ve_kronik_bilgiler'] ?? {};
    final ekspertiz = veri['ekspertiz_durumu'] ?? {};
    final piyasa = veri['piyasa_analizi'] ?? {};
    // 🚀 KRİTİK: Backend anahtarı 'guven_skoru' ile tam eşleşmeli
    final hamGuvenSkoru = veri['guven_skoru'] ?? 'Hesaplanamadı';

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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
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
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        arac['kasa_kodu'] ?? "Genel Analiz",
                        style: const TextStyle(color: Color(0xFF00D2D3), fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      // 🚀 GÜNCELLEME: Fiyat kutusu taşma koruması
                      Flexible( 
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          margin: const EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D2D3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            (arac['fiyat'].toString().contains("Bilinmiyor") || arac['fiyat'] == null)
                                ? "Fiyat Belirtilmedi"
                                : "${_formatSayi(arac['fiyat'])} TL",
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF00B2B2)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(color: Color(0xFFF0F0F0))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ozetHucre("YIL", arac['yil'].toString()),
                      _ozetHucre("KM", _formatSayi(arac['kilometre'])),
                      _ozetHucre("YAKIT", arac['yakit_tipi'] ?? "-"),
                      _ozetHucre("VİTES", arac['vites'] ?? "-"),
                    ],
                  ),
                  const SizedBox(height: 30),
                  EkspertizSema(
                    boyali: ekspertiz['boyali_parcalar'] ?? [],
                    degisen: ekspertiz['degisen_parcalar'] ?? [],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // 🚀 KRİTİK DÜZELTME: Doğru değişkeni gönderiyoruz
            _buildGuvenSkoruKarti(hamGuvenSkoru),

            const SizedBox(height: 20),
            _eliteBilgiKarti(
              baslik: "Ustasının Mekanik Analizi",
              icon: Icons.auto_awesome,
              accentColor: Colors.blueAccent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bilgiSatiri("Motor / Şanzıman", "${teknik['motor_kodu'] ?? '-'} - ${teknik['sanziman_tipi'] ?? '-'}"),
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
                      style: const TextStyle(fontSize: 14, height: 1.5, fontStyle: FontStyle.italic, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text("⚠️ TESPİT EDİLEN KRONİK RİSKLER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.redAccent, letterSpacing: 0.5)),
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
                ],
              ),
            ),
            const SizedBox(height: 20),
            _eliteBilgiKarti(
              baslik: "Piyasa ve Fiyat",
              icon: Icons.insights,
              accentColor: const Color(0xFF00D2D3),
              child: Column(
                children: [
                  _bilgiSatiri("Satış Hızı Skoru", piyasa['ikinci_el_likiditesi']),
                  _bilgiSatiri("Fiyat Analizi", piyasa['fiyat_degerlendirmesi']),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGuvenSkoruKarti(String hamVeri) {
    int skor = _parseSkor(hamVeri);
    Color skorRengi = Colors.redAccent;
    String durumMetni = "Yüksek Riskli";
    IconData durumIkonu = Icons.dangerous_outlined;

    if (hamVeri == 'Hesaplanamadı' || hamVeri == 'Belirtilmemiş') {
      skorRengi = Colors.grey;
      durumMetni = "Analiz Bekleniyor";
      durumIkonu = Icons.hourglass_empty;
    } else if (skor >= 75) {
      skorRengi = Colors.green;
      durumMetni = "Gözü Kapalı Alınır";
      durumIkonu = Icons.verified_user_outlined;
    } else if (skor >= 50) {
      skorRengi = Colors.orange;
      durumMetni = "Dikkatli İncelenmeli";
      durumIkonu = Icons.warning_amber_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text("YAPAY ZEKA GÜVEN SKORU", style: GoogleFonts.rajdhani(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[600])),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: skor / 100,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey[200],
                      color: skorRengi,
                    ),
                    Center(child: Text("%$skor", style: GoogleFonts.rajdhani(fontSize: 20, fontWeight: FontWeight.bold, color: skorRengi))),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(durumIkonu, color: skorRengi, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            durumMetni, 
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: skorRengi),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hamVeri, 
                      style: const TextStyle(fontSize: 10, color: Colors.black54, height: 1.3),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )
            ],
          ),
        ],
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
          Text(icerik?.toString() ?? "-", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87)),
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
              Expanded(child: Text(baslik, style: GoogleFonts.rajdhani(fontSize: 17, fontWeight: FontWeight.bold))),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}