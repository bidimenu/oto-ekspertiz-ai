import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:desktop_window/desktop_window.dart';
import 'package:google_fonts/google_fonts.dart'; // Yeni ekledik
import 'rapor_sayfasi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    await DesktopWindow.setWindowSize(const Size(450, 850));
    await DesktopWindow.setMinWindowSize(const Size(400, 800));
  }
  runApp(const OtoEkspertizApp());
}

class OtoEkspertizApp extends StatelessWidget {
  const OtoEkspertizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AUTO-SCAN PRO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.interTextTheme(), // Modern tipografi
        scaffoldBackgroundColor: const Color(0xFFF5F5F7), // Apple tarzı soft gri
      ),
      home: const AnalizEkrani(),
    );
  }
}

class AnalizEkrani extends StatefulWidget {
  const AnalizEkrani({super.key});
  @override
  State<AnalizEkrani> createState() => _AnalizEkraniState();
}

class _AnalizEkraniState extends State<AnalizEkrani> {
  File? fotoDetay;
  File? fotoAciklama;
  bool yukleniyor = false;
  Map<String, dynamic>? sonuc;
  final picker = ImagePicker();

  Future fotoSec(bool detayMi) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    setState(() {
      if (pickedFile != null) {
        if (detayMi) fotoDetay = File(pickedFile.path);
        else fotoAciklama = File(pickedFile.path);
      }
    });
  }

  Future analizGonder() async {
    if (fotoDetay == null || fotoAciklama == null) return;
    setState(() => yukleniyor = true);
    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8000/analiz'));
      request.files.add(await http.MultipartFile.fromPath('foto_detay', fotoDetay!.path));
      request.files.add(await http.MultipartFile.fromPath('foto_aciklama', fotoAciklama!.path));
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        sonuc = json.decode(responseData);
        if (!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => RaporSayfasi(veri: sonuc!)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    } finally {
      setState(() => yukleniyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER SECTİON
              _buildHeader(),
              const SizedBox(height: 40),

              // UPLOAD CARDS
              _buildUploadCard(
                title: "İLAN AÇIKLAMASI",
                subtitle: "Ekran görüntüsü veya dosya",
                icon: Icons.description_outlined,
                file: fotoDetay,
                onTap: () => fotoSec(true),
              ),
              const SizedBox(height: 16),
              _buildUploadCard(
                title: "EKSPERTİZ BİLGİSİ",
                subtitle: "Araç fotoğrafları veya rapor",
                icon: Icons.assignment_outlined,
                file: fotoAciklama,
                onTap: () => fotoSec(false),
              ),
              
              const SizedBox(height: 30),
              const Center(child: Text("MANUEL BİLGİ GİRİŞİ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2))),
              const SizedBox(height: 15),

              // ANALYZE BUTTON
              _buildMainButton(),

              const SizedBox(height: 50),
              
              // LAST SCANS SECTION
              const Text("LAST SCANS", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 15),
              _buildLastScans(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("AUTO-SCAN PRO", style: GoogleFonts.rajdhani(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const Icon(Icons.circle, color: Colors.greenAccent, size: 12),
          ],
        ),
        const Text("AI-Powered Vehicle Intelligence", style: TextStyle(color: Colors.grey, fontSize: 13)),
      ],
    );
  }

  Widget _buildUploadCard({required String title, required String subtitle, required IconData icon, File? file, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: file != null ? Colors.cyan.withOpacity(0.5) : Colors.transparent, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF5F5F7), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.black87),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text(file != null ? "Görsel Seçildi" : subtitle, style: TextStyle(color: file != null ? Colors.green : Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (file != null) const Icon(Icons.check_circle, color: Colors.cyan),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton() {
    return Center(
      child: yukleniyor 
        ? const CircularProgressIndicator(color: Colors.cyan)
        : GestureDetector(
            onTap: analizGonder,
            child: Container(
              height: 65,
              width: 240,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00D2D3), Color(0xFF00B2B2)]),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00D2D3).withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 8)),
                ],
              ),
              child: const Center(
                child: Text("TAM ANALİZ BAŞLAT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ),
    );
  }

  Widget _buildLastScans() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _scanItem("BMW M4", "9.2/10 Score"),
          _scanItem("Tesla Model Y", "No Issues"),
          _scanItem("Audi Q7", "Price: High"),
        ],
      ),
    );
  }

  Widget _scanItem(String title, String status) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car, size: 30, color: Colors.black54),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          Text(status, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}