import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'serviceses/kredi_servisi.dart'; // Senin Supabase kredi servisin

class OdemeServisi {
  // 🚀 RevenueCat API Key (Panelden aldığın apple_ veya goog_ ile başlayanları buraya koy)
  static const _appleApiKey = "appl_KDaYPxeWVGHRKoYSlHcFApsEhht"; 
  static const _googleApiKey = "goog_KDaYPxeWVGHRKoYSlHcFApsEhht";

  final KrediServisi _krediServisi = KrediServisi();

  // 1. BAŞLATMA: Uygulama açılırken bir kez çağrılır
 Future<void> initialize() async {
    // 🚀 LEAD DOKUNUŞU: Sadece iOS veya Android ise başlat
    if (!Platform.isIOS && !Platform.isAndroid) {
      print("⚠️ Ödeme servisi bu platformda (Windows/Web vb.) desteklenmiyor. Atlanıyor...");
      return; 
    }

    await Purchases.setLogLevel(LogLevel.debug);

    String apiKey = Platform.isIOS ? _appleApiKey : _googleApiKey;
    
    try {
      await Purchases.configure(PurchasesConfiguration(apiKey));
      print("✅ RevenueCat Yapılandırıldı.");
    } catch (e) {
      print("❌ RevenueCat Yapılandırma Hatası: $e");
    }
  }

  // 2. PAKETLERİ ÇEKME: Apple Store'daki fiyatları canlı getirir
  Future<List<StoreProduct>> mevcutPaketleriGetir() async {
    try {
      Offerings offerings = await Purchases.getOfferings();
      if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
        // RevenueCat panelinde oluşturduğun "Offering" içindeki paketleri döner
        return offerings.current!.availablePackages.map((p) => p.storeProduct).toList();
      }
    } catch (e) {
      print("❌ Paket Çekme Hatası: $e");
    }
    return [];
  }

  // 3. SATIN ALMA: Gerçek Apple Pay / Google Pay ekranını açar
  Future<bool> satinAl(StoreProduct product, int krediMiktari) async {
    try {
      // 💳 Ödeme ekranını tetikler
      CustomerInfo customerInfo = await Purchases.purchaseStoreProduct(product);
      
      // ✅ Ödeme başarılıysa Supabase'deki krediyi artır
      print("🎉 Ödeme Başarılı! Kullanıcı: ${customerInfo.originalAppUserId}");
      
      // Kredi miktarını veritabanına işle
      await _krediServisi.krediSatinAlTest(krediMiktari);
      
      return true;
    } catch (e) {
      print("❌ Satın Alma İptal veya Hata: $e");
      return false;
    }
  }
}