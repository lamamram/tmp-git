## procédure

```bash
#!/bin/bash

## procédure à exécuter avec précaution !!!!!

## créer et basculer sur une branche orpheline 
# orpheline == sans commit de base
#  à partir commit en paramètre
git checkout --orphan tmp_branch HEAD~1 # ou hash

## créer le commit de base à partir de l'état de la copie de travail  
git add . && git commit -m "root-commit"

## rapatrier les commits le plus récents de la branche à couper
git cherry-pick main~1..main # hash..main

## ICI FAIRE UN BACKUP DE LA BRANCHE A COUPER AU CAS OU
## suppression de la branche à couper
git branch -D main

## renommer la branche orpheline selon la branche qu'on a coupé
git branch -m main

## écraser la branche distante pour synchroniser les historiques
git push -f origin main

## rendre les commits coupés inaccessibles du reflog
git reflog expire --all --expire=now
# ou plus souple
git reflog expire --all --expire=11.minute.ago

## la branche à couper est maintenant supprimée
## mais les commits sont toujours présents dans le dépôt
## SUPPRESSION PHYSIQUE DES COMMITS INACCESSIBLES
git gc --aggressive --prune=all
```


