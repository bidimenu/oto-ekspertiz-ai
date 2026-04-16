import 'main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'onboarding_ekrani.dart'; // 🚀 Yeni yaptığımız ekrana yönlendirildi
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // 🚀 Animasyon Kontrolcüsü
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Hafifçe büyüme efekti (Premium his)
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack)
    );

    // Karanlıktan aydınlığa yumuşak geçiş
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn)
    );

    _controller.forward(); // Animasyonu başlat

    // 2.5 saniye sonra geçiş yap
Timer(const Duration(milliseconds: 2500), () async {
      final prefs = await SharedPreferences.getInstance();
      // 'tanitim_goruldu' değeri yoksa (null ise) false kabul et
      bool tanitimGoruldu = prefs.getBool('tanitim_goruldu') ?? false;

      if (mounted) {
        if (tanitimGoruldu) {
          // 🚀 Daha önce görmüş, direkt ana ekrana!
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const AnalizEkrani()),
          );
        } else {
          // 🚀 İlk kez açıyor, tanıtıma gönder
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const OnboardingEkrani()),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🚀 Karanlık temadan aydınlığa geçtik
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🚀 Yeni temamızla uyumlu Turkuaz/Beyaz ikon kutusu
                Container(
                  padding: const EdgeInsets.all(35),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D2D3).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.document_scanner_rounded, color: Color(0xFF00D2D3), size: 80),
                ),
                const SizedBox(height: 30),
                
                Text(
                  "AUTO-SCAN PRO",
                  style: GoogleFonts.rajdhani(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                
                Text(
                  "YAPAY ZEKA DESTEKLİ EKSPERTİZ",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12, letterSpacing: 1.5, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}