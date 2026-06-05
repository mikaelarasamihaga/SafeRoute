from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Tuple
from moteur_itineraire import MoteurItineraire
from sqlalchemy.orm import Session
from fastapi import Depends
import base_de_donnees as db_config
import modeles

app = FastAPI(
    title="SafeRoute API",
    description="Backend pour l'application de navigation sécurisée SafeRoute",
    version="0.1.0"
)

# Initialisation de la base de données (si possible)
try:
    db_config.initialiser_db()
except Exception as e:
    print(f"Avertissement : Connexion DB échouée : {e}")


# Initialisation du moteur d'itinéraire (Antananarivo par défaut)
moteur = MoteurItineraire()

class RequeteItineraire(BaseModel):
    depart: Tuple[float, float] # (lat, lon)
    arrivee: Tuple[float, float] # (lat, lon)

class RequeteSignalement(BaseModel):
    type_danger: str
    latitude: float
    longitude: float
    description: str = None

# Configuration CORS pour Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def accueil():
    return {"message": "Bienvenue sur l'API SafeRoute", "statut": "en cours d'exécution"}

@app.get("/sante")
async def verification_sante():
    return {"statut": "sain"}

@app.get("/recherche")
async def rechercher(q: str):
    """Proxy pour la recherche d'adresse utilisant la bibliothèque standard (sans httpx)."""
    import urllib.request
    import json
    try:
        url = f"https://nominatim.openstreetmap.org/search?q={urllib.parse.quote(q)}&format=json&limit=5&addressdetails=1"
        headers = {'User-Agent': 'SafeRoute-App-L3'}
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as response:
            return json.loads(response.read().decode())
    except Exception as e:
        return {"erreur": str(e)}

@app.post("/itineraire")
async def obtenir_itineraire(requete: RequeteItineraire):
    try:
        itineraire = moteur.calculer_itineraire_sur(requete.depart, requete.arrivee)
        if not itineraire:
            raise HTTPException(status_code=404, detail="Aucun itinéraire trouvé")
        return {"itineraire": itineraire}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/signalement")
async def creer_signalement(requete: RequeteSignalement, db: Session = Depends(db_config.get_db)):
    nouveau_signalement = modeles.Signalement(
        type_danger=requete.type_danger,
        latitude=requete.latitude,
        longitude=requete.longitude,
        description=requete.description
    )
    db.add(nouveau_signalement)
    db.commit()
    db.refresh(nouveau_signalement)
    return {"message": "Signalement enregistré", "id": nouveau_signalement.id}

@app.get("/signalements")
async def lister_signalements(db: Session = Depends(db_config.get_db)):
    return db.query(modeles.Signalement).all()

@app.get("/refuges")
async def lister_refuges(db: Session = Depends(db_config.get_db)):
    return db.query(modeles.Refuge).all()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
