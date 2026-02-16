#!/bin/bash

## procédure à exécuter avec précaution !!!!!

NEW_ROOT_COMMIT=$1
BRANCH_TO_CUT=$2

## créer et basculer sur une branche orpheline 
# orpheline == sans commit de base
#  à partir commit en paramètre
git checkout --orphan tmp_branch $NEW_ROOT_COMMIT

## créer le commit de base à partir de l'état de la copie de travail  
git add . && git commit -m "root-commit"

## rapatrier les commits le plus récents de la branche à couper
git merge --ff $2

## ICI FAIRE UN BACKUP DE LA BRANCHE A COUPER AU CAS OU
## suppression de la branche à couper
git branch -D $2

## renommer la branche orpheline selon la branche qu'on a coupé
git branch -m $2

## écraser la branche distante pour synchroniser les historiques
git push -f origin $2

## la branche à couper est maintenant supprimée
## mais les commits sont toujours présents dans le dépôt
## SUPPRESSION PHYSIQUE DES COMMITS
git gc --aggressive --prune=all

## mettre à jour le reflog
git reflog expire --all --expire=now

## THAT'S FOLKS !!!
