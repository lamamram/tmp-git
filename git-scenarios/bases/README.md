# créer des commits et contrôler son dépôt local

> copier le dossier "bases" en dehors du dépôt local courant

---

## création du dépôt local dans la copie de travail "bases"

```bash
cd /path/to/bases
git init
ls -al # voir le dossier .git
```
---

## vérifier les configurations importantes pour travailler

### nom de la branche principale

* avec **Git Bash / terminal|éditeur configuré pour git**
  + voir à droite du prompt ou dans un menu

* sinon on va créer un commit transitoirement
```bash
git add . && git commit -m "root-commit"
git branch -v
```

> quel est le nom de la branch : **main** ou **master**
> les outils git récents utilisent **main**

---

### changer de nom de branche principale

```bash
# avant de créer un nouveau dépôt (cf infra)
git config --global init.defaultBranch main
# OU au moment de la création d'un nouveau dépôt
git init --initial-branch=main
# OU après la création mais avant de pousser sur un dépôt distant
git branch -m main
```

---

### métadonnées nécessaires pour créer des commits

```bash
# regarder si ces valeur existent dans la configuration
# fichier au format .ini
# [section]
#   key = value
git config user.name
git config user.email

# tout voir
git config --list
```

### créer l'utilisateur et l'email

```bash
# si vides: on les créé 
# SOIT en local => écrit dans .git/config
# ces valeurs valent pour le dossier "bases"
git config --local user.name <votre-username>
git config --local user.email <votre-email>

# tout voir
git config --local --list
```

---

```bash
# SOIT en global => écrit dans ~/.gitconfig
# ces valeurs valent pour tous les dossier git
# sans configuration locale => subsidiarité
git config --global user.name <votre-username>
git config --global user.email <votre-email>

# tout voir
git config --global --list
```

---

### supprimer une configuration

```bash
git config --local --unset <section>.<key>
git config --global --unset <section>.<key>
```
 
---

### spécifier l'éditeur par défaut

* git peut demander des saisies de données depuis un éditeur
* principalement pour le **message de commit**
* avec *Git-Bash* l'éditeur par défaut est **vim** qui peut être
* considéré commme conte-intuitif par des utilisateurs *windows*

* `git config --global core.editor notepad`

> le fichier exécutable de l'éditeur doit être dans le PATH !!

---

## créer un commit

### ajout d'un nouveau fichier dans la copie de travail

```bash
# copier et coller toutes les lignes depuis cat => EOF dans git-bash
cat <<EOF > script1.txt
function1_1(){
  code1_1
  return
}
EOF

# regarder le statut du fichier script1.txt
git status
# version raccourcie
git status -s
```

> un nouveau fichier commence à l'état **"Untracked"** dans une copie de travail
> Donc "non suivi": le dépôt (.git) ne le connaît pas !!!

---

### ajout de ce fichier dans l'index

* l'**index** ou *zone de préparation* ou *"staging area"*
* est un emplacement intermédiaire entre
  + la copie de travail (dossier bases)
  + et le dépôt (.git)
  + qui permet de choisir et confirmer les fichiers modifiés candidats au commit
  + l'index est stocké dans `.git/index` *non éditable*

```bash
git add script1.txt

# observer le changement de statut de script1.txt
git status
```

---

### confirmer - "commiter" le fichier dans le dépôt

```bash
# GIT demande un message depuis l'éditeur par défaut
git commit
# fermer l'éditeur sans message => ABORT !!!

# avec message
git commit -m "ajout du fichier script1.txt au dépôt"

# observer le statut de script1.txt et surtout son absence de statut !!
git status
```

> avec la commande `git commit`, qui réalise l'**action COMMIT**,
> le fichier, avec tout son contenu, a été copié dans le dépôt `.git`
> en tant qu'**objet COMMIT** == **VERSION**

> les contenus du fichier en copie de travail et dans le dépôt sont identiques
> donc pas de statut

---

### autre fichier + nouvelle modification sur le fichier existant

```bash
# création du nouveau fichier script2.txt
# et mettre à jour script1.txt
cat <<EOF > script2.txt
function2_1(){
  code2_1
  return
}
EOF

cat <<EOF > script1.txt
import script2

function1_1(){
  code1_1
  use code2_1
  return
}
EOF

git status
```

> il y a donc 2 types de modifications de la copie de travail
> **Untracked:** modification sur un fichier inconnu du dépôt
> **Modified:** modification sur un fichier déjà commité au - 1x
> quand vous avez l'habitude de `git status`
> `git config --global alias.st status`
> `git st` remplace `git status`

---

### ajouter plusieurs fichiers à l'index

```bash
git add script1.txt
git add script2.txt
git add README.md

# OU MIEUX
git add script1.txt script2.txt README.md

# TOUTES les modifications dans la copie de travail: 
# il faut une copie suffisamment propre
git add .

git commit -m "ajouts des scripts + README"
```

---

### techniques d'ajouts complexes

* cas de figure réaliste
  + il y a 15 fichiers modifiés (**U** et/ou **M**)
  + mais je ne veux ajouter que 10 fichiers

* solutions efficaces:
  1. avec un outil graphique permettant les sélections multiples *(shift + click)*
  2. ou `git add -i` dans le terminal *(pas parfait)*

---

#### démo git add -i

```bash
# scénario: copier et coller dans git-bash
for index in $(seq 1 15); do
  echo "content_$index" > "demo_$index.txt"
done
for index in $(seq 2 5); do
  git add "demo_$index.txt"
done
git commit -m "ajout 4 fichiers"
for index in $(seq 2 5); do
  echo -e "\nother_$index\n" >> "demo_$index.txt"
done

# observer la copie de travail
git status

# ajouter demo_1 jusqu'à jusqu'à demo_10 avec git add -i
# ?????
git commit -m "ajout 10 démos"
```

> quand vous avez l'habitude de `git commit`
> `git config --global alias.ci commit`
> `git ci` remplace `git commit`

---

### voir l'historique

* `git log`: tous les métadonnées des commits depuis le + récent jusqu'au + ancien
* un commit est identifié par une nombre en héxadécimal de longueur 40
* de nom `hash` ou `revision`
* `hash` car l'id est généré à partir du contenu et des métadonnées de l'objet commit transformés par une *fonction de hachage* , ici **SHA-1**

---

### configurer l'affichage de l'historique

* `git log --oneline`: tous les infos de base des commits
* ajouter un alias pour cette commande
  + `git config --global alias.ll 'log --oneline'`
  + `git ll` remplace `git log --oneline`

* n'afficher que les `n (entier)` premiers +récents: `git ll -n`
* voir les fichiers modifiés de la copie commités: `git ll -n --stat`

> il serait aussi intéressant de consulter l'historique depuis un outil graphique