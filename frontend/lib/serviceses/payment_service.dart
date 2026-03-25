import 'dart:io';
import 'package:purchases_flutter/purchases_flutter.dart';

class PaymentService {
  static Future<void> init() async {
    // Geliştirme aşamasında logları görmek hayat kurtarır
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;

    if (Platform.isIOS) {
      // 🔑 Senin az önce kopyaladığın anahtar
      configuration = PurchasesConfiguration("test_xtMQPkAEMyZoCMSOawFJOTozaHZ");
      await Purchases.configure(configuration);
      print("✅ RevenueCat iOS Yapılandırması Tamamlandı!");
    }
  }
}