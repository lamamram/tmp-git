# déterminer les diffs

> copier le dossier "diffs" en dehors du dépôt local courant
 
```bash
git init && git add . && git commit -m "root-commit"
```
---

## voir les diffs entre 2 fichiers

1. voir une modification élémentaire ou "hunk", avec ses marges internes (padding)

```bash
# copier toutes les lignes jusqu'à EOF
cat <<EOF > content.txt
line1
line2
line3
line4
line5
line6
line7
line8
line9
line10
line11
line12
line13
line14
line15
EOF

# même chose
cat <<EOF > content2.txt
line1
line2
line3
line4
line5_bis
line6
line7
line8
line9
line10
line11
line12
line13
line14
line15
EOF

git diff --no-index content.txt content2.txt
```

2. voir le **nb MAXIMUM de lignes** entre deux modifs individuelles inclus dans un seul hunk :
```bash
cat <<EOF > content2.txt
line1
line2
line3
line4
line5_bis
line6
line7
line8
line9
line10
line11
line12_bis
line13
line14
line15
EOF

```

3. voir le **nb MINIMUM de lignes** entre deux modifs constituant deux hunks :
```bash
cat <<EOF > content2.txt
line1
line2
line3
line4
line5_bis
line6
line7
line8
line9
line10
line11
line12
line13_bis
line14
line15
EOF

```
---

## diffs à un paramètre

* index vs working copie vs dépôt
  + `git diff`: index vs copie (pour les fichiers déjà commités)
  + `git diff --cached`: dépôt vs index
  + `git diff HEAD`: dépôt vs copie (pour les fichiers déjà commités ou ajoutés)

### en ajoutant des fichiers dans l'index

```bash
# position de départ: 2 fichiers à l'état "Untracked"
# RIEN pour les 3 diffs
git add content.txt
git diff          # RIEN
git diff --cached # on voit l'ajout de content.txt
git diff HEAD     # on voit l'ajout de content.txt

git commit -m "ajout de content.txt" # RIEN pour les 3 diffs

echo "line16" >> content.txt
git diff          # on voit l'ajout
git diff --cached # RIEN: index == dépôt
git diff HEAD     # on voit l'ajout

git add content.txt && git commit -m "MAJ content.txt"
# RIEN pour les 3 diffs
```

### en ajoutant une partie des hunks d'un fichier (patch)

```bash
cat <<EOF > content.txt
line1
line2
line3
line4
line5_bis
line6
line7
line8
line9
line10
line11
line12
line13_bis
line14
line15
EOF

git add -p content.txt # choisir y et n
git diff               # on voit le 2ème hunk -> non ajouté
git diff --cached      # on voit le 1er hunk -> ajouté mais non commité
git diff HEAD          # on voit les deux hunks non commités
```

---

## préciser la commande diff pour un fichier particulier

* `git diff [...] ... -- <file>`

---

## diff à 2 paramètres de type git

```bash
## entre 2 commits
git diff hash1 hash2

## entre 2 branches (donc les commits du bout des branches)
git diff branch1 branch2
```
