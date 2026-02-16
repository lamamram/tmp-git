# gestion des commits

## setup

> copier le dossier "commits-mgnt" en dehors du dépôt local courant

```bash
git init
git add . && git commit -m "root-commit"

```

## voir le contenu de l'objet commit

```bash
# commit le + récent dans tout le dépôt
last_commit=$(git rev-list --all -1)
git cat-file -p $last_commit

```

* décrit les métadonnées nécessaires à un commit
  + **nom et email** de l'*auteur* => qui a écrit le code
  + **nom et email** de l'*committer* => qui a déclencher le **commit**
  + la date en tant que *timestamp unix* et la TimeZone
  + le **message** du commit

* puis un objet **tree** contenant la version la plus récente, *pour chaque fichier* ajouté au dépôt depuis le début, à l'instant de ce commit.

## nouveau commit

```bash
echo "a content" > content.txt
git add . && git commit -m "add content.txt"

```

### voir le commit

```bash
git cat-file -p HEAD
```

* on voit l'entrée **parent**: fait référence au commit précédent
> en particulier le "root commit" n'a pas de parent !!
> en particulier un commit de fusion a plusieurs parents (le + souvent 2)

### l'objet tree

```bash
git ls-tree -r $(git cat-file -p HEAD | grep -Po "tree \K.*")
```

* l'on voit les objets **blob** stockant le contenu, **complet**, le + récent, pour chaque fichier ajouté au dépôt depuis le début, à l'instant de ce commit.
  
> le premier commit a ajouté led fichiers [README.md, .gitignore] dans le dépôt
> le second commit a ajouté *uniquement* le fichier content.txt //
> MAIS: le tree du second commit contient les 2 autres fichiers du commit précédent !

* voir un blob `git cat-file -p <blob_hash>`: on voit bien le contenu complet

### incidente importante 

1. à chaque fois qu'on modifie puis "commite" un fichier, la totalité du fichier est stocké dans le blob

2. le blob est une représentation compressée du fichier donc + légère

3. MAIS: il faut faire attention 

> au fichiers sources contenant beaucoup (1000+) de lignes et souvent modfiés (mauvaise pratique)
>  aux grosses images ou tout contenu mal comprimable (est ce vraiment à versionner ?)

## troisième commit (git rm)

```bash
echo "2nd content" > content.txt
echo "bad content" > bad_content.txt
git add . && git commit -m "bad content"

```

### comparaison des poids des blobs de content.txt

```bash
## current blob of content.txt
tree=$(git cat-file -p HEAD | grep -Po "tree \K.*")
blob=$(git ls-tree -r $tree | grep -P "\tcontent\.txt$" | awk '{print $3}')
ll ".git/objects/${blob:0:2}/${blob:2:${#blob}}" | awk '{print $5}'
## ou git cat-file -s $blob

## 28 (octets)

## previous blob of content.txt
tree=$(git cat-file -p HEAD~1 | grep -Po "tree \K.*")
blob=$(git ls-tree -r $tree | grep -P "\tcontent\.txt$" | awk '{print $3}')
ll ".git/objects/${blob:0:2}/${blob:2:${#blob}}" | awk '{print $5}'

## 26 (octets)
```
