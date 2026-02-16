# fusions de branches

> copier le dossier "branching" en dehors du dépôt local courant

```bash
git init
git add . && git commit -m "root-commit"
git checkout -b feature
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
git add . && git commit -m "ajout script1.txt"
cat <<EOF > script2.txt
function2_1(){
  code3
  return
}
EOF
cat <<EOF >> script1.txt
function1_3(){
  code4
  return
}
EOF
git add . && git commit -m "ajout script2.txt + MAJ sur script1.txt"
git checkout main
echo "new_file" > new_file.txt
git add . && git commit -m "ajout new_file.txt"

```

## cas classique sans conflit

* 2 commits sur une nouvelle `feature`
* 1 commit intermittent sur `main`

### voir les divergeances

```bash
# observer l'historique des 2 branches
# cet affichage n'est PAS SATISFAISANT
# on devrait voir une DIVERGEANCE entre main et feature
# puisque les 2 commits de feature ET le nouveau commit de main
# n'ont pas de relations directes !!!!
git ll --all

# voir les divergeance/convergeances
git ll --all --graph
```

> on préfère de faire un alias
> `git config --global alias.graph 'log --oneline --all --graph'`
> `git graph` remplace ``git log --oneline --all --graph`

---

### fusionner

* consiste à rapatrier les commits de `feature` dans `main`
* en prenant en compte le(s) commit(s) créés sur main après la création de `feature`,
* en créant un **nouveau commit** !!

```bash
# on se met toujours sur la branche de RECEPTION (ici main)
git checkout main
# lancer l'éditeur car nouveau commit => message
git merge feature
# OU avec message par défaut
git merge feature --no-edit
# observer le graphe
git graph
```

> le résultat est un nouveau commit sur main
> dit **commit de fusion**
> qui a 2 parents !! : `git cat-file -p HEAD`

> la stratégie dite `ort` ou `recursive` gère la fusion en cas de **criss cross merge** 
> qui génère plusieurs ancêtres communs entre les 2 branches **ANTIPATTERN NOTOIRE!!!**
> `ort` utilise l'algo histogramme le plus puissant pour détecter les conflits
---

### après la fusion

* La bonne pratique est de supprimer la branche `feature`
* si l'on veut retravailler ce code
* on recréé une nouvelle branche de travail

* `git branch -d feature`

---

## cas classique avec conflit

### setup:

* 2 commits sur une nouvelle `feature2`
* 1 commit intermittent sur `main`

```bash
git checkout -b feature2
cat <<EOF >> script2.txt

function2_2(){
  code5
  return
}
EOF
git add . && git commit -m "MAJ2 sur script2.txt"
cat <<EOF >> script1.txt
function1_4(){
  code6
  return
}
EOF
git add . && git commit -m "MAJ3 sur script1.txt"
git checkout main
cat <<EOF >> script2.txt

function2_3(){
  code7
  return
}
EOF
git add . && git commit -m "MAJ2_BIS sur script2.txt"

```

---

### conflit: raison

```bash
git graph -4

git checkout main
# CONFLIT !!
# oberver la trace du merge
git merge feature2 --no-edit

