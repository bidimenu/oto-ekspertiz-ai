import 'main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // 🚀 Eklendi
import 'onboarding_ekrani.dart';
import 'splash_ekrani.dart';

class ProfilEkrani extends StatelessWidget {
  const ProfilEkrani({super.key});

  // 🚀 Sadece bu cihaza ait analizleri getiren fonksiyon
  Future<List<GecmisAnaliz>> _getBenimAnalizlerim() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cihazId = prefs.getString('cihaz_id');

      if (cihazId == null) return [];

      final response = await Supabase.instance.client
          .from('analizler')
          .select()
          .eq('cihaz_id', cihazId) // 🔑 Filtreleme burada yapılıyor
          .order('olusturulma_tarihi', ascending: false);

      final List<dynamic> data = response;
      return data.map((item) => GecmisAnaliz.fromJson(item)).toList();
    } catch (e) {
      debugPrint("Profil verisi hatası: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("PROFİL", style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildUserHeader(),
            const SizedBox(height: 30),

            _buildSectionHeader("SON ANALİZLERİNİZ"),

            // 🚀 STATİK LİSTE YERİNE DİNAMİK FUTUREBUILDER GELDİ
            FutureBuilder<List<GecmisAnaliz>>(
              future: _getBenimAnalizlerim(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(30.0),
                    child: Center(child: CircularProgressIndicator(color: Color(0xFF00D2D3))),
                  );
                }

                final analizler = snapshot.data ?? [];

                if (analizler.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: Text("Henüz bir analiziniz bulunmuyor.", 
                      style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: analizler.length,
                  itemBuilder: (context, index) {
                    final item = analizler[index];
                    return _buildHistoryItem(
                      "${item.marka} ${item.model}",
                      item.tarih, // Modelde formatladığımız tarih
                      "Raporu Gör", // Buraya istersen item içinden bir özet basabilirsin
                      const Color(0xFF00D2D3),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 20),
            _buildSectionHeader("UYGULAMA AYARLARI"),
            _buildActionTile(
              context, 
              icon: Icons.help_outline, 
              title: "Kullanım Rehberini Göster", 
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const OnboardingEkrani()));
              }
            ),
            const Divider(height: 1),
            _buildActionTile(
              context, 
              icon: Icons.delete_forever_outlined, 
              title: "Verilerimi ve Geçmişi Sil", 
              isDestructive: true,
              onTap: () => _verileriSilOnay(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        String displayId = snapshot.data?.getString('cihaz_id') ?? "Yükleniyor...";
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF00D2D3), width: 2),
              ),
              child: const CircleAvatar(
                radius: 45,
                backgroundColor: Color(0xFFF0F9F9),
                child: Icon(Icons.person, size: 45, color: Color(0xFF00D2D3)),
              ),
            ),
            const SizedBox(height: 12),
            Text("PREMIUM KULLANICI", style: GoogleFonts.rajdhani(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("ID: $displayId", style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        );
      }
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFFF8F9FA),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
    );
  }

  Widget _buildHistoryItem(String title, String sub, String status, Color color) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFF0F9F9), borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.directions_car_filled, color: Color(0xFF00D2D3)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 12)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
        child: Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black87),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : Colors.black87, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  void _verileriSilOnay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tüm Veriler Silinsin mi?"),
        content: const Text("Geçmiş analizleriniz ve cihaz verileriniz kalıcı olarak silinecek. Uygulama sıfırlanacaktır."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("İPTAL")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, elevation: 0),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const SplashScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text("SİL VE SIFIRLA", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}