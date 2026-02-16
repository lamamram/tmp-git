# réécritures d'historiques

> copier le dossier "rewritings" en dehors du dépôt local courant

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
  bad_code
  return
}
EOF
git add . && git commit -m "mauvais msg"

git ll
```

---

## commit --amend

* réécrire le message sur le commit courant: 
  + `git commit --amend -m "ajout script2.txt + MAJ sur script1.txt"`

* réécrire le contenu sur le commit courant:

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

function1_3(){
  good_code
  return
}
EOF
git add . && git commit --amend --no-edit

git diff HEAD~1 HEAD
```

* on aurait pu faire les 2: modif + add + `git commit --amend -m "good message"`

---

## rebase

* configuration de la fusion classique ou conflit MAIS la branche de fonctionnalité n'est pas prête !
* on veut savoir comment les nouveaux commits de main vont intéragir avec notre code

### cas sans conflit

```bash
git checkout main
echo "new_file" > new_file.txt
git add . && git commit -m "ajout new_file.txt"
git graph

# le rebase se fait sur la branche qui se déplace
git checkout feature
git rebase main

# observer le graph linéaire !
# observer le nouveau commit de base "root-commit" => "ajout new_file.txt"
git graph
```

---

### cas avec conflit

* z commits sur feature 2 + 1 commit de main avec modification alternative

```bash
git checkout main
git merge --ff feature
git branch -d feature

git checkout -b feature2
cat <<EOF > script1.txt
function1_1(){
  code1
  return
}

function1_2_bis(){
  new code2
  return
}

function1_3(){
  good_code
  return
}
EOF
git add . && git commit -m "MAJ 1_2 script1.txt"

cat <<EOF >> script2.txt

function2_2(){
  code2_2
  return
}
EOF
git add . && git commit -m "ADD 2_2 script2.txt"

git checkout main
cat <<EOF > script1.txt
function1_1(){
  code1
  return
}

function1_2_ter(){
  alt code2
  yield
}

function1_3(){
  good_code
  return
}
EOF
git add . && git commit -m "MAJ ALT 1_2 script1.txt"
```

#### conflit

```bash
git checkout feature2
git rebase main

# oberserver le compteur dans le terminal (|REBASE 1/2)
# le conflit concerne le 1er commit déplacé

#résolution possible
cat <<EOF > script1.txt
function1_1(){
  code1
  return
}

function1_2_mode_yield(){
  alt code2
  yield
}

function1_2_mode_return(){
  new code2
  return
}

function1_3(){
  good_code
  return
}
EOF

# ajouter les fichiers résolus dans l'index
git add script1.txt
git rebase --continue
# éditer le message du 1er nouveau commit de feature2 "MAJ 1_2_mode_return + 1_2_mode_yield script1.txt"
git graph

git checkout main
git merge --ff feature2
git branch -d feature2
git graph
```

---

## git rebase -i

* retravailler les commits d'une branche **feature3**
* USAGE: dans une branche de fonctionnalité avant la revue de code dans la MR
* 5 commits contenant un code presque bon mais mal présenté

```bash
git checkout -b feature3

## REWORD: commit mal nommé
cat <<EOF > script2.txt
function2_1(){
  code3
  return
}

function2_2(){
  code2_2bis
  return
}
EOF
git add . && git commit -m "BEURK"

## SQUASH: série de commit de corrections
cat <<EOF > script2.txt
function2_1(){
  bad_code1
  return
}

function2_2(){
  code2_2bis
  return
}
EOF
git add . && git commit -m "bad code 1"

cat <<EOF > script2.txt
function2_1(){
  bad_code2
  return
}

function2_2(){
  code2_2bis
  return
}
EOF
git add . && git commit -m "bad code 2"

cat <<EOF > script2.txt
function2_1(){
  good_code
  return
}

function2_2(){
  code2_2bis
  return
}
EOF
git add . && git commit -m "good code"

## EDIT: oubli dans le code
cat <<EOF > script2.txt
function2_1(){
  good_code
  return
}

function2_2(){
  code2_2bis
  return
}

???
EOF
git add . && git commit -m "ADD function 2_3 script2.txt"

git graph -5
```

### procédure

* sur **feature3**

```bash
git rebase -i HEAD~5

## contenu de l'éditeur
## pick: ne rien faire => pas de rebase
# pick 05bcf78 BEURK
# pick 58bee24 bad code 1
# pick c456a81 bad code 2
# pick dadba57 good code
# pick 4d8bf70 ADD function 2_3 script2.txt

## programme voulu "reword" 1 commit + "squash" 3 commit + "edit" le dernier
## le deuxième est le "pivot" du squash !
# r 05bcf78 BEURK
# pick 58bee24 bad code 1
# s c456a81 bad code 2
# s dadba57 good code
# e 4d8bf70 ADD function 2_3 script2.txt

## mode e: le rebase bloque il faut éditer le commit
# édition possible
cat <<EOF > script2.txt
function2_1(){
  good_code
  return
}

function2_2(){
  code2_2bis
  return
}

function2_3(){
  code2_3
  return
}
EOF

git add script2.txt
## en mode --amend => sur le commit lui même
git commit --amend --no-edit
## on termine le rebase
git rebase --continue

## il ne reste que 3 commits bien nommés et bien codés !!!
git graph -5

## DANS LE CADRE ET SEULEMENT DANS LE CADRE DE LA BRANCHE DE FEATURE
git push -f
```



---
