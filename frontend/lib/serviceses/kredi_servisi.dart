import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class KrediServisi {
  final supabase = Supabase.instance.client;

  Future<String> _getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isIOS) {
        var iosDeviceInfo = await deviceInfo.iosInfo;
        return iosDeviceInfo.identifierForVendor ?? "unknown_ios";
      } else if (Platform.isAndroid) {
        var androidDeviceInfo = await deviceInfo.androidInfo;
        return androidDeviceInfo.id; 
      }
    } catch (e) {
      print("Cihaz ID alma hatası: $e");
    }
    return "unknown_device";
  }

  Future<int> bakiyeGetir() async {
    final cihazId = await _getDeviceId();
    final response = await supabase
        .from('kullanici_kredileri')
        .upsert({'cihaz_id': cihazId}, onConflict: 'cihaz_id')
        .select('kredi_sayisi')
        .single();
    return response['kredi_sayisi'] as int;
  }

  Future<bool> krediKullan() async {
    try {
      final cihazId = await _getDeviceId();
      final bool basarili = await supabase.rpc('kredi_dusur', params: {'p_cihaz_id': cihazId});
      return basarili;
    } catch (e) {
      return false;
    }
  }

  // 🚀 İŞTE GERİ GETİRDİĞİMİZ GÜVENLİ FONKSİYON
  Future<void> krediEkle(int miktar) async {
    try {
      final cihazId = await _getDeviceId();
      await supabase.rpc('kredi_artir', params: {'p_cihaz_id': cihazId, 'p_miktar': miktar});
      print("✅ Kredi başarıyla eklendi: +$miktar");
    } catch (e) {
      print("🚨 Kredi eklenirken hata: $e");
    }
  }
}