import os
import json
import google.generativeai as genai
from PIL import Image
from dotenv import load_dotenv

# .env dosyasındaki şifreyi güvenli bir şekilde çekiyoruz
load_dotenv()
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))

def analiz_yap(foto1: Image.Image, foto2: Image.Image):
    # En hızlı ve güncel modelimizi seçiyoruz
    model = genai.GenerativeModel('gemini-2.5-flash')
    
    prompt = """
    Sen uzman bir oto ekspertiz, kıdemli bir otomotiv mühendisi ve veri analizi asistanısın. 
    Ek'te verilen iki ekran görüntüsü bir ikinci el araç ilanına aittir (Biri detayları, diğeri açıklamayı içerir).
    
    GÖREV 1: Görsellerdeki verileri dikkatlice ayıkla.
    GÖREV 2: Aracın marka, model, yıl, paket ve motor gücü bilgilerini kullanarak kendi otomotiv bilgi bankanı tara. Bu spesifik kombinasyonun şase kodunu, motorunu, şanzımanını, kronik sorunlarını ve ağır bakım periyotlarını tespit et.
    GÖREV 3: Elde ettiğin tüm verileri harmanlayarak BİREBİR aşağıdaki JSON formatında, hiçbir ek metin olmadan yanıt ver. Bilinmeyen veya görselde olmayan veriler için "Belirtilmemiş" yaz. Sayısal verileri rakam olarak dön.
    
    İstenen JSON Yapısı:
    {
      "arac_bilgileri": {
        "marka": "", "model": "", "kasa_kodu": "", "yil": "", "yakit_tipi": "", 
        "vites": "", "kilometre": "", "motor_gucu": "", "agir_hasarli": "", "fiyat": ""
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
        "ikinci_el_likiditesi": "", "fiyat_degerlendirmesi": ""
      },
      "satici_notu_ozeti": "",
      "kapsamli_ekspertiz_raporu": ""
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