# alléger un dépôt git

## setup

```bash
git init
git add cut_history.md
git commit -m "root-commit"
echo "first contenu" > content.txt
git add README.md content.txt
git commit -m "ajout README & content"
echo -e "\nsecond contenu\n" >> content.txt
git add content.txt
git commit -m "MAJ1 content"
echo -e "\nthird contenu\n" >> content.txt
echo "first contenu" > content2.txt
git add content.txt content2.txt
git commit -m "MAJ2 content + ADD content2"

# taille des objets
du -sh .git/objects
```

## stockage dans les sous dossiers .git/objects "loose objects"

### ajouter un gros fichier

```bash
curl https://raw.githubusercontent.com/mojombo/grit/master/lib/grit/repo.rb > repo.rb
git add repo.rb
git commit -m "ajout big file"

# taille du blob
blob=$(git cat-file -p main^{tree} | grep -P "\trepo\.rb$" | awk '{ print $3 }')
git cat-file -s $blob

# taille complète
du -sh .git/objects
```

### petite modification sur un gros fichier

```bash
echo "# MODIF" >> repo.rb
git commit -am "MAJ big file"

## IDEM
new_blob=$(git cat-file -p main^{tree} | grep -P "\trepo\.rb$" | awk '{ print $3 }')
git cat-file -s $new_blob

# taille complète
du -sh .git/objects
```

> stockage complet mais volumineux des versions des fichiers !!!

## stockage dans les fichiers "pack"

* rassembler les objets liés à un commit dans un fichier `.pack`
* on trouve un élément dans un pack à partir de son `offset`
* les `offsets` sont listés dans le fichier `.idx` associé
* les blobs sont transformés en `deltas` assis sur la version précédente
> STOCKAGE INCREMENTAL

```bash
git gc
# version plus précise mais plus lente
git gc --aggressive
```

## supprimer les blobs / commits inaccessibles "unreachable"

### commit inaccessible

```bash
# recommencer le setup avec un nouveau dépôt sans le git gc
# commit(s) inconnu(s) dans l'historique d'aucune branche
# Ex:
git reset --hard HEAD~2

# NI dans le reflog
git reflog -3
# expire par défaut garde les *2 dernières semaines*
git reflog expire --all --expire-unreachable=now

# voir les éléments accessibles
git fsck --unreachable
```

### empaqueter PUIS supprimer les éléments inaccessibles

```bash
# le Garbage Collector créer le pack sans les éléments inaccessibles
git gc --aggressive
# voir les objets dans le pack
git verify-pack -v .git/objects/pack/*.idx
# lister les objets "loose" restants
git count-objects -v 
# déterminer la liste des éléments à supprimer
git prune -n --expire=now
# pour de vrai
git prune --expire=now
```

### empaqueter ET supprimer les éléments inaccessibles

* `git gc --aggressive --prune=all`

## application possible: couper l'historique d'une branche

### setup

```bash
curl https://raw.githubusercontent.com/mojombo/grit/master/lib/grit/repo.rb > repo.rb
git add .
git commit -m "ajout big file"

echo "# MODIF" >> repo.rb
git commit -am "MAJ big file"

echo "# MODIF" >> content2.txt
git commit -am "MAJ content2"

```

### virer tous les commits avant HEAD~1 et recommencer sur celui là

[ici](./cut_history.md)