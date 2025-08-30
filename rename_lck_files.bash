#!/bin/bash

# Script pour renommer les fichiers LCK_????.MP4 vers CYQ_????.MP4

# Vérifier si des fichiers correspondent au pattern
if ls LCK_[0-9][0-9][0-9][0-9].MP4 1> /dev/null 2>&1; then
    echo "Fichiers trouvés, début du renommage..."
    
    # Boucle sur tous les fichiers correspondant au pattern
    for fichier in LCK_[0-9][0-9][0-9][0-9].MP4; do
        # Extraire la partie numérique (les 4 chiffres)
        numero=$(echo "$fichier" | sed 's/LCK_\([0-9][0-9][0-9][0-9]\)\.MP4/\1/')
        
        # Créer le nouveau nom
        nouveau_nom="CYQ_${numero}.MP4"
        
        # Renommer le fichier
        mv "$fichier" "$nouveau_nom"
        echo "Renommé: $fichier -> $nouveau_nom"
    done
    
    echo "Renommage terminé !"
else
    echo "Aucun fichier correspondant au pattern LCK_????.MP4 trouvé."
fi
