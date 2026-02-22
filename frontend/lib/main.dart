import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:desktop_window/desktop_window.dart'; 
import 'rapor_sayfasi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows) {
    await DesktopWindow.setWindowSize(const Size(400, 800));
    await DesktopWindow.setMinWindowSize(const Size(350, 700));
  }
  
  runApp(const OtoEkspertizApp());
}

class OtoEkspertizApp extends StatelessWidget {
  const OtoEkspertizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oto Ekspertiz AI',
      debugShowCheckedModeBanner: false, // Debug bandını kapattık
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
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
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        if (detayMi) {
          fotoDetay = File(pickedFile.path);
        } else {
          fotoAciklama = File(pickedFile.path);
        }
      }
    });
  }

  Future analizGonder() async {
    if (fotoDetay == null || fotoAciklama == null) return;

    setState(() { yukleniyor = true; });

    try {
      // Backend adresini kontrol et (localhost bazen sorun çıkarabilir, gerekirse 127.0.0.1 kullan)
      var request = http.MultipartRequest('POST', Uri.parse('http://127.0.0.1:8000/analiz'));
      
      request.files.add(await http.MultipartFile.fromPath('foto_detay', fotoDetay!.path));
      request.files.add(await http.MultipartFile.fromPath('foto_aciklama', fotoAciklama!.path));

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        setState(() {
          sonuc = json.decode(responseData);
          yukleniyor = false;
          
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RaporSayfasi(veri: sonuc!)),
          );
        });
      } else {
        throw Exception("Sunucu Hatası: ${response.statusCode}");
      }
    } catch (e) {
      setState(() { yukleniyor = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Oto Ekspertiz AI"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ElevatedButton(onPressed: () => fotoSec(true), child: const Text("İlan Detay Seç")),
                      if (fotoDetay != null) const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    children: [
                      ElevatedButton(onPressed: () => fotoSec(false), child: const Text("Açıklama Seç")),
                      if (fotoAciklama != null) const Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if (yukleniyor) 
              const CircularProgressIndicator()
            else if (fotoDetay != null && fotoAciklama != null)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: analizGonder, 
                  child: const Text("ANALİZ ET", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}