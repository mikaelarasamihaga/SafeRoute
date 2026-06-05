from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from modeles import Base

# Utilisation de SQLite pour la simplicité locale
SQLALCHEMY_DATABASE_URL = "sqlite:///./saferoute.db"

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def initialiser_db():
    from modeles import Refuge
    Base.metadata.create_all(bind=engine)
    
    # Ajouter des données de test si vide
    db = SessionLocal()
    if db.query(Refuge).count() == 0:
        test_refuges = [
            Refuge(nom="Commissariat Central", type_refuge="police", latitude=-18.8792, longitude=47.5079, adresse="Tsaralalana"),
            Refuge(nom="Pharmacie de Garde", type_refuge="pharmacie", latitude=-18.8850, longitude=47.5150, adresse="Antanimena"),
            Refuge(nom="Poste de Police", type_refuge="police", latitude=-18.8700, longitude=47.5000, adresse="Anosy"),
            Refuge(nom="Pharmacie 24/7", type_refuge="pharmacie", latitude=-18.8900, longitude=47.5200, adresse="Analakely"),
        ]
        db.add_all(test_refuges)
        db.commit()
    db.close()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
