import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'rapor_sayfasi.dart';
import 'package:flutter/material.dart';
import 'package:desktop_window/desktop_window.dart'; // Yeni ekledik
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Uygulama açıldığında pencere boyutunu bir telefon gibi ayarla
  if (Platform.isWindows) {
    await DesktopWindow.setWindowSize(const Size(400, 800)); // Telefon boyutu
    await DesktopWindow.setMinWindowSize(const Size(350, 700));
  }
  
  runApp(const OtoEkspertizApp());
}

// void main() => runApp(const OtoEkspertizApp());

class OtoEkspertizApp extends StatelessWidget {
  const OtoEkspertizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oto Ekspertiz AI',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
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

  // Galeriden fotoğraf seçme fonksiyonu
  Future fotoSec(bool detayMi) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        detayMi ? fotoDetay = File(pickedFile.path) : fotoAciklama = File(pickedFile.path);
      }
    });
  }

  // Backend'e (Python) gönderme fonksiyonu
Future analizGonder() async {
    if (fotoDetay == null || fotoAciklama == null) return;

    setState(() { yukleniyor = true; });

    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8000/analiz'));
      
      // ANAHTAR KELİMELER: 'foto_detay' ve 'foto_aciklama' Python'daki ile aynı olmalı
      request.files.add(await http.MultipartFile.fromPath('foto_detay', fotoDetay!.path));
      request.files.add(await http.MultipartFile.fromPath('foto_aciklama', fotoAciklama!.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      print("Sunucu Yanıtı: $responseData"); // Debug için terminale basalım

     setState(() {
        sonuc = json.decode(responseData);
        yukleniyor = false;
        
        // SONUÇ GELDİĞİNDE YENİ SAYFAYA GİT:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RaporSayfasi(veri: sonuc!)),
        );
      });
    } catch (e) {
      setState(() { yukleniyor = false; });
      print("Hata oluştu: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Oto Ekspertiz AI")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: () => fotoSec(true), child: const Text("İlan Detay Seç"))),
                const SizedBox(width: 10),
                Expanded(child: ElevatedButton(onPressed: () => fotoSec(false), child: const Text("Açıklama Seç"))),
              ],
            ),
            const SizedBox(height: 20),
            if (yukleniyor) const CircularProgressIndicator(),
            if (!yukleniyor && fotoDetay != null && fotoAciklama != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                onPressed: analizGonder, 
                child: const Text("ANALİZ ET")
              ),
            const SizedBox(height: 20),
            if (sonuc != null)
              Container(
                padding: const EdgeInsets.all(10),
                color: Colors.grey[200],
                child: Text(const JsonEncoder.withIndent('  ').convert(sonuc)),
              )
          ],
        ),
      ),
    );
  }
}