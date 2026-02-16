# git push rejetté par git

> REGLE D'OR: faire un pull avant un push !!!

---

## cas de la réécriture d'historique

* `git reset | rebase | commit --amend | cherry-picking | ...`

### sur une branche inidividuelle (feature)

`git push -f`

---

### sur une branche commune (dev / main / preprod / prod )

* il faut **réparer l'historique**
* dans ce cas il faut **retrouver le commmit** avant la réécriture de l'historique locale

```bash
# trouver le commit le plus récent avant réécriture
git reflog
# s'il y a des modifs non commitées dans la copie
git stash -u
# restaurer ce commit
git reset [--hard | --mixed] stash@{index}
# restaurer les modifications stashées
git stash pop
### RESOLUTION SI CONFLIT !!!
```

---

## cas d'un push sans avoir fait un pull préalable

### setup

#### 2 configs possibles

* autoriser le Fast-Forward
* ou non (ci-dessous)

```bash
# on veut des commits de fusion tout le temps en fusion
git config --global merge.ff false
# mais pas en pull !!! 
# car pull fait une fusion d' origin/<branch> dans <branch>
git config --global pull.ff only
```

---

#### dépôts

* le dépôt courant: 

```bash
git init
git add . && git commit -m "root-commit"
```

* créer un dépôt distant (cf `../server-git.md`)
* dépôt alternatif:

```bash
cd ..
git clone git@<subject>.lan:app.git
```

---

### manip

1. dépôt alternatif: 

```bash
echo "alt update" > alt.txt
git add . && git commit -m "alt update"
git push origin main
```

---

2. dépôt courant: 

```bash
echo "my update" > content.txt
git add . && git commit -m "my update"
git push origin main
### REJECTED !!!! ###
```

---

3. problème

> *git ne peut pas incorporer le commit "my update"*
> *car le commit "alt update" déjà poussé sur le dépôt distant*
> *n'a pas de relation enfant <=> parent avec le premier*

---

### résolution

* `git pull` : pour la config 1 Fast-Forward

> *pb à cause de la configuration no-ff sur merge et ff only sur pull*
> *on ne veut pas de commit de fusion sur un pull !!!*

* `git pull --rebase` : pour la config 2 non Fast-Forward

> *remplace le merge par un rebase dans le pull (fetch && rebase)*
> *OK: place le commit "alt update" AVANT "my update"*