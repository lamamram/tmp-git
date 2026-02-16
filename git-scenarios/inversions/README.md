# commandes d'inversions

> copier le dossier "inversions" en dehors du dépôt local courant

```bash
# copier et coller toutes les lignes de bash dans git-bash
git init
cat <<EOF > script1.txt
function1_1(){
  code1_1
  return
}
EOF
git add . && git commit -m "root-commit"
cat <<EOF > script2.txt
function2_1(){
  code2_1
  return
}
EOF
git add . && git commit -m "ajout script2.txt"

```

## supprimer les modifications de la copie de travail

### supprimer des modifs non corrigeables

* modifications *incompréhensibles et/ou défaillantes*
* qu'on ne peut plus corriger en revenant à l'**état stable précédent** !!
* plus de `ctrl+Z` !!

```bash
cat <<EOF > script1.txt
function1_1(){
  weird
  code1
  weird
  return
}
weird

weird_function(){
  weird
}
EOF

```

---

```bash
cat <<EOF > script2.txt

fuegergenction2_1(){
  code2_1
  retergerurn
}
EOF

```
---

### checkout "en mode fichier"

```bash
# observer les diffs
git diff HEAD
# enlever les modifications indûes
git checkout -- script*.txt
```

> la copie de travail revient à l'état du commit courant **HEAD**
> checkout écrase la copie de travail à partir d'un commit du dépôt
> `--` signifie qu'on ne fait cet écrasement qu'avec certains fichiers spécifiés à droite

---

### Effet du checkout sur un fichier mis à l'index

```bash
cat <<EOF > script2.txt

fuegergenction2_1(){
  code2_1
  retergerurn
}
EOF

```

> l'écrasement ne fonctionne pas sur un fichier mis à l'index !

```bash
git add script2.txt
git checkout -- script2.txt

# il faut désindéxer le fichier avant d'écraser
git reset -- script2.txt
git checkout -- script2.txt
```


---

### mécanisme sous-jacent

* `--` en linux, désactive le comportements spéciaux des commandes
* ex: les options des commandes

```bash
# je créé un fichier qui s'appelle "-i"
echo "awesome code" > -i
# je veux créer ce fichier: ERROR car "-i" est une option de "rm"
rm -i
# SOLUCE
rm -- -i
```

> avec git `--` signifie qu'à droite on a que des fichiers !!!
> en particulier **pas de nom de branche**

---

### restaurer des modifs commitées et indûment

```bash
cat <<EOF > script1.txt
function1_1(){
  return
}
EOF

git checkout -- script1.txt
```

> quand vous avez l'habitude de `git checkout`
> `git config --global alias.co checkout`
> `git co` remplace `git checkout`

---

## désindéxer

```bash
cat <<EOF > script2.txt
function2_1(){
  maj code2_1
  return
}
EOF

git add script2.txt
## inversion de l'ajout
git reset -- script2.txt
git status
```

---

### vider l'index

```bash
git add .
git reset -- .
git add . && git commit -m "MAJ fonction 2_1 dans script2.txt"
```

---

## suppressions dans le dépôt

### un fichier inutile ou déprécié et déjà commité

```bash
cat <<EOF > wrong_script.txt
deprecated_function(){
  deprecated_code
  return
}
EOF
git add . && git commit -m "ajout wrong_script.txt"

```

---

### suppression physique + ordre de suppression

```bash
# le fichier disparait de la copie de travail
git rm wrong_script.txt

# observer le statut: ordre de suppression dans l'INDEX
# pas besoin de add
git status

# confirmer la suppression dans le dépôt
git commit -m "suppression wrong_script.txt"
```

---

### suppression dans le dépôt: abus de langage

```bash
# voir les fichiers que le commit courant connait
# ON NE LE VERRA PLUS DANS LE COMMIT ET LES PROCHAINS 
git ls-tree -r $(git cat-file -p HEAD | grep -Po "tree \K.*")

# voir les fichiers que le commit précédent connait
# avant le git rm
# MAIS IL EST TOUJOURS LA
git ls-tree -r $(git cat-file -p HEAD~1 | grep -Po "tree \K.*")
```

---

### inverser un git rm

* si le fichier supprimé est dans le commit précédent
* je peux renvoyer ce fichier **depuis ce commit dans la copie de travail**

```bash
# attention le fichier est dans la copie et ajouté à l'index
git checkout HEAD~1 -- wrong_script.txt

# au cas où
git reset -- wrong_script.txt
```

---

### supprimer dans le dépôt mais laisser intact en copie de travail

* usage: un fichier commité MAIS qui aurait dû être ignoré !!!
* pour des *configs. non lié au projet* (éditeur)
* pour les **artifacts**, tout fichier/dossier généré lors
  + compilation
  + exécution
  + tests

```bash
mkdir .vscode
cat <<EOF > .vscode/settings.json
{
  "tabSize": 4
}
EOF
cat <<EOF >> script1.txt

function1_2(){
  code1_2
  return
}
EOF

git add . && git commit -m "commit utile au projet mais ajoutant des configs inutiles"
```

---

### seulement suppression au dépôt

```bash
# -r: pour un dossier
# --cached: laisser intacte la copie de travail
git rm -r --cached .vscode
# ajout du .vscode dans le .gitignore
echo ".vscode/" > .gitignore
git add .gitignore && commit -m "suppression de .vscode"
```

---

### renommer/déplacer un fichier dans la copie ET dans le dépôt

* même mécasnisme qu'avec `git rm`
* `git mv` renomme/déplace dans la copie de travail et ajoute un ordre de renommage/déplacement dans l'iINDEX

```bash
cat <<EOF > bad_name_script.txt
valid_function(){
  valid_code
  return
}
EOF
git add . && git commit -m "rehabilitation de bad_name_script.txt"

# renommage
git mv bad_name_script.txt good_name_script.txt

# observer le statut particulier
git status
git commit -m "renommage du bad_name_script en good_name_script"
```