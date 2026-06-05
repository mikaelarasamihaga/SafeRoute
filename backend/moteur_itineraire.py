import osmnx as ox
import networkx as nx
import pandas as pd

class MoteurItineraire:
    def __init__(self, nom_lieu="Madagascar"):
        self.nom_lieu = nom_lieu
        self.graphe = None
        self.last_centre = (0, 0)

    def _charger_graphe_pour_point(self, centre):
        """Charge dynamiquement une zone de 4km autour d'un point donné."""
        # On vérifie si on a déjà chargé une zone proche (pour éviter de retélécharger)
        if self.graphe is not None:
            # Si le nouveau point est à moins de 2km de l'ancien centre, on garde le graphe actuel
            # (Simple approximation pour la performance)
            dist_approx = abs(self.last_centre[0] - centre[0]) + abs(self.last_centre[1] - centre[1])
            if dist_approx < 0.02: 
                return

        print(f"Chargement dynamique du graphe pour la zone {centre}...")
        try:
            self.graphe = ox.graph_from_point(centre, dist=4000, network_type='walk')
            self.graphe = ox.add_edge_speeds(self.graphe)
            self.graphe = ox.add_edge_travel_times(self.graphe)
            self.last_centre = centre
            print(f"Graphe chargé avec succès ({len(self.graphe.nodes)} nœuds).")
        except Exception as e:
            print(f"Erreur chargement dynamique : {e}")

    def calculer_itineraire_sur(self, coords_depart, coords_arrivee):
        print(f"Calcul d'itinéraires : {coords_depart} -> {coords_arrivee}")
        
        # On charge la zone autour du point de départ si besoin
        self._charger_graphe_pour_point(coords_depart)

        if self.graphe is None:
            print("Erreur : Impossible de charger le graphe pour cette zone.")
            return None

        try:
            try:
                noeud_depart = ox.distance.nearest_nodes(self.graphe, coords_depart[1], coords_depart[0])
                noeud_arrivee = ox.distance.nearest_nodes(self.graphe, coords_arrivee[1], coords_arrivee[0])
            except Exception as e:
                print(f"Échec de nearest_nodes (OSMnx), utilisation du fallback manuel : {e}")
                # Fallback ultra-rapide avec NumPy si scikit-learn n'est pas là
                def _trouver_noeud_proche(pt):
                    import numpy as np
                    nodes = self.graphe.nodes(data=True)
                    node_ids = np.array([n for n, d in nodes])
                    coords = np.array([[d['y'], d['x']] for n, d in nodes])
                    
                    # Calcul vectorisé de la distance au carré
                    dist_sq = np.sum((coords - np.array([pt[0], pt[1]]))**2, axis=1)
                    return node_ids[np.argmin(dist_sq)]
                
                noeud_depart = _trouver_noeud_proche(coords_depart)
                noeud_arrivee = _trouver_noeud_proche(coords_arrivee)
            
            # Préparer les poids de sécurité
            for u, v, k, donnees in self.graphe.edges(data=True, keys=True):
                longueur = donnees.get('length', 1)
                eclaire = donnees.get('lit', 'no')
                multiplicateur_securite = 1.0 if eclaire == 'yes' else 1.8 # On augmente un peu la pénalité pour les zones sombres
                donnees['poids_securite'] = longueur * multiplicateur_securite

            # 1. Calcul de l'itinéraire rapide (poids = length)
            chemin_rapide = nx.shortest_path(self.graphe, noeud_depart, noeud_arrivee, weight='length')
            # 2. Calcul de l'itinéraire sécurisé (poids = poids_securite)
            chemin_securise = nx.shortest_path(self.graphe, noeud_depart, noeud_arrivee, weight='poids_securite')

            def extraire_details(itineraire):
                coords_itineraire = []
                instructions = []
                distance_totale = 0
                for i in range(len(itineraire) - 1):
                    u, v = itineraire[i], itineraire[i+1]
                    donnees_arete = self.graphe.get_edge_data(u, v)[0]
                    nom_rue = donnees_arete.get('name', 'Rue sans nom')
                    distance = donnees_arete.get('length', 0)
                    distance_totale += distance
                    donnees_noeud = self.graphe.nodes[u]
                    coords_itineraire.append([donnees_noeud['y'], donnees_noeud['x']])
                    if not instructions or instructions[-1]['rue'] != nom_rue:
                        instructions.append({'rue': nom_rue, 'distance': round(distance)})
                    else:
                        instructions[-1]['distance'] += round(distance)
                dernier_noeud = self.graphe.nodes[itineraire[-1]]
                coords_itineraire.append([dernier_noeud['y'], dernier_noeud['x']])
                return {
                    "points": coords_itineraire,
                    "instructions": instructions,
                    "distance_totale": round(distance_totale)
                }

            return {
                "rapide": extraire_details(chemin_rapide),
                "securise": extraire_details(chemin_securise)
            }
        except Exception as e:
            print(f"Erreur calcul itinéraires : {e}")
            return None

# Test
if __name__ == "__main__":
    moteur = MoteurItineraire()
    itineraire = moteur.calculer_itineraire_sur((-18.8792, 47.5079), (-18.8850, 47.5150))
    print(f"Itinéraire trouvé avec {len(itineraire)} points.")
