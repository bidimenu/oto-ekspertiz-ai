import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:desktop_window/desktop_window.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 🚀 EKLENDİ
import 'rapor_sayfasi.dart';
import 'package:frontend/serviceses/kredi_servisi.dart'; // 🚀 EKLENDİ
import 'splash_ekrani2.dart'; // 🚀 Splash ekranını ana dosyaya tanıttık
import 'odeme_servisi.dart'; // 🚀 Ödeme servisini buraya import ettik

//const String baseApiUrl = "https://oto-backend-yeni-354386706606.europe-west3.run.app";

const bool isDebugMode = false; 

String get baseApiUrl {
  if (!isDebugMode) {
    // ☁️ CANLI (PRODUCTION) SUNUCU (Cloud Run)
    return "https://oto-backend-yeni-354386706606.europe-west3.run.app";
  }
  
  // 💻 LOCALHOST (DEBUG) SUNUCU - Windows için
  return "http://127.0.0.1:8000"; 
}

void main() async {
  // 1. Flutter motorunun ve binding'lerin hazır olduğundan emin oluyoruz
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // 🚀 ENV'Yİ BAŞLAT
  // 2. 🚀 SUPABASE BAŞLATMA
  await Supabase.initialize(
    url: 'https://xwiodyndbewwmpsvrtql.supabase.co', 
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh3aW9keW5kYmV3d21wc3ZydHFsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE3ODY2ODYsImV4cCI6MjA4NzM2MjY4Nn0.x9FdxhKHydLyunfXYdT-xZuhNzGWhrzrpA4Xr6lOMRs',
  );

  // 3. 🚀 REVENUECAT (ÖDEME) BAŞLATMA
  // Uygulama açılmadan önce finansal altyapıyı hazır hale getiriyoruz
  await OdemeServisi().initialize();

  // 4. MASAÜSTÜ PENCERE AYARLARI (Windows testi için)
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
      // 🚀 Uygulama artık profesyonel bir Splash Screen ile açılıyor
      home: const SplashScreen(),
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
  
  bool yukleniyor = false;
  final picker = ImagePicker();
  final TextEditingController _manuelGirisController = TextEditingController();
  final KrediServisi _krediServisi = KrediServisi(); // 🚀 SERVİS BAĞLANDI

  double ilerlemeYuzdesi = 0.0;
  Timer? _progressTimer;
  int mesajIndex = 0;
  Timer? _mesajTimer;
  int mevcutKredi = 0; // 🚀 UI'da gösterilecek güncel bakiye
  
  late Future<List<GecmisAnaliz>> _gecmisVerisi;
  
  final List<String> analizMesajlari = [
    "Görüntüler işleniyor...",
    "Ekspertiz detayları ayıklanıyor...",
    "Motor, şanzıman değerlendiriliyor...",
    "Kronik sorunlar analiz ediliyor...",
    "Piyasa verileri karşılaştırılıyor...",
    "Final raporu hazırlanıyor...",
  ];

  @override
  void initState() {
    super.initState();
    _gecmisVerisi = getGecmisAnalizler(); 
    _krediGuncelle(); // 🚀 UYGULAMA AÇILDIĞINDA KREDİYİ ÇEK
  }

  // 🚀 KREDİYİ SUPABASE'DEN ÇEKİP UI'I GÜNCELLEYEN FONKSİYON
  Future<void> _krediGuncelle() async {
    final bakiye = await _krediServisi.bakiyeGetir();
    if (mounted) {
      setState(() {
        mevcutKredi = bakiye;
      });
    }
  }

  // 🚀 KREDİ BİTTİĞİNDE ÇIKACAK ÖDEME (PAYWALL) EKRANI
  void _krediSatinAlModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView( 
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30), 
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const Icon(Icons.bolt, size: 45, color: Colors.cyan), 
              const SizedBox(height: 12),
              const Text("KREDİ YÜKLE", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), 
              const SizedBox(height: 8),
              const Text(
                "Yapay zeka analizine devam etmek için paket seçin.", 
                textAlign: TextAlign.center, 
                style: TextStyle(color: Colors.grey, fontSize: 13), 
              ),
              const SizedBox(height: 25),
              
              // 🚀 1 KREDİ BUTONU AKTİF EDİLDİ 🚀
              _paketButonu("1 ANALİZ HAKKI", "99 TL", () async {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Apple'a bağlanılıyor...")));
                
                // 1_kredi parametresi gönderiliyor
                bool odemeBasarili = await OdemeServisi().paketSatinAl("\$rc_six_month");
                
                if (odemeBasarili) {
                  await _krediServisi.krediEkle(1); // 1 Kredi yaz
                  await _krediGuncelle();
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ 1 Kredi başarıyla yüklendi!")));
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Ödeme işlemi iptal edildi.")));
                  }
                }
              }),
              
              const SizedBox(height: 12),
              
              // 🚀 3 KREDİ BUTONU GÜNCELLENDİ 🚀
              _paketButonu("3 ANALİZ (POPÜLER)", "199 TL", () async {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Apple'a bağlanılıyor...")));
                
                // 3_kredi parametresi gönderiliyor
                bool odemeBasarili = await OdemeServisi().paketSatinAl("\$rc_lifetime");
                
                if (odemeBasarili) {
                  await _krediServisi.krediEkle(3); // 3 Kredi yaz
                  await _krediGuncelle();
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("✅ 3 Kredi başarıyla yüklendi!")));
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("⚠️ Ödeme işlemi iptal edildi.")));
                  }
                }
              }, highlight: true),
              
              const SizedBox(height: 10), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _paketButonu(String baslik, String fiyat, VoidCallback onTap, {bool highlight = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), 
        decoration: BoxDecoration(
          color: highlight ? Colors.cyan : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.cyan, width: 2),
          boxShadow: highlight ? [BoxShadow(color: Colors.cyan.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              baslik, 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: highlight ? Colors.white : Colors.cyan) 
            ),
            Text(
              fiyat, 
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: highlight ? Colors.white : Colors.cyan) 
            ),
          ],
        ),
      ),
    );
  }

  void _startLoadingProcess() {
    ilerlemeYuzdesi = 0.0;
    mesajIndex = 0;
    const int hedefSureSaniye = 35; 

    _mesajTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted && yukleniyor) {
        setState(() {
          mesajIndex = (mesajIndex + 1) % analizMesajlari.length;
        });
      } else {
        timer.cancel();
      }
    });

    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && yukleniyor) {
        setState(() {
          double artisMiktari = 0.1 / hedefSureSaniye;
          if (ilerlemeYuzdesi < 0.95) { 
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
    _progressTimer?.cancel(); 
    _manuelGirisController.dispose();
    super.dispose();
  }

  Future fotoSec() async {
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
        fotoDetay = File(pickedFile.path); 
      });
    }
  }

  Future analizGonder() async {
    if (fotoDetay == null && _manuelGirisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen fotoğraf yükleyin veya araç bilgilerini yazın.")));
      return;
    }

    // 🚀 ANALİZ ÖNCESİ KREDİ KİLİDİ
    bool krediHarcanabilir = await _krediServisi.krediKullan();
    if (!krediHarcanabilir) {
      _krediSatinAlModal(); // Bakiye yoksa Paywall aç
      return;
    }

    // Kredi başarılı harcandı, arayüzdeki sayıyı güncelle ve sürece başla
    _krediGuncelle();
    setState(() { yukleniyor = true; });
    _startLoadingProcess(); 

    try {
      print("--- ANALİZ BAŞLADI ---");
      final String cleanUrl = baseApiUrl.trim();
      final targetUrl = Uri.parse('$cleanUrl/analiz');
      
      var request = http.MultipartRequest('POST', targetUrl);
      
      if (fotoDetay != null) {
        request.files.add(await http.MultipartFile.fromPath('foto_detay', fotoDetay!.path));
      }
      
      request.fields['manuel_text'] = _manuelGirisController.text;

      var streamedResponse = await request.send().timeout(const Duration(seconds: 90));
      var responseData = await streamedResponse.stream.bytesToString();
      
      if (streamedResponse.statusCode == 200) {
        if (mounted) {
          setState(() { ilerlemeYuzdesi = 1.0; });
        }
        
        final Map<String, dynamic> sonuc = json.decode(responseData);
        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;
        
        await Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => RaporSayfasi(veri: sonuc))
        );

        setState(() {
          fotoDetay = null;
          _manuelGirisController.clear(); 
          _gecmisVerisi = getGecmisAnalizler(); 
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sunucu hatası: ${streamedResponse.statusCode}")));
      }
    } on TimeoutException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Bağlantı zaman aşımına uğradı. Backend çok uzun sürdü.")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    } finally {
      if (mounted) {
        setState(() { yukleniyor = false; });
        _mesajTimer?.cancel();
        _progressTimer?.cancel(); 
      }
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildCreditBanner(),
              const SizedBox(height: 25),
              _buildUploadCard(
                title: "Araç Bilgisi Yükle",
                subtitle: "İlan veya ekran görüntüsü",
                icon: Icons.auto_awesome,
                file: fotoDetay,
                onTap: () => fotoSec(),
              ),
              const SizedBox(height: 20),
              _buildManuelInput(),
              const SizedBox(height: 30),
              _buildMainButton(),
              const SizedBox(height: 40),
              const Text("SON ANALİZLER",
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildLastScans(),
            ],
          ),
        ),
      ),
    ),
  );
}
Widget _buildHeader() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AI AUTO SCAN",
            style: GoogleFonts.orbitron(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Akıllı ekspertiz sistemi",
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.greenAccent.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Row(
          children: [
            Icon(Icons.circle, color: Colors.greenAccent, size: 10),
            SizedBox(width: 6),
            Text("AI AKTİF",
                style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
          ],
        ),
      )
    ],
  );
}

