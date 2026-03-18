import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class KrediServisi {
  final supabase = Supabase.instance.client;

  // --- 🔒 CİHAZ KİMLİĞİ (PRIVATE) ---
  Future<String> _getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isIOS) {
        var iosDeviceInfo = await deviceInfo.iosInfo;
        return iosDeviceInfo.identifierForVendor ?? "unknown_ios";
      } else if (Platform.isAndroid) {
        var androidDeviceInfo = await deviceInfo.androidInfo;
        return androidDeviceInfo.id; 
      } else if (Platform.isWindows) {
        var windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.deviceId;
      }
    } catch (e) {
      print("Cihaz ID alma hatası: $e");
    }
    return "unknown_device";
  }

  // --- 📊 BAKİYE SORGULAMA ---
  // Uygulama açılışında veya UI'da bakiye gösterirken kullanılır.
  Future<int> bakiyeGetir() async {
    final cihazId = await _getDeviceId();

    final response = await supabase
        .from('kullanici_kredileri')
        .upsert({'cihaz_id': cihazId}, onConflict: 'cihaz_id')
        .select('kredi_sayisi')
        .single();

    return response['kredi_sayisi'] as int;
  }

  // --- 🚀 KREDİ KULLANMA (ATOMIC RPC) ---
  // Bu metod SQL'deki 'kredi_dusur' fonksiyonunu çağırır.
  // İşlem başarılıysa true, bakiye yetersizse false döner.
  Future<bool> krediKullan() async {
    try {
      final cihazId = await _getDeviceId();

      // Supabase üzerindeki Stored Procedure (RPC) çağrısı
      final bool basarili = await supabase.rpc(
        'kredi_dusur', 
        params: {'p_cihaz_id': cihazId}
      );

      return basarili;
    } catch (e) {
      print("🚨 Kredi harcanırken hata oluştu: $e");
      return false;
    }
  }


  Future<void> krediSatinAlTest(int miktar) async {
    final cihazId = await _getDeviceId();
    final mevcutKredi = await bakiyeGetir();
    
    // Supabase'deki krediyi manuel artırıyoruz
    await supabase
        .from('kullanici_kredileri')
        .update({'kredi_sayisi': mevcutKredi + miktar})
        .eq('cihaz_id', cihazId);
  }
}