import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // 🚀 .ENV EKLENDİ

class OdemeServisi {
  static final OdemeServisi _instance = OdemeServisi._internal();
  factory OdemeServisi() => _instance;
  OdemeServisi._internal();

  Future<void> initialize() async {
    try {
      await Purchases.setLogLevel(LogLevel.debug);

      String apiKey = "";
      if (Platform.isIOS) {
        // 🔑 Güvenli anahtar okuma
        apiKey = dotenv.env['REVENUECAT_API_KEY'] ?? ""; 
      }

      if (apiKey.isNotEmpty) {
        await Purchases.configure(PurchasesConfiguration(apiKey));
        debugPrint("✅ RevenueCat iOS Üzerinde GÜVENLİ Başlatıldı!");
      } else {
        debugPrint("⚠️ Uyarı: .env dosyasından anahtar okunamadı!");
      }
    } catch (e) {
      debugPrint("❌ RevenueCat Başlatma Hatası: $e");
    }
  }

  Future<bool> paketSatinAl(String paketId) async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        Package? secilenPaket;
        try {
          secilenPaket = offerings.current!.availablePackages.firstWhere((p) => p.identifier == paketId);
        } catch (e) {
          debugPrint("⚠️ Paketi bulamadık: $paketId");
          return false;
        }
        
        PurchaseResult result = await Purchases.purchasePackage(secilenPaket);
        debugPrint("🎉 ÖDEME BAŞARILI! Apple onay verdi.");
        return true; 
      }
      return false;
    } catch (e) {
      debugPrint("❌ Ödeme İptal Edildi veya Hata: $e");
      return false;
    }
  }

  // 🍏 APPLE APP REVIEW İÇİN ZORUNLU METOD
  Future<void> satinAlmalariGeriYukle() async {
    try {
      await Purchases.restorePurchases();
      debugPrint("🔄 Satın almalar geri yüklendi.");
    } catch (e) {
      debugPrint("❌ Geri yükleme hatası: $e");
    }
  }
}