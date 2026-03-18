import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'main.dart'; // Ana ekrana yönlendirme için
import 'tanitim_ekrani.dart'; // 🚀 Splash ekranını ana dosyaya tanıttık


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true); // Pulse (Nefes alma) efekti
    
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // 3 saniye sonra ana ekrana geçiş yap
// splash_ekrani.dart içinde
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const TanitimEkrani()), // AnalizEkrani yerine TanitimEkrani'na git
      );
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
      backgroundColor: const Color(0xFF121212), // Premium Dark Arka Plan
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bolt, color: Colors.cyan, size: 80), // Ana ikonumuz
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "AUTO-SCAN PRO",
              style: GoogleFonts.rajdhani(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "YAPAY ZEKA DESTEKLİ EKSPERTİZ",
              style: TextStyle(color: Colors.grey, fontSize: 12, letterSpacing: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}