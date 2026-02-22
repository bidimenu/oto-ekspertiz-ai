from sqlalchemy import create_all, Column, Integer, String, JSON, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import datetime

# .env dosyasından çekmek en güvenlisi
DATABASE_URL = "postgresql://user:password@localhost/oto_ekspertiz_db"

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()

class AracAnaliz(Base):
    __tablename__ = "analizler"

    id = Column(Integer, primary_key=True, index=True)
    marka = Column(String)
    model = Column(String)
    plaka = Column(String, nullable=True)
    sonuc_json = Column(JSON) # Gemini'den gelen tüm JSON buraya
    tarih = Column(DateTime, default=datetime.datetime.utcnow)

Base.metadata.create_all(bind=engine)