Widget _buildCreditBanner() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        colors: [Color(0xFF00F5A0), Color(0xFF00D9F5)],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.cyan.withOpacity(0.4),
          blurRadius: 20,
        )
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "$mevcutKredi Kredi",
          style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        GestureDetector(
          onTap: _krediSatinAlModal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text("YÜKLE",
                style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        )
      ],
    ),
  );
}

Widget _buildUploadCard({
  required String title,
  required String subtitle,
  required IconData icon,
  File? file,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.cyanAccent, size: 28),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                Text(
                  file != null ? "Görsel seçildi" : subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          if (file != null)
            const Icon(Icons.check_circle, color: Colors.greenAccent)
        ],
      ),
    ),
  );
}

Widget _buildManuelInput() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(20),
    ),
    child: TextField(
      controller: _manuelGirisController,
      maxLines: 4,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        hintText: "Araç bilgilerini yaz...",
        hintStyle: TextStyle(color: Colors.white38),
        border: InputBorder.none,
        contentPadding: EdgeInsets.all(16),
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
              const SizedBox(height: 10),
              Text(
                analizMesajlari[mesajIndex],
                style: const TextStyle(color: Colors.white70),
              )
            ],
          )
        : GestureDetector(
            onTap: analizGonder,
            child: Container(
              height: 70,
              width: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F5A0), Color(0xFF00D9F5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: const Center(
                child: Text(
                  "AI ANALİZ BAŞLAT",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
              ),
            ),
          ),
  );
}

  Widget _buildLastScans() {
    return FutureBuilder<List<GecmisAnaliz>>(
      future: _gecmisVerisi, 
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