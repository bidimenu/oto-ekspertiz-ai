import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_ekrani.dart'; // Dosya ismin farklıysa güncelle
import 'splash_ekrani.dart';     // Dosya ismin farklıysa güncelle

class ProfilEkrani extends StatelessWidget {
  const ProfilEkrani({super.key});

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
            
            // 👤 KULLANICI KARTI
            _buildUserHeader(),
            
            const SizedBox(height: 30),

            // 🚗 ANALİZ GEÇMİŞİ (Şu anlık statik, ilerde veritabanına bağlarız)
            _buildSectionHeader("SON ANALİZLERİNİZ"),
            _buildHistoryItem("BMW M3 G80", "12 Nisan 2026", "Hatasız", Colors.green),
            _buildHistoryItem("Nissan Patrol", "10 Nisan 2026", "Ağır Hasarlı", Colors.red),
            _buildHistoryItem("Audi A4", "5 Nisan 2026", "Boyalı", Colors.orange),
            
            const SizedBox(height: 20),

            // ⚙️ AYARLAR VE GÜVENLİK
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

  // Kullanıcı başlık kartı
  Widget _buildUserHeader() {
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
        Text(
          "PREMIUM KULLANICI", 
          style: GoogleFonts.rajdhani(fontSize: 20, fontWeight: FontWeight.bold)
        ),
        Text(
          "Cihaz ID: #AS-77210", 
          style: TextStyle(color: Colors.grey[500], fontSize: 12)
        ),
      ],
    );
  }

  // Bölüm başlıkları
  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: const Color(0xFFF8F9FA),
      child: Text(
        title, 
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1),
      ),
    );
  }

  // Geçmiş listesi öğesi
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

  // Ayar satırı
  Widget _buildActionTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap, bool isDestructive = false}) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.black87),
      title: Text(title, style: TextStyle(color: isDestructive ? Colors.red : Colors.black87, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }

  // Apple'ın zorunlu tuttuğu veri silme onayı
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
              await prefs.clear(); // Tüm hafızayı temizle
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