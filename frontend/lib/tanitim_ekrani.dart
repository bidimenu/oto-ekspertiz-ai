import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class TanitimEkrani extends StatefulWidget {
  const TanitimEkrani({super.key});

  @override
  State<TanitimEkrani> createState() => _TanitimEkraniState();
}

class _TanitimEkraniState extends State<TanitimEkrani> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "baslik": "İlanı Paylaş",
      "alt": "Arabanın ilan linkini veya fotoğrafını yükle, gerisini yapay zekaya bırak.",
      "icon": "📲"
    },
    {
      "baslik": "Derin Analiz",
      "alt": "Gemini AI, aracın motor kodundan kronik sorunlarına kadar her şeyi tarasın.",
      "icon": "🧠"
    },
    {
      "baslik": "Akıllı Karar",
      "alt": "Piyasa değerini gör, zarar etmeden en doğru aracı satın al.",
      "icon": "💎"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(_pages[index]["icon"]!, style: const TextStyle(fontSize: 100)),
                  const SizedBox(height: 40),
                  Text(_pages[index]["baslik"]!, 
                    style: GoogleFonts.rajdhani(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(_pages[index]["alt"]!, 
                      textAlign: TextAlign.center, 
                      style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _tamamla(),
                  child: const Text("ATLA", style: TextStyle(color: Colors.grey)),
                ),
                Row(
                  children: List.generate(_pages.length, (index) => 
                    Container(
                      margin: const EdgeInsets.all(4),
                      width: _currentPage == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.cyan,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.cyan),
                  onPressed: () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    } else {
                      _tamamla();
                    }
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _tamamla() {
    // Burada SharedPreferences ile "tanitimi_gordu = true" yapmalısın (Daha sonra yapacağız)
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AnalizEkrani()));
  }
}