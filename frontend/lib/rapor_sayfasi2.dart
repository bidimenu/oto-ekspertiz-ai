
import 'package:flutter/material.dart';
import 'ekspertiz_sema.dart';

class RaporSayfasi extends StatelessWidget {
  final Map<String, dynamic> veri;

  // Hatalı satırı bu şekilde güncelliyoruz:
  const RaporSayfasi({super.key, required this.veri});

  @override
  Widget build(BuildContext context) {
    final arac = veri['arac_bilgileri'] ?? {};
    final teknik = veri['teknik_ve_kronik_bilgiler'] ?? {};
    final ekspertiz = veri['ekspertiz_durumu'] ?? {};

    return Scaffold(
      appBar: AppBar(
        title: Text("${arac['marka']} ${arac['model']} Analizi"),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TEMEL BİLGİLER VE KASA KODU KARTI
            _buildSectionCard(
              title: "Araç Kimliği",
              icon: Icons.directions_car,
              color: Colors.blue,
              content: Column(
                children: [
                  _infoRow("Kasa Kodu", arac['kasa_kodu'], isHighlight: true),
                  _infoRow("Yıl", arac['yil']),
                  _infoRow("Kilometre", "${arac['kilometre']} KM"),
                  _infoRow("Fiyat", "${arac['fiyat']} TL"),
                ],
              ),
            ),

            // 2. TEKNİK VE KRONİK SORUNLAR (KRİTİK ALAN)
            _buildSectionCard(
              title: "Teknik Analiz & Kronik Sorunlar",
              icon: Icons.engineering,
              color: Colors.orange,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow("Motor Kodu", teknik['motor_kodu']),
                  _infoRow("Şanzıman", teknik['sanziman_tipi']),
                  const Divider(),
                  const Text("⚠️ Kronik Sorunlar:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  ...(teknik['kronik_sorunlar'] as List? ?? []).map((s) => Text("• $s")),
                  const SizedBox(height: 10),
                  const Text("🛠️ Ağır Bakım Tahmini:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(teknik['agir_bakim_tahmini'] ?? "Belirtilmemiş"),
                ],
              ),
            ),

             _buildSectionCard(
                title: "Kaporta ve Ekspertiz Durumu",
                icon: Icons.format_paint,
                color: Colors.redAccent,
                content: EkspertizSema(
                  boyali: ekspertiz['boyali_parcalar'] ?? [],
                  degisen: ekspertiz['degisen_parcalar'] ?? [],
                ),
              ),

            // 3. YAPAY ZEKA MÜHENDİSLİK ANALİZİ
            _buildSectionCard(
              title: "Yapay Zeka Uzman Görüşü",
              icon: Icons.psychology,
              color: Colors.purple,
              content: Text(
                veri['kapsamli_ekspertiz_raporu'] ?? "",
                style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Color color, required Widget content}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
            const Divider(),
            content,
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, dynamic value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value?.toString() ?? "N/A",
            style: TextStyle(fontWeight: FontWeight.bold, color: isHighlight ? Colors.blue : Colors.black),
          ),
        ],
      ),
    );
  }
}