import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart'; 
import 'package:shared_preferences/shared_preferences.dart'; // 🚀 Import ekle


class OnboardingEkrani extends StatefulWidget {
  const OnboardingEkrani({super.key});

  @override
  State<OnboardingEkrani> createState() => _OnboardingEkraniState();
}

class _OnboardingEkraniState extends State<OnboardingEkrani> {
  final PageController _pageController = PageController(initialPage: 0);
  int _mevcutSayfa = 0;

  final List<Map<String, dynamic>> onboardingVerileri = [
    {
      "baslik": "İlanı Çek, Yükle\nAnalizi Başlat",
      "aciklama": "Araç ilanının ekran görüntüsünü yükleyin veya teknik özelliklerini doğrudan yazın.",
      "ikon": Icons.screenshot_monitor_rounded,
      "renk": const Color(0xFF00D2D3),
    },
    {
      "baslik": "Yapay Zeka ile\nSaniyeler İçinde Rapor",
      "aciklama": "Modelimiz; aracın kaporta, boya ve değişen durumunu saniyeler içinde analiz etsin.",
      "ikon": Icons.document_scanner_outlined,
      "renk": Colors.blueAccent,
    },
    {
      "baslik": "Kronik Sorunlar ve\nGerçek Piyasa Değeri",
      "aciklama": "Gözden kaçabilecek arıza risklerini ve aracın güncel piyasa fiyatını güvenle öğrenin.",
      "ikon": Icons.price_check_rounded,
      "renk": Colors.orangeAccent,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _sayfaDegistir(int index) {
    setState(() {
      _mevcutSayfa = index;
    });
  }

Future<void> _uygulamayaGec() async {
    // 🚀 Hafızaya "Bu kullanıcı tanıtımı gördü" notunu düşüyoruz
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tanitim_goruldu', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AnalizEkrani()), 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 🚀 ÜST KISIM (ATLA BUTONU)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _uygulamayaGec,
                    child: Text(
                      "Geç",
                      style: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),

            // 🚀 ORTA KISIM (KAYDIRILABİLİR İÇERİK - DARALTILDI)
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: _sayfaDegistir,
                itemCount: onboardingVerileri.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // İkon boyutu ve etrafındaki boşluk küçültüldü
                        Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: onboardingVerileri[index]["renk"].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            onboardingVerileri[index]["ikon"],
                            size: 70, // 90'dan 70'e düşürüldü
                            color: onboardingVerileri[index]["renk"],
                          ),
                        ),
                        const SizedBox(height: 30), // 40'tan 30'a düşürüldü
                        
                        Text(
                          onboardingVerileri[index]["baslik"],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rajdhani(
                            fontSize: 24, // 26'dan 24'e düşürüldü
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12), // 15'ten 12'ye düşürüldü
                        
                        Text(
                          onboardingVerileri[index]["aciklama"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // 🚀 ALT KISIM (İLERLEME ÇUBUĞU VE BUTON)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20), // Alt boşluklar sıkılaştırıldı
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingVerileri.length,
                      (index) => _buildDot(index: index),
                    ),
                  ),
                  const SizedBox(height: 25), // 30'dan 25'e düşürüldü
                  SizedBox(
                    width: double.infinity,
                    height: 55, 
                    child: ElevatedButton(
                      onPressed: () {
                        if (_mevcutSayfa == onboardingVerileri.length - 1) {
                          _uygulamayaGec();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D2D3),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Text(
                        _mevcutSayfa == onboardingVerileri.length - 1 ? "HEMEN BAŞLA" : "İLERİ",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required int index}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _mevcutSayfa == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _mevcutSayfa == index ? const Color(0xFF00D2D3) : Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}