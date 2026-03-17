import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:desktop_window/desktop_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'rapor_sayfasi.dart';
//test
//final String baseApiUrl = "https://oto-ekspertiz-api.onrender.com";

final String baseApiUrl = "https://oto-backend-354386706606.europe-west3.run.app";

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

  void _startLoadingMessages() {
    mesajIndex = 0;
    _mesajTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted && yukleniyor) {
        setState(() {
          mesajIndex = (mesajIndex + 1) % analizMesajlari.length;
        });
      } else {
        timer.cancel();
      }
    });
  }

  // --- YENİ: VERİTABANINDAN GEÇMİŞİ ÇEKEN FONKSİYON ---
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
    _manuelGirisController.dispose();
    super.dispose();
  }

Future fotoSec(bool detayMi) async {
  // maxWidth ve maxHeight ekleyerek çözünürlüğü "makul" bir seviyeye çekiyoruz.
  // Gemini'nin OCR yapması için 1024-1200px genişlik fazlasıyla yeterli.
  final pickedFile = await picker.pickImage(
    source: ImageSource.gallery, 
    maxWidth: 1200,      // Çözünürlüğü optimize et
    maxHeight: 1200,     // Çözünürlüğü optimize et
    imageQuality: 65     // Kaliteyi %65'e çekmek boyutu ciddi oranda düşürür, okunabilirliği bozmaz
  );

  if (pickedFile != null) {
    // Seçilen dosyanın boyutunu merak edersen debug console'dan bakabilirsin
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
  _startLoadingMessages();

  try {
    print("--- ANALİZ BAŞLADI ---");
    final targetUrl = Uri.parse('$baseApiUrl/analiz');
    
    var request = http.MultipartRequest('POST', targetUrl);
    
    if (fotoDetay != null) {
      request.files.add(await http.MultipartFile.fromPath('foto_detay', fotoDetay!.path));
    }
    if (fotoAciklama != null) {
      request.files.add(await http.MultipartFile.fromPath('foto_aciklama', fotoAciklama!.path));
    }
    
    request.fields['manuel_text'] = _manuelGirisController.text;

    print("İstek gönderiliyor (Bekleyiniz)...");
    var streamedResponse = await request.send().timeout(const Duration(seconds: 60));
    
    var responseData = await streamedResponse.stream.bytesToString();
    
    if (streamedResponse.statusCode == 200) {
      final Map<String, dynamic> sonuc = json.decode(responseData);
      if (!mounted) return;
      
      print("Sayfaya yönlendiriliyor...");

      // --- KRİTİK DEĞİŞİKLİK: AWAIT KULLANIMI ---
      // Navigator.push önüne 'await' ekledik. 
      // Kod burada durur, kullanıcı rapor sayfasından geri gelene kadar aşağı geçmez.
      await Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => RaporSayfasi(veri: sonuc))
      );

      // --- KULLANICI GERİ GELDİĞİNDE TEMİZLİK ---
      // Rapor sayfası kapandığında (pop) burası çalışır. 
      // Artık veriler güvenle temizlenebilir ve ana ekran listesi yenilenir.
      setState(() {
        fotoDetay = null;
        fotoAciklama = null;
        _manuelGirisController.clear(); 
      });

    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sunucu hatası: ${streamedResponse.statusCode}")));
    }
  } on TimeoutException catch (_) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bağlantı zaman aşımına uğradı.")));
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
  } finally {
    if (mounted) {
      setState(() { yukleniyor = false; });
      _mesajTimer?.cancel();
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
              _buildLastScans(), // ARTIK DİNAMİK!
            ],
          ),
        ),
      ),
    );
  }

  // --- UI BİLEŞENLERİ (TASARIM AYNI KALDI) ---

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

  Widget _buildMainButton() {
    return Center(
      child: yukleniyor 
        ? Column(
            children: [
              const CircularProgressIndicator(color: Colors.cyan),
              const SizedBox(height: 15),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  analizMesajlari[mesajIndex],
                  key: ValueKey<String>(analizMesajlari[mesajIndex]),
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.cyan[700]),
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

  // --- DİNAMİK LAST SCANS LİSTESİ ---
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

// --- DATA MODEL ---
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