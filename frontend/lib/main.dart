import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:desktop_window/desktop_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'rapor_sayfasi.dart';

//final String baseApiUrl = "https://oto-ekspertiz-api.onrender.com";
final String baseApiUrl = "https://oto-backend-yeni-354386706606.europe-west3.run.app";

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
        textTheme: GoogleFonts.interTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
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
  final picker = ImagePicker();
  final TextEditingController _manuelGirisController = TextEditingController();

  // --- 🚀 YENİ: PROGRESS BAR DEĞİŞKENLERİ ---
  double ilerlemeYuzdesi = 0.0;
  Timer? _progressTimer;
  int mesajIndex = 0;
  Timer? _mesajTimer;
  
  final List<String> analizMesajlari = [
    "Görüntüler işleniyor...",
    "Ekspertiz detayları ayıklanıyor...",
    "Motor, şanzıman değerlendiriliyor...",
    "Kronik sorunlar analiz ediliyor...",
    "Piyasa verileri karşılaştırılıyor...",
    "Final raporu hazırlanıyor...",
  ];

  // --- 🚀 YENİ: 35 SANİYELİK YÜKLEME MOTORU ---
  void _startLoadingProcess() {
    ilerlemeYuzdesi = 0.0;
    mesajIndex = 0;
    const int hedefSureSaniye = 35; 

    // 1. Mesajları 5 saniyede bir değiştir
    _mesajTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && yukleniyor) {
        setState(() {
          mesajIndex = (mesajIndex + 1) % analizMesajlari.length;
        });
      } else {
        timer.cancel();
      }
    });

    // 2. Progress Bar'ı saniyede 10 kere (100ms) akıcı şekilde doldur
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && yukleniyor) {
        setState(() {
          // 35 saniyede 1.0 (Yani %100) olması için gereken matematik
          double artisMiktari = 0.1 / hedefSureSaniye;
          if (ilerlemeYuzdesi < 0.95) { 
            // Cevap gelene kadar %95'te bekletir, birden bitmesin diye
            ilerlemeYuzdesi += artisMiktari;
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<List<GecmisAnaliz>> getGecmisAnalizler() async {
    try {
      final response = await http.get(Uri.parse('$baseApiUrl/gecmis'));
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((item) => GecmisAnaliz.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint("Geçmiş hatası: $e");
      return [];
    }
  }

  @override
  void dispose() {
    _mesajTimer?.cancel();
    _progressTimer?.cancel(); // Yeni timer temizliği
    _manuelGirisController.dispose();
    super.dispose();
  }

  Future fotoSec(bool detayMi) async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery, 
      maxWidth: 1200,      
      maxHeight: 1200,     
      imageQuality: 65     
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      print("Optimize edilmiş fotoğraf boyutu: ${bytes.length / 1024} KB");

      setState(() {
        if (detayMi) {
          fotoDetay = File(pickedFile.path);
        } else {
          fotoAciklama = File(pickedFile.path);
        }
      });
    }
  }

  Future analizGonder() async {
    if (fotoDetay == null && fotoAciklama == null && _manuelGirisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen fotoğraf yükleyin veya araç bilgilerini yazın.")));
      return;
    }

    setState(() { yukleniyor = true; });
    _startLoadingProcess(); // YENİ FONKSİYONU ÇAĞIRIYORUZ

    try {
      print("--- ANALİZ BAŞLADI ---");
      final String cleanUrl = baseApiUrl.trim();
      final targetUrl = Uri.parse('$cleanUrl/analiz');
      print("Hedef URL: $targetUrl");
      
      var request = http.MultipartRequest('POST', targetUrl);
      
      if (fotoDetay != null) {
        request.files.add(await http.MultipartFile.fromPath('foto_detay', fotoDetay!.path));
      }
      if (fotoAciklama != null) {
        request.files.add(await http.MultipartFile.fromPath('foto_aciklama', fotoAciklama!.path));
      }
      
      request.fields['manuel_text'] = _manuelGirisController.text;

      print("İstek gönderiliyor... (Timeout: 90sn)");
      var streamedResponse = await request.send().timeout(const Duration(seconds: 90));
      
      print("Cevap kodu alındı: ${streamedResponse.statusCode}");
      var responseData = await streamedResponse.stream.bytesToString();
      
      if (streamedResponse.statusCode == 200) {
        
        // --- 🚀 CEVAP GELDİĞİNDE BARI %100 YAP ---
        if (mounted) {
          setState(() { ilerlemeYuzdesi = 1.0; });
        }
        
        final Map<String, dynamic> sonuc = json.decode(responseData);
        print("Analiz Başarılı. Rapor sayfasına geçiliyor...");

        // Ufak bir bekleme ekledik ki kullanıcı %100'ü 1 saniye görsün
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;
        
        await Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => RaporSayfasi(veri: sonuc))
        );

        setState(() {
          fotoDetay = null;
          fotoAciklama = null;
          _manuelGirisController.clear(); 
        });

      } else {
        print("Sunucu Hatası: $responseData");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sunucu hatası: ${streamedResponse.statusCode}")));
      }
    } on TimeoutException catch (e) {
      print("ZAMAN AŞIMI HATASI: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bağlantı zaman aşımına uğradı. Backend çok uzun sürdü.")));
    } catch (e) {
      print("BEKLENMEDİK HATA: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    } finally {
      if (mounted) {
        setState(() { yukleniyor = false; });
        _mesajTimer?.cancel();
        _progressTimer?.cancel(); // Timer'ı kapatmayı unutmuyoruz
      }
      print("--- ANALİZ SÜRECİ BİTTİ ---");
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
              _buildHeader(),
              const SizedBox(height: 35),
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
              const SizedBox(height: 25),
              const Center(child: Text("VEYA MANUEL BİLGİ GİRİŞİ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2))),
              const SizedBox(height: 15),
              _buildManuelInput(),
              const SizedBox(height: 25),
              _buildMainButton(),
              const SizedBox(height: 45),
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

  Widget _buildManuelInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: TextField(
        controller: _manuelGirisController,
        maxLines: 4,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: "Örn: Opel Tigra 2005 cabrio 175 bin km...",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
          contentPadding: const EdgeInsets.all(20),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // --- 🚀 YENİ TASARLANMIŞ BUTON VE PROGRESS BAR ALANI ---
  Widget _buildMainButton() {
    return Center(
      child: yukleniyor 
        ? Column(
            children: [
              Container(
                width: 280,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: ilerlemeYuzdesi,
                        minHeight: 10, // Barı biraz kalınlaştırdık
                        backgroundColor: Colors.cyan.withOpacity(0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ilerlemeYuzdesi == 1.0 ? Colors.green : Colors.cyan
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ilerlemeYuzdesi == 1.0 ? "%100 TAMAMLANDI!" : "%${(ilerlemeYuzdesi * 100).toInt()}",
                      style: TextStyle(
                        fontSize: 14, 
                        fontWeight: FontWeight.bold, 
                        color: ilerlemeYuzdesi == 1.0 ? Colors.green : Colors.cyan
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  ilerlemeYuzdesi == 1.0 ? "Rapor oluşturuluyor..." : analizMesajlari[mesajIndex],
                  key: ValueKey<String>(ilerlemeYuzdesi == 1.0 ? "rapor" : analizMesajlari[mesajIndex]),
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.cyan[800]),
                ),
              ),
            ],
          )
        : GestureDetector(
            onTap: analizGonder,
            child: Container(
              height: 65,
              width: 240,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00D2D3), Color(0xFF00B2B2)]),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [BoxShadow(color: const Color(0xFF00D2D3).withOpacity(0.4), blurRadius: 25, offset: const Offset(0, 8))],
              ),
              child: const Center(
                child: Text("TAM ANALİZ BAŞLAT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ),
    );
  }

  Widget _buildLastScans() {
    return FutureBuilder<List<GecmisAnaliz>>(
      future: getGecmisAnalizler(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 110, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("Henüz bir analiz yapmadınız.", style: TextStyle(color: Colors.grey, fontSize: 12));
        }

        final veriler = snapshot.data!;
        return SizedBox(
          height: 125,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: veriler.length,
            itemBuilder: (context, index) {
              final analiz = veriler[index];
              return _scanItem(
                "${analiz.marka} ${analiz.model}", 
                analiz.tarih, 
                analiz.detay
              );
            },
          ),
        );
      },
    );
  }

  Widget _scanItem(String title, String status, Map<String, dynamic> detay) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => RaporSayfasi(veri: detay))),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.history, size: 24, color: Colors.cyan),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(status, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class GecmisAnaliz {
  final int id;
  final String marka;
  final String model;
  final String yil;
  final String tarih;
  final Map<String, dynamic> detay;

  GecmisAnaliz({required this.id, required this.marka, required this.model, required this.yil, required this.tarih, required this.detay});

  factory GecmisAnaliz.fromJson(Map<String, dynamic> json) {
    return GecmisAnaliz(
      id: json['id'],
      marka: json['marka'],
      model: json['model'],
      yil: json['yil'],
      tarih: json['tarih'],
      detay: json['sonuc'],
    );
  }
}