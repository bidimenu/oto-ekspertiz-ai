import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class OdemeServisi {
  // Singleton yapısı: Uygulama boyunca tek bir servis çalışsın
  static final OdemeServisi _instance = OdemeServisi._internal();
  factory OdemeServisi() => _instance;
  OdemeServisi._internal();

  // 1. BAŞLATMA (Uygulama açılırken main.dart'tan çağrılır)
  Future<void> initialize() async {
    try {
      // Terminalde ne olup bittiğini görmek hayat kurtarır
      await Purchases.setLogLevel(LogLevel.debug);

      PurchasesConfiguration? configuration;

      if (Platform.isIOS) {
        // 🔑 Senin RevenueCat iOS API Anahtarın
        configuration = PurchasesConfiguration("test_xtMQPkAEMyZoCMSOawFJOTozaHZ");
      }

      if (configuration != null) {
        await Purchases.configure(configuration);
        debugPrint("✅ RevenueCat iOS Üzerinde Başarıyla Başlatıldı!");
      }
    } catch (e) {
      debugPrint("❌ RevenueCat Başlatma Hatası: $e");
    }
  }

  // 2. SATIN ALMA İŞLEMİ (Kullanıcı butona basınca FaceID açar)
// ... diğer kodlar aynı kalacak

  Future<bool> paketSatinAl() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        
        // 🚀 İŞTE DEĞİŞEN SATIR: Artık PurchaseResult dönüyor
        PurchaseResult result = await Purchases.purchasePackage(offerings.current!.availablePackages.first);
        
        debugPrint("🎉 ÖDEME BAŞARILI! Apple onay verdi.");
        
        // Artık CustomerInfo'ya bu result'ın içinden ulaşabilirsin (İleride gerekirse)
        // CustomerInfo customerInfo = result.customerInfo;
        
        return true; 
      } else {
        debugPrint("⚠️ RevenueCat'te satılacak paket bulunamadı!");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Ödeme İptal Edildi veya Hata: $e");
      return false;
    }
  }

// ... diğer kodlar aynı kalacak
}