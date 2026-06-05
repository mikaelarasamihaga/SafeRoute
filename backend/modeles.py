from sqlalchemy import Column, Integer, String, DateTime, Float
from sqlalchemy.orm import declarative_base
from datetime import datetime, timezone

Base = declarative_base()

class Signalement(Base):
    __tablename__ = "signalements"

    id = Column(Integer, primary_key=True, index=True)
    type_danger = Column(String) # ex: 'sombre', 'desert', 'autre'
    description = Column(String, nullable=True)
    date_creation = Column(DateTime, default=lambda: datetime.now(timezone.utc))
    
    # Coordonnées géographiques
    latitude = Column(Float)
    longitude = Column(Float)

class Refuge(Base):
    __tablename__ = "refuges"

    id = Column(Integer, primary_key=True, index=True)
    nom = Column(String)
    type_refuge = Column(String) # ex: 'police', 'pharmacie', 'commerce'
    adresse = Column(String, nullable=True)
    latitude = Column(Float)
    longitude = Column(Float)
