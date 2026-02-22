from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from typing import Optional
import google.generativeai as genai
from PIL import Image
import io
import json
import os
from dotenv import load_dotenv

# .env dosyasındaki şifreyi güvenli bir şekilde çekiyoruz
load_dotenv()

app = FastAPI(title="AUTO-SCAN PRO API", version="1.2")

# Gemini API Key yapılandırması
#GOOGLE_API_KEY = "YOUR_GEMINI_API_KEY"
#genai.configure(api_key=GOOGLE_API_KEY)
genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
model = genai.GenerativeModel('gemini-2.5-flash')


DEBUG_MODE = False 

MOCK_DATA = {
    "arac_bilgileri": {
        "marka": "Opel",
        "model": "Tigra 1.8 Sport",
        "kasa_kodu": "S93",
        "yil": "2005",
        "yakit_tipi": "Benzin",
        "vites": "Manuel",
        "kilometre": "175.000",
        "motor_gucu": "125 HP",
        "agir_hasarli": "Hayır",
        "fiyat": "450.000"
    },
    "ekspertiz_durumu": {
        "boyali_parcalar": ["Sağ Ön Çamurluk"],
        "degisen_parcalar": ["Ön Kaput"],
        "hasar_kaydi": "4.500 TL"
    },
    "teknik_ve_kronik_bilgiler": {
        "motor_kodu": "Z18XE",
        "sanziman_tipi": "F17",
        "kronik_sorunlar": ["Hardtop tavan piston sızıntısı", "Ecotec yağ eksiltme", "ABS Beyin arızası"],
        "fabrika_geri_cagirmalari": ["2006 Tavan Kilidi Revizyonu"],
        "agir_bakim_tahmini": "Triger seti ve devirdaim 10.000 km sonra değişmeli.",
        "obd_ve_mekanik_tavsiyeler": ["Tavan mekanizmasını yağlayın", "Yağ seviyesini haftalık kontrol edin"],
        "yapay_zeka_mekanik_yorumu": "Bu 1.8 litrelik ünite, kasanın hafifliğiyle birleşince keyifli bir performans sunar. Ancak yüksek kilometrede yağ bakımları aksatılmamalıdır."
    },
    "piyasa_analizi": {
        "ikinci_el_likiditesi": "Düşük (Koleksiyonluk/Niş)",
        "fiyat_degerlendirmesi": "Emsallerine göre makul."
    },
    "satici_notu_ozeti": "Bakımlı, tavanı sorunsuz çalışan, masrafsız bir hobi aracı.",
    "kapsamli_ekspertiz_raporu": "Araç genel kondisyon olarak iyi durumda. Belirtilen boya ve değişen haricinde şaseler orijinal."
}

def build_prompt(user_text: Optional[str] = None):
    # Senin hazırladığın profesyonel prompt
    base_prompt = """
    Sen uzman bir oto ekspertiz, kıdemli bir otomotiv mühendisi ve veri analizi asistanısın. 
    Ek'te verilen iki ekran görüntüsü bir ikinci el araç ilanına aittir (Biri detayları, diğeri açıklamayı içerir).
    """
    
    if user_text:
        base_prompt += f"\nNOT: Kullanıcı görsellere ek olarak şu bilgileri de iletti: '{user_text}'. Analiz yaparken bu bilgiyi de mutlaka harmanla.\n"

    base_prompt += """
    GÖREV 1: Görsellerdeki ve varsa kullanıcı notundaki verileri dikkatlice ayıkla.
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
        "yapay_zeka_mekanik_yorumu": ""
      },
      "piyasa_analizi": {
        "ikinci_el_likiditesi": "", "fiyat_degerlendirmesi": ""
      },
      "satici_notu_ozeti": "",
      "kapsamli_ekspertiz_raporu": ""
    }
    """
    return base_prompt

@app.post("/analiz")
async def arac_analiz_et(
    foto_detay: Optional[UploadFile] = File(None),
    foto_aciklama: Optional[UploadFile] = File(None),
    manuel_text: Optional[str] = Form(None)
):
    

    # EĞER DEBUG MODU AÇIKSA DİREKT STATİK VERİYİ DÖN
    if DEBUG_MODE:
        import asyncio
        await asyncio.sleep(3) # Uygulamadaki loading ekranını görmek için yapay bekleme
        return MOCK_DATA
    
    
    try:
        # Prompt'u oluştur
        final_prompt = build_prompt(manuel_text)
        icerik_listesi = [final_prompt]
        
        # Fotoğrafları oku ve listeye ekle
        if foto_detay:
            d_bytes = await foto_detay.read()
            icerik_listesi.append(Image.open(io.BytesIO(d_bytes)))
        
        if foto_aciklama:
            a_bytes = await foto_aciklama.read()
            icerik_listesi.append(Image.open(io.BytesIO(a_bytes)))

        # Gemini'ye gönder (generation_config ile JSON çıktısını zorlayalım)
        response = model.generate_content(
            icerik_listesi,
            generation_config={"response_mime_type": "application/json"}
        )
        
        # JSON'u parse et ve dön
        return json.loads(response.text)
        
    except Exception as e:
        print(f"Hata detayı: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)