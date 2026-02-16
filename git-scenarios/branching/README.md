# Manipulation sur les branches en local

> copier le dossier "branching" en dehors du dépôt local courant

```bash
git init
git add . && git commit -m "root-commit"

```

## cycle de vie  d'une branche

### création

```bash
git branch feature

# voir les pointeurs de branches de travail
# on est toujours sur main !!
git branch -v
```

---

### basculement sur une branche

```bash
git checkout feature

# HEAD se déplace sur le pointeur feature
git branch -v
```

---

### suppression d'une branche

```bash
# ERROR: on ne scie pas la branche sur laquelle on est assis !
git branch -d feature

git checkout main
# OK car la branche ne contient aucun commit ,
# déjà utilisé par une autre branche
# donc pas de perte de données
git branch -d feature
```

> quand vous avez l'habitude de `git branch`
> `git config --global alias.br branch`
> `git br` remplace `git branch`

---

### création + basculement

```bash
git checkout -b feature
git branch -v
```

---

## problématiques de basculement

### cas n°1

* une modification de la copie de travail 
* sur un commit commun à plusieurs branches

```bash
cat <<EOF > script1.txt
function1_1(){
  code1
  return
}

function1_2(){
  code2
  return
}
EOF

```

#### cas n°1: problème

```bash
# modif U dans feature
git status

git checkout main

# modif U dans main
git status
```

> cette modif peut APPARTENIR à feature ou main
> mais elle est dédiée à feature et elle est incomplète !!
> on pourrait facielement la committer dans main

---

### cas n°2

* une modification de la copie de travail
* sur un fichier ajouté à un commit
* **exclusif à la branche courante**

```bash
git checkout feature
# commit exclusif à feature
git add . && git commit -m "ajout script1.txt"

# voir l'historique des 2 branches
# main ne connaît pas ce nouveau commit
git ll --all
```

---

#### cas n°2: problème

```bash
# nouvelle modifications au dessus du commit exclusif
cat <<EOF >> script1.txt

function1_3(){
  code3
  return
}
EOF

# ERROR: checkout bloqué
git checkout main
```

---

#### cas n°2: explication

*  `git checkout`: associe 2 effets
  + déplacement de **HEAD**
  + écraser la copie de travail depuis un commit du dépôt

* ICI:
  + si le `checkout` était autorisé 
  + alors `script1.txt` qui n'existe pas sur main
  + doit être supprimé par écrasement 
  + avec sa **modif NON COMMITEE**
  + => PERTE DE DONNEES => ERROR

---

### mêmes résolutions pour les 2 problèmes

1. créer commit pour planquer la modif dans la branche courante
   + `git add . && git commit -m "modif WIP pour basculer"`
2. OU utliser l'utilitaire `git stash` pour remiser les modifications non commitées

```bash
# pour ramasser toutes les modifs aussi les U
git stash -u

# voir une copie de travail PROPRE avant de basculer
git status

# basculer
git checkout main
```

### restaurer les modifs "stashées"

```bash
# voir le stockage des modifs dans le stash
# ATTENTION: structure de pile => les indices ne sont pas fiables
git stash list

# IMPORTANT: de ne pas oublier de revenir sur la branche de départ
git checkout feature

# IMPORTANT: de ne pas oublier de restaurer les modifs dans la bonne branche
git stash pop
```

---

### problèmes du stash

1. la possibilité d'appliquer les modifications d'un stash où on veut
2. deux lots de modifications successives de même branche et commit auront le même nom dans le stash
3. la possibilité d'oublier les modifications *"stashées"*
4. donc l'accumulation/embrouillimini de la pile
5. on peut supprimer tout ou partie des éléments du stash

```bash
# je replanque les modifs sur feature
git stash -u

git checkout main
# créer une modif sur main et je planque
echo "new_file" > new_file.txt
git stash -u

git checkout feature
# encore une modifié dans le stash
echo "new_script" > new_script.txt
git stash -u

git checkout main
git stash list
```

---

### nettoyer

```bash
# restaurer une entrée particulière dans feature
git checkout feature
git stash pop stash@{2}
git add . && git commit "MAJ sur script2.txt"

# supprimer une entrée
git stash drop stash@{1}
# vider le stash
git stash clear
```

---

### auto-stash: shell linux avec bash/git-bash

* cf le script `auto-stash.sh` dans les scenarios

---

### suppression forcée

```bash
git checkout main
# PERTE DE DONNEES autorisée
git branch -D feature
```