from fastapi import FastAPI, File, UploadFile, HTTPException, Form
from typing import Optional
import google.generativeai as genai
from PIL import Image
import io
import json
import os
from datetime import datetime
from dotenv import load_dotenv
import asyncio
# Veritabanı için gerekli kütüphaneler
from sqlalchemy import create_engine, Column, Integer, String, JSON, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from fastapi.middleware.cors import CORSMiddleware


load_dotenv()

# --- VERİTABANI YAPILANDIRMASI ---
# .env dosyanda şu formatta olmalı: DATABASE_URL=postgresql://kullanici:sifre@localhost:5432/oto_ekspertiz_db
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Veritabanı Tablo Modeli
class AracAnaliz(Base):
    __tablename__ = "analizler"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True) # autoincrement açık olmalı
    marka = Column(String)
    model = Column(String)
    yil = Column(String)
    sonuc_json = Column(JSON) 
    olusturulma_tarihi = Column(DateTime, default=datetime.utcnow)

# Tabloları oluştur
Base.metadata.create_all(bind=engine)
# ---------------------------------

app = FastAPI(title="AUTO-SCAN PRO API", version="1.3")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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
        "yapay_zeka_mekanik_yorumu": "Bu 1.8 litrelik ünite, kasanın hafifliğiyle birleşince keyifli bir performans sunar."
    },
    "piyasa_analizi": {
        "ikinci_el_likiditesi": "Düşük",
        "fiyat_degerlendirmesi": "Emsallerine göre makul."
    },
    "satici_notu_ozeti": "Bakımlı, hobi aracı.",
    "kapsamli_ekspertiz_raporu": "Araç genel kondisyon olarak iyi durumda."
}

def build_prompt(user_text: Optional[str] = None):
    base_prompt = """
    Sen uzman bir oto ekspertiz, kıdemli bir otomotiv mühendisi ve veri analizi asistanısın. 
    Ek'te verilen iki ekran görüntüsü bir ikinci el araç ilanına aittir.
    """
    if user_text:
        base_prompt += f"\nNOT: Kullanıcı şu bilgileri iletti: '{user_text}'.\n"

    base_prompt += """
    GÖREV 1: Verileri ayıkla.
    GÖREV 2: Bilgi bankanı tara (kronik sorunlar, şanzıman vb.).
    GÖREV 3: BİREBİR aşağıdaki JSON formatında yanıt ver.
    
    İstenen JSON Yapısı:
    {
      "arac_bilgileri": {"marka": "", "model": "", "kasa_kodu": "", "yil": "", "yakit_tipi": "", "vites": "", "kilometre": "", "motor_gucu": "", "agir_hasarli": "", "fiyat": ""},
      "ekspertiz_durumu": {"boyali_parcalar": [], "degisen_parcalar": [], "hasar_kaydi": ""},
      "teknik_ve_kronik_bilgiler": {"motor_kodu": "", "sanziman_tipi": "", "kronik_sorunlar": [], "fabrika_geri_cagirmalari": [], "agir_bakim_tahmini": "", "obd_ve_mekanik_tavsiyeler": [], "yapay_zeka_mekanik_yorumu": ""},
      "piyasa_analizi": {"ikinci_el_likiditesi": "", "fiyat_degerlendirmesi": ""},
      "satici_notu_ozeti": "",
      "kapsamli_ekspertiz_raporu": ""
    }
    """
    return base_prompt

# ... önceki kodlar ...

@app.post("/analiz")
async def arac_analiz_et(
    foto_detay: Optional[UploadFile] = File(None),
    foto_aciklama: Optional[UploadFile] = File(None),
    manuel_text: Optional[str] = Form(None)
):
    # DİKKAT: Gemini'ye gitmek için bunu False yapmalısın!
    DEBUG_MODE = False 

    final_sonuc = {}

    if DEBUG_MODE:
        await asyncio.sleep(2)
        final_sonuc = MOCK_DATA
        print("🛠️ DEBUG MODU: Mock veri dönülüyor, Gemini'ye gidilmedi.")
    else:

        import google.generativeai as genai # Gerektiğinde import et
        genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
        model = genai.GenerativeModel('gemini-2.0-flash')


        try:
            print("🌟 GEMINI ANALİZİ BAŞLADI...")
            final_prompt = build_prompt(manuel_text)
            icerik_listesi = [final_prompt]
            
            if foto_detay:
                icerik_listesi.append(Image.open(io.BytesIO(await foto_detay.read())))
            if foto_aciklama:
                icerik_listesi.append(Image.open(io.BytesIO(await foto_aciklama.read())))

            # Gemini 2.0 Flash kullanımı
            response = model.generate_content(
                icerik_listesi,
                generation_config={"response_mime_type": "application/json"}
            )
            final_sonuc = json.loads(response.text)
            print("✅ GEMINI YANITI ALINDI.")
        except Exception as e:
            print(f"❌ GEMINI HATASI: {e}")
            raise HTTPException(status_code=500, detail=f"Gemini Hatası: {str(e)}")

    # --- VERİTABANI KAYIT ---
    db = SessionLocal()
    try:
        print("💾 SUPABASE'E KAYIT DENENİYOR...")
        arac = final_sonuc.get("arac_bilgileri", {})
        
        yeni_analiz = AracAnaliz(
            marka=str(arac.get("marka", "Bilinmiyor")),
            model=str(arac.get("model", "Bilinmiyor")),
            yil=str(arac.get("yil", "0")),
            sonuc_json=final_sonuc 
        )
        
        db.add(yeni_analiz)
        db.commit() # Veriyi kalıcı hale getirir
        db.refresh(yeni_analiz)
        print(f"🚀 KAYIT BAŞARILI! ID: {yeni_analiz.id}")
    except Exception as e:
        db.rollback()
        print(f"🚨 DB KAYIT HATASI: {e}")
        # Not: DB hatası olsa bile kullanıcıya analizi dönmek isteyebilirsin
    finally:
        db.close()

    return final_sonuc


@app.get("/gecmis")
async def gecmis_analizleri_getir():
    db = SessionLocal()
    try:
        analizler = db.query(AracAnaliz).order_by(AracAnaliz.olusturulma_tarihi.desc()).limit(5).all()
        
        liste = []
        for a in analizler:
            liste.append({
                "id": a.id,
                "marka": a.marka,
                "model": a.model,
                "yil": a.yil,
                "tarih": a.olusturulma_tarihi.strftime("%d.%m.%Y %H:%M"),
                "sonuc": a.sonuc_json  # <--- Burayı 'detay'dan 'sonuc'a çevirdik
            })
        return liste
    except Exception as e:
        print(f"Geçmiş çekme hatası: {e}")
        return []
    finally:
        db.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)