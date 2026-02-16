# cas d'utilisations de revert

> copier le dossier "reverts" en dehors du dépôt local courant

## setup

```bash
git init
echo "content" > content.txt
git add . && git commit -m "root-commit"

```
---

## que fait un revert

1. créer un 2ème commit

```bash
echo -e "\n2nd_content\n" >> content.txt
git add content.txt && git commit -m "2nd content"

```

---

2. considérer les diffs

```bash
git diff HEAD~1 HEAD
git diff HEAD HEAD~1
```

---

3. appliquer un objet diff au commit courant et créer un commit

```bash
git diff HEAD HEAD~1 | git apply
git add . && git commit -m "revert 2nd content"
```

---

4. c'est ce que fait `git revert`

```bash
## --no-edit : message par défaut
git revert HEAD --no-edit
git diff HEAD~1 HEAD
```

---

## conflit de revert sur un commit

1. créer 2 commits

```bash
echo -e "\n3rd_content\n" >> content.txt
git add content.txt && git commit -m "3rd content"

echo -e "\n4th_content\n" >> content.txt
git add content.txt && git commit -m "4th content"

```

---

2. on va inverser le **"3rd content"** => donc **HEAD~1**

* `git revert HEAD~1 --no-edit`

---

3. conflit !!

* `cat content.txt`

```text
content
<<<<<<< HEAD

3rd_content


4th_content

=======
>>>>>>> parent of f62170a (3rd content)
```

---

4. explications

> ce `revert` veut créer un commit inversant les diffs entre **HEAD~2 et HEAD~1**

* `git diff HEAD~1 HEAD~2` : on veut dégager "3rd content"

> mais l'état résultant de ce revert est en *contradiction* avec l'**état de HEAD** qui contien "4th content" !!

> git ne peut pas écraser l'état du commit **HEAD**

---

5. 2 actions possibles

* on annule et on réétudie le cas:  `git revert --abort`:
* résolution de conflits:
  + modifier les zones en conflit
```bash
cat <<EOF > content.txt
content

4th_content

EOF

```
  + `git add . && git revert --continue --no-edit`

---

## conflit de revert avec plusieurs commits

* on peut demander plusieurs commits à `git revert`
  + `git revert <hash1> <hash2> ...`

* on peut demander une suite de commits contigus également
  + `git revert <hash1>..<hash2>`

---

### setup

1. 3 commits

```bash
echo -e "\n5th_content\n" >> content.txt
echo "new_file" > new_file.txt
git add . && git commit -m "5th content + new_file.txt"

echo -e "\n6th_content\n" >> content.txt
git add content.txt && git commit -m "6th content"

echo -e "\n7th_content\n" >> content.txt
git add content.txt && git commit -m "7th content"

```
---

2. on veut inverser les 5th content et 6th content

* `git revert HEAD~2 HEAD~1`
* pas de `--no-edit` on va faire un message perso

---

3. conflit

* nouvelle possibilité: on peut annuler le revert de **HEAD~1** s'il y a un pb avec celui là et on se concentre sur **HEAD**
* `git revert --skip`
* on termine comme avec le cas précédent ...
```bash
cat <<EOF > content.txt
content

4th_content

7th_content

EOF

git add content.txt && git revert --continue
```

---

> pourquoi --continue et non un commit ?
> s'il y a plusieurs commits à inverser `--continue` permet de résoudre des cnoflits séquentiellement