import os
import json
import google.generativeai as genai
from PIL import Image
from dotenv import load_dotenv

# .env dosyasındaki şifreyi güvenli bir şekilde çekiyoruz
load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
#test
def analiz_yap(foto1: Image.Image, foto2: Image.Image):
    # En hızlı ve güncel modelimizi seçiyoruz
    model = genai.GenerativeModel('gemini-2.5-flash')
    
    prompt = """
    Sen 30 yıllık kıdemli bir otomobil mekanik ustası, kıdemli bir otomotiv mühendisi ve veri bilimcisin. 
    Ek'te verilen iki ekran görüntüsü bir ikinci el araç ilanına aittir.

    GÖREV 1: Görsellerdeki verileri (marka, model, yıl, km, hasar durumu) titizlikle ayıkla.
    GÖREV 2: Kendi devasa bilgi bankanı tara. Bu aracın motor kodu (Örn: N47, EA888), şanzıman tipi (Örn: DSG, ZF8, CVT) ve bu kilometredeki potansiyel kondisyonunu analiz et. Sadece teorik değil, sanayideki usta tecrübesiyle yaklaş (Hangi parça kaç binde yorulur, hangi ses neyin habercisidir).
    GÖREV 3: Net bir piyasa analizi yap. Kondisyon/KM/Hasar dengesine göre KESİNLİKLE net bir tahmini satış fiyatı belirle.
    GÖREV 4: Aşağıdaki JSON formatında, hiçbir ek metin olmadan yanıt ver. Bilinmeyen veriler için "Belirtilmemiş" yaz.

 {
  "guven_skoru": "Eldeki verilere dayanarak (km, yaş, kronik sorunlar) KESİNLİKLE '%70 riskli' veya '%85 alınır' formatında bir skor üret.",
  "arac_bilgileri": {
    "marka": "",
    "model": "",
    "kasa_kodu": "Aracın fabrikasyon şase/kasa kodunu yaz (Örn: F30, W205, MK7).",
    "yil": "",
    "yakit_tipi": "",
    "vites": "",
    "kilometre": "",
    "motor_gucu": "",
    "agir_hasarli": "",
    "fiyat": "SADECE rakam yaz."
  },
  "piyasa_analizi": {
    "ikinci_el_likiditesi": "Piyasadaki satış hızını MAKSİMUM 1-2 CÜMLE ile ÇOK KISA VE NET yaz (Örn: 'Hızlı satılır, piyasası canlıdır.' veya 'Niş araçtır, alıcısını bekler.'). Kesinlikle uzun açıklama yapma.",
    "fiyat_degerlendirmesi": "Tahmini piyasa değerini ve fiyat yorumunu MAKSİMUM 1-2 CÜMLE ile NET yaz (Örn: 'Piyasası 11.500.000 TL bandındadır, ilandaki fiyat makul/yüksek.'). Asla paragraf yazma."
  },
  "ekspertiz_durumu": {
    "boyali_parcalar": [],
    "degisen_parcalar": [],
    "hasar_kaydi": ""
  },
  "teknik_ve_kronik_bilgiler": {
    "motor_kodu": "Motorun teknik kodunu belirt (Örn: B47D20).",
    "sanziman_tipi": "Şanzıman modelini belirt (Örn: 7G-Tronic, EDC).",
    "kronik_sorunlar": ["Bu modelde kronik olan 2-3 madde ekle."],
    "agir_bakim_tahmini": "Bu km ve yaşta yapılmış olması gereken ağır bakımları (Triger, Kavrama, Sıvılar) belirt.",
    "obd_ve_mekanik_tavsiyeler": ["Eksperde özellikle bakılması gereken 2 kritik nokta."],
    "yapay_zeka_mekanik_yorumu": "Bu motor-şanzıman ikilisinin karakterini, sanayideki ününü ve bu kilometredeki sürprizlerini bir usta ağzıyla anlat (2-3 cümle)."
  },
  "kapsamli_ekspertiz_raporu": "Kullanıcıya 'Alırsan şunlara hazırlıklı ol' diyen, usta tecrübesi içeren 2-3 paragraflık samimi özet."
}
"""

    try:
        response = model.generate_content(
            [prompt, foto1, foto2],
            generation_config={"response_mime_type": "application/json"}
        )
        return json.loads(response.text)
    except Exception as e:
        return {"hata": f"Yapay zeka analizi sırasında bir sorun oluştu: {str(e)}"}







'''

  {
    "arac_bilgileri": {
      "marka": "", "model": "", "kasa_kodu": "", "yil": "", "yakit_tipi": "", 
      "vites": "", "kilometre": "", "motor_gucu": "", "agir_hasarli": "", "fiyat": "SADECE rakam yaz (Örn: 1.250.000).Yazmıyorsa KESİNLİKLE 'Belirtilmemiş' yaz."
    },
    "ekspertiz_durumu": {
      "boyali_parcalar": [], "degisen_parcalar": [], "hasar_kaydi": ""
    },
    "teknik_ve_kronik_bilgiler": {
      "motor_kodu": "", "sanziman_tipi": "", "kronik_sorunlar": [],
      "fabrika_geri_cagirmalari": [], "agir_bakim_tahmini": "",
      "obd_ve_mekanik_tavsiyeler": [],
      "yapay_zeka_mekanik_yorumu": "Bu motor ve şanzıman ikilisinin uyumu, performansı ve karakteri hakkında çok kısa, net bir uzman yorumu (2-3 cümle)."
    },
    "piyasa_analizi": {
      "ikinci_el_likiditesi": "", 
      "fiyat_degerlendirmesi": "Buraya kesinlikle aracın tahmini piyasa satış fiyatını yaz (Örn: 850.000 TL) ve ilandaki fiyatla kıyasla."
    },
    "guven_skoru":"Aracın genel kondisyonuna göre KESİNLİKLE '%85 alınır' veya '%40 riskli' formatında bir skor ve çok kısa bir gerekçe yaz.",
    "satici_notu_ozeti": "",
    "kapsamli_ekspertiz_raporu": ""
  }'''




'''
    Sen uzman bir oto ekspertiz, kıdemli bir otomotiv mühendisi motor ve mekanik ve elektrik ustasısın. 
    Ek'te verilen iki ekran görüntüsü bir ikinci el araç ilanına aittir (Biri detayları, diğeri değişen boya durumunu içerir).


    GÖREV 1: Görsellerdeki verileri dikkatlice ayıkla.
    GÖREV 2: Aracın marka, model, yıl, paket ve motor gücü bilgilerini kullanarak kendi otomotiv bilgi bankanı tara. Bu spesifik kombinasyonun şase kodunu, motorunu, şanzımanını, kronik sorunlarını ve ağır bakım periyotlarını tespit et.
    GÖREV 3: Elde ettiğin verilerle piyasa analizi yap. Aracın kondisyonuna, hasar geçmişine ve kilometresi gibi etkenlere göre KESİNLİKLE net bir tahmini satış fiyatı belirle (Örn: 850.000 TL). Ayrıca aracın genel durumunu değerlendirerek "%85 alınır" formatında bir güven skoru ver.
    GÖREV 4: Elde ettiğin tüm verileri harmanlayarak BİREBİR aşağıdaki JSON formatında, hiçbir ek metin veya kod bloğu olmadan yanıt ver. Bilinmeyen veya görselde olmayan veriler için "Belirtilmemiş" yaz.
 
  İstenen JSON Yapısı:
{
  "guven_skoru": "VERİ EKSİK OLSA BİLE eldeki verilere dayanarak (km, yaş, kronik sorunlar) KESİNLİKLE '%70 riskli' veya '%85 alınır' formatında bir skor üret. Bu alan ASLA boş kalmamalı.",
  "arac_bilgileri": {
    "marka": "",
    "model": "",
    "kasa_kodu": "",
    "yil": "",
    "yakit_tipi": "",
    "vites": "",
    "kilometre": "",
    "motor_gucu": "",
    "agir_hasarli": "",
    "fiyat": "Ekranda fiyat varsa SADECE rakam yaz (Örn: 1.250.000). Yoksa KESİNLİKLE 'Belirtilmemiş' yaz."
  },
  "piyasa_analizi": {
    "ikinci_el_likiditesi": "",
    "fiyat_degerlendirmesi": "Aracın tahmini piyasa satış fiyatını yaz (Örn: 850.000 TL) ve ilandaki fiyatla kıyasla."
  },
  "ekspertiz_durumu": {
    "boyali_parcalar": [],
    "degisen_parcalar": [],
    "hasar_kaydi": ""
  },
  "teknik_ve_kronik_bilgiler": {
    "motor_kodu": "",
    "sanziman_tipi": "",
    "kronik_sorunlar": [],
    "agir_bakim_tahmini": "",
    "obd_ve_mekanik_tavsiyeler": [],
    "yapay_zeka_mekanik_yorumu": "Bu motor ve şanzıman ikilisinin uyumu, performansı ve karakteri hakkında çok kısa, net bir uzman yorumu (2-3 cümle).."
  },

  "kapsamli_ekspertiz_raporu": "Bu alanı 2-3 paragrafı geçmeyecek şekilde özetle."
}
 '''