# oberserver le sufixe du bash (main|MERGING)
# et le statut "Unmerged" ou "UU"
git status
# observer le code de script2.txt
cat script2.txt
```

> le commit "MAJ2 sur script2.txt" de `feature2`
> ET le commit "MAJ2_BIS sur script2.txt" de `main`
> contiennent des **modifications CONTRADICTOIRES**
> sur les mêmes lignes du même fichier
> sachant qu'on a pas de relation directes (parent-enfant) entre les 2
> git n'a pas le droit d'arbitrer les versions != => CONFLIT

---

### conflit: analyse

* on voit les lignes en contradiction

```text
<<<<<<< HEAD
function2_3(){
  code7
=======
function2_2(){
  code5
>>>>>>> feature2
```

> pour terminer la fusion, on va créer le commit de fusion manuellement
> créer un commit == faire des modifs / ajouter les modifs / commiter
> les modifs devraient être décidées par les parties prenantes au conflit !

### conflit: résolution

```bash
# modif décidée: juxtaposer les codes
cat <<EOF > script2.txt
function2_1(){
  code3
  return
}

function2_2(){
  code5
  return
}

function2_3(){
  code7
  return
}
EOF

# "marque" le fichier comme résolution
# enlève le statut "Unmerged"
git add .
git status
# crée le commit de fusion
git commit -m "Merge feature2"

git graph -4
git branch -d feature2
```

> cas particulier: demander soit notre version en cas de conflit : `git merge -X ours feature2`
> soit la version de l'autre branche en cas de conflit : `git merge -X theirs feature2`

---

## cas "Fast-Forward"

### setup

* 2 commits sur une nouvelle branche `feature3`
* pas de commit intermittent dans `main`

```bash
git checkout -b feature3
cat <<EOF >> script2.txt

function2_4(){
  code8
  return
}
EOF
git add . && git commit -m "MAJ3 sur script2.txt"
cat <<EOF >> script1.txt
function1_5(){
  code9
  return
}
EOF
git add . && git commit -m "MAJ4 sur script1.txt"

```

---

### fusion FF

* puisque le graphe est **linéaire** entre `feature3` et `main`
* la fusion, par défaut, va consister à repositionner `main` sur `feature`

> qui donne l'impression d'une "avance rapide"

```bash
git checkout main
# pas de message car pas de nouveau commit !!
git merge feature3
# main et feature au même niveau
git graph -3
```

---

## no-ff

### no-ff: mécanisme manuel

* le **FF** est le comportement de git par défaut
* MAIS pourrait forcer la création d'un commit de fusion dans ce cas

```bash
# on supprime les deux commits fusionnés en ff de main
git reset --hard HEAD~2
# on redemande une fusion MAIS avec commit de fusion
# et un message par défaut
git merge --no-ff --no-edit feature3
git graph -4
```

---

### no-ff: mécanisme par défaut

```bash
# on demande à la configuration git qu'on ait toujours
# des commits de fusion dans tous les cas de figures
git config --global merge.ff false

# on supprime le commit de fusion précédent
git reset --hard HEAD~1

# no-ff auto-include
git merge --no-edit feature3
git graph -4

# FF demandé manuellement
git reset --hard HEAD~1
git merge --ff feature3
git graph -3
```

---

### no-ff: intérêt & inconvénient

* intérêt1: 
  + le commit de fusion et sa divergeance/convergrance liées
  + donne l'information pertinente qu'une branche a été fusionnéé
  + concernant un nombre de commits connus
  + même en cas de suppression de la branche de feature (bonne pratique)

* intérêt2:
  + on peut inverser un commit de fusion avec `revert`
  + qui *désactive proprement* une élément du projet cohérent

* inconvénient:
  + `git pull` réalise une fusion entre une branche de suivi et une branche de travil en local
  + le `no-ff` impacte ces fusion
  + on ajoute deux autres configuration
  + `git config --global pull.ff only`
  + voire  `git config --global pull.rebase true`
  + cf (scenario "remotes")
---

## revert d'un commit de fusion (no-ff)

* `git revert <rev>`: génère un commit 
  + à partir des diffs du commit parent du commit ciblé `<rev>`
  + MAIS un commit de fusion à 2 parents
  + il faut donc ici spécifier le parent qui nous intéresse
* avec l'option `-m <n>`: "main line"
  + on spécifie le numéro de la ligne de convergeance voulue
  + la ligne de branche de réception (main) est **toujours 1**  

```bash
# on reprend une config no-ff sur feature3
git reset --hard HEAD~2
git merge --no-edit feature3

# je vais inverser le commit de fusion
git revert -m 1 --no-edit HEAD
git graph -5
```