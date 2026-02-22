import 'package:flutter/material.dart';

class EkspertizSema extends StatelessWidget {
  final List<dynamic> boyali;
  final List<dynamic> degisen;

  const EkspertizSema({super.key, required this.boyali, required this.degisen});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("🚗 Araç Hasar Panoraması", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...boyali.map((p) => _statusChip(p.toString(), Colors.orange, "Boya")),
            ...degisen.map((p) => _statusChip(p.toString(), Colors.red, "Değişen")),
            if (boyali.isEmpty && degisen.isEmpty) 
              const Text("✅ Hatasız / Boyasız", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _statusChip(String label, Color color, String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text("$label ($type)", style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}