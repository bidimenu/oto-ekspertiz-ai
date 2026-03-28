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
        configuration = PurchasesConfiguration("appl_HGzgwVMZMDOuBdCeywAVCxxFldB");
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

// Dışarıdan paketId alacak şekilde güncelledik
  Future<bool> paketSatinAl(String paketId) async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        
        // 🚀 VİTRİNDEN KULLANICININ SEÇTİĞİ PAKETİ BULUYORUZ
        Package? secilenPaket;
        try {
          secilenPaket = offerings.current!.availablePackages.firstWhere((p) => p.identifier == paketId);
        } catch (e) {
          debugPrint("⚠️ Paketi RevenueCat'te bulamadık: $paketId");
          return false;
        }
        
        // Seçilen paketle Apple ekranını çağır
        PurchaseResult result = await Purchases.purchasePackage(secilenPaket);
        debugPrint("🎉 ÖDEME BAŞARILI! Apple onay verdi.");
        
        return true; 
      } else {
        debugPrint("⚠️ RevenueCat'te aktif vitrin yok!");
        return false;
      }
    } catch (e) {
      debugPrint("❌ Ödeme İptal Edildi veya Hata: $e");
      return false;
    }
  }

// ... diğer kodlar aynı kalacak
}