import google.generativeai as genai
import os

# API Key'ini buraya yapıştır veya Render'daki gibi ENV'den al
API_KEY = "xx" 

genai.configure(api_key=API_KEY)

print("--- KULLANILABİLİR MODELLER LİSTELENİYOR ---")

try:
    for m in genai.list_models():
        if 'generateContent' in m.supported_generation_methods:
            print(f"Model Adı: {m.name}")
            print(f"Versiyon: {m.version}")
            print(f"Açıklama: {m.display_name}")
            print("-" * 30)
except Exception as e:
    print(f"Hata oluştu: {e}")