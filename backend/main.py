from fastapi import FastAPI, File, UploadFile, HTTPException
from ai_engine import analiz_yap
from PIL import Image
import io
#semih was here

# API'mizi ayağa kaldırıyoruz
app = FastAPI(title="Profesyonel Oto AI API", version="1.0")

@app.get("/")
def read_root():
    return {"mesaj": "Oto Ekspertiz AI Sunucusu Aktif! Analiz için /analiz endpointine POST isteği atın."}

@app.post("/analiz")
async def arac_analiz_et(
    foto_detay: UploadFile = File(...),
    foto_aciklama: UploadFile = File(...)
):
    try:
        # 1. Mobil uygulamadan gelen fotoğrafları bilgisayarın hafızasına (RAM) oku
        detay_bytes = await foto_detay.read()
        aciklama_bytes = await foto_aciklama.read()
        
        # 2. Byte (veri) halindeki fotoğrafları PIL (Python Image) formatına çevir
        img_detay = Image.open(io.BytesIO(detay_bytes))
        img_aciklama = Image.open(io.BytesIO(aciklama_bytes))
        
        # 3. AI Motoruna gönder ve sonucu bekle
        sonuc = analiz_yap(img_detay, img_aciklama)
        
        # Eğer yapay zeka tarafında bir hata olduysa bunu uygulamaya bildir
        if "hata" in sonuc:
            raise HTTPException(status_code=500, detail=sonuc["hata"])
            
        return sonuc
        
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Görseller işlenirken hata oluştu: {str(e)}")