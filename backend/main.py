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
SQLALCHEMY_DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_engine(SQLALCHEMY_DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

# Veritabanı Tablo Modeli
class AracAnaliz(Base):
    __tablename__ = "analizler"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    cihaz_id = Column(String, nullable=True) # 🚀 BURA EKLENDİ
    marka = Column(String)
    model = Column(String)
    yil = Column(String)
    sonuc_json = Column(JSON) 
    olusturulma_tarihi = Column(DateTime, default=datetime.utcnow)

# Tabloları oluştur
Base.metadata.create_all(bind=engine)
# ---------------------------------

app = FastAPI(title="AUTO-SCAN PRO API", version="1.4")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 🛠️ MOCK VERİ GÜNCELLENDİ (Uzun özet silindi, rozet uyumlu hale geldi)
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
        "yapay_zeka_mekanik_yorumu": "Kronik ABS beyni arızasına dikkat, temizse 1.8 motor kasa hafifliğinden dolayı çok keyif verir."
    },
    "piyasa_analizi": {
        "ikinci_el_likiditesi": "Niş araçtır, yavaş satılır.",
        "fiyat_degerlendirmesi": "FIRSAT - Değerinin 40.000 TL altında, hızlı giden alır."
    },
    "satici_notu_ozeti": "Bakımlı, hobi aracı."
}

def build_prompt(user_text: Optional[str] = None):
    base_prompt = """
    Sen uzman bir oto ekspertiz, kıdemli bir otomotiv mühendisi ve veri analizi asistanısın. 
    Ek'te verilen iki ekran görüntüsü bir ikinci el araç ilanına aittir.
    """
    if user_text:
        base_prompt += f"\nNOT: Kullanıcı şu bilgileri iletti: '{user_text}'.\n"

    # 🚀 LEAD DOKUNUŞU: Masal anlatan prompt yerini "Kesin Kurallar"a bıraktı.
    base_prompt += """
    GÖREV 1: Verileri ayıkla.
    GÖREV 2: Bilgi bankanı tara (kronik sorunlar, şanzıman vb.).
    GÖREV 3: BİREBİR aşağıdaki JSON formatında yanıt ver.
    
    ÖNEMLİ KURALLAR:
    
    - "yapay_zeka_mekanik_yorumu" alanı DOĞRUDAN motor ve şanzıman kondisyonuna odaklanan 2 veya 3 net cümleden oluşmalı. 
      Formülün şu olmalı: [Motorun kronik riski] + [Şanzıman tipi ve arıza maliyeti] + [Usta uyarısı].
      Asla genel geçer sözler söyleme, doğrudan sanayi jargonuyla nokta atışı yap.
      (Örn: "1.4 TSI motorlarda 100 bin km sonrası triger zinciri uzaması ve yağ yakma kroniktir, kompresyon testi şart. Üzerindeki 7 ileri kuru kavrama DSG şanzımanın mekatronik beyni saatli bombadır; kavrama titremesi varsa anında 50 bin TL masraf açar")
    
    - "fiyat_degerlendirmesi" alanı SADECE şu kelimelerden birini içermeli ve maksimum 1 cümle olmalı: "PAHALI", "FIRSAT", "NORMAL". kesinlikle cümle degil kelime")
    - "ikinci_el_likiditesi" alanı maksimum 3-4 kelime veya 1 cümle olmalı. (Örn: "Peynir ekmek gibi satılır" veya "Niş araç, bekletir").
    - Asla uzun paragraf veya hikaye yazma. Kısa ve öz ol.
    - Teknik ve kronik bilgiler için 5-6 madde yaz
    - Motor ve şanzımana ilk olarak yorum yap 1 cümle
    
    İstenen JSON Yapısı:
    {
      "arac_bilgileri": {"marka": "", "model": "", "kasa_kodu": "", "yil": "", "yakit_tipi": "", "vites": "", "kilometre": "", "motor_gucu": "", "agir_hasarli": "", "fiyat": ""},
      "ekspertiz_durumu": {"boyali_parcalar": [], "degisen_parcalar": [], "hasar_kaydi": ""},
      "teknik_ve_kronik_bilgiler": {"motor_kodu": "", "sanziman_tipi": "", "kronik_sorunlar": [], "fabrika_geri_cagirmalari": [], "agir_bakim_tahmini": "", "obd_ve_mekanik_tavsiyeler": [], "yapay_zeka_mekanik_yorumu": ""},
      "piyasa_analizi": {"ikinci_el_likiditesi": "", "fiyat_degerlendirmesi": ""},
      "satici_notu_ozeti": ""
    }
    """
    return base_prompt

# - "yapay_zeka_mekanik_yorumu" alanı 250 KARAKTER ve 3 cümle olmalı. Tokat gibi, net ve vurucu bir sanayi ustası yorumu yaz. (Örn: "Kavrama titremesine dikkat et, temizse 100 bin km üzmez.")
#    - "yapay_zeka_mekanik_yorumu" alanı 3 kısa cümleden oluşmalı. İlk cümle motor/şanzıman uyumunu ve performansı, diğerleri doğrudan arabaya özel usta tavsiye ve yorumu. Çok uzatma ama doyurucu bir sanayi ustası analizi olsun. (Örn: "Bu motor kasayı rahat çeker ama 100 bin km devirdiği için kavrama titremesine dikkat etmelisin. Şanzıman yağı değişmemişse 40 bin TL masraf açabilir, almadan önce mutlaka kontrol ettir.")


@app.post("/analiz")
async def arac_analiz_et(
    foto_detay: Optional[UploadFile] = File(None),
    foto_aciklama: Optional[UploadFile] = File(None),
    manuel_text: Optional[str] = Form(None),
    cihaz_id: Optional[str] = Form(None) # 🚀 BURA EKLENDİ: Flutter'dan gelen ID'yi yakalayacak
):
    # DİKKAT: Gemini'ye gitmek için bunu False yapmalısın!
    DEBUG_MODE = False 

    final_sonuc = {}

    if DEBUG_MODE:
        await asyncio.sleep(2)
        final_sonuc = MOCK_DATA
        print("🛠️ DEBUG MODU: Mock veri dönülüyor, Gemini'ye gidilmedi.")
    else:
        import google.generativeai as genai
        
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise HTTPException(status_code=500, detail="API Key eksik! .env dosyasını kontrol et.")
            
        print(f"Sistem Başlatıldı. Kullanılan API Key (ilk 4): {api_key[:4]}***")
        genai.configure(api_key=api_key)
        
        # Not: Eğer "gemini-2.5-flash" isimli model henüz aktif değilse "gemini-2.0-flash" veya "gemini-1.5-flash" yapabilirsin.
        model = genai.GenerativeModel("gemini-2.5-flash")

        try:
            print("🌟 GEMINI ANALİZİ BAŞLADI...")
            final_prompt = build_prompt(manuel_text)
            icerik_listesi = [final_prompt]
            
            if foto_detay:
                icerik_listesi.append(Image.open(io.BytesIO(await foto_detay.read())))
            if foto_aciklama:
                icerik_listesi.append(Image.open(io.BytesIO(await foto_aciklama.read())))

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
        print("💾 VERİTABANINA KAYIT DENENİYOR...")
        arac = final_sonuc.get("arac_bilgileri", {})
        
        yeni_analiz = AracAnaliz(
            marka=str(arac.get("marka", "Bilinmiyor")),
            model=str(arac.get("model", "Bilinmiyor")),
            yil=str(arac.get("yil", "0")),
            sonuc_json=final_sonuc,
            cihaz_id=cihaz_id # 🚀 BURA EKLENDİ: Yakalanan ID veritabanına yazılıyor
        )
        
        db.add(yeni_analiz)
        db.commit()
        db.refresh(yeni_analiz)
        print(f"🚀 KAYIT BAŞARILI! ID: {yeni_analiz.id}")
    except Exception as e:
        db.rollback()
        print(f"🚨 DB KAYIT HATASI: {e}")
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
                "sonuc": a.sonuc_json 
            })
        return liste
    except Exception as e:
        print(f"Geçmiş çekme hatası: {e}")
        return []
    finally:
        db.close()


@app.post("/verileri-sil")
async def verileri_sil_ve_anonimlestir(cihaz_id: str = Form(...)):
    db = SessionLocal()
    try:
        # 🚀 KRİTİK NOKTA: Veriyi silmiyoruz (delete), sadece cihaz_id'yi siliyoruz (update).
        # Böylece veri anonim olarak senin veritabanında ML eğitimi için kalıyor.
        kayitlar = db.query(AracAnaliz).filter(AracAnaliz.cihaz_id == cihaz_id).all()
        
        if not kayitlar:
            return {"mesaj": "Silinecek veri bulunamadı."}

        for kayit in kayitlar:
            kayit.cihaz_id = "anonim_silinmis" # Orijinal ID'yi eziyoruz
            
        db.commit()
        print(f"✅ {cihaz_id} ID'li kullanıcının verileri anonimleştirildi.")
        return {"mesaj": "Veriler başarıyla anonimleştirildi."}
        
    except Exception as e:
        db.rollback()
        print(f"🚨 DB Silme Hatası: {e}")
        raise HTTPException(status_code=500, detail="İşlem başarısız oldu.")
    finally:
        db.close()

        

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)