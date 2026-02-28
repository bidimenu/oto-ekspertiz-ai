import google.generativeai as genai

# API Key'ini buraya yapıştır
API_KEY = "xx" 

genai.configure(api_key=API_KEY)

def test_gemini_25():
    try:
        print("--- GEMINI 2.5 FLASH TESTİ BAŞLADI ---")
        
        # Listendeki tam isimle modeli çağırıyoruz
        model = genai.GenerativeModel("gemini-2.5-flash")
        
        prompt = """
        Bir Lead Data Scientist için test mesajı: 
        Aşağıdaki araç bilgisini analiz et ve JSON formatında marka ve model döndür:
        '2022 model gri bir Toyota Corolla, 45 bin km'de, boyasız.'
        """
        
        response = model.generate_content(prompt)
        
        print("\n[SUNUCU CEVABI]:")
        print(response.text)
        print("\n--- TEST BAŞARILI! ---")
        
    except Exception as e:
        print(f"\n[HATA]: Test sırasında bir sorun oluştu: {e}")

if __name__ == "__main__":
    test_gemini_25()