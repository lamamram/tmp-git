#!/bin/bash
# à placer dans un alias linux
# dans ~/.bashrc
# alias gsw='/path/to/auto-stash.sh'
# __git_complete gsw _git_switch

# retourne de l'index du stash en fonction d'un message
check_index(){
  git stash list | grep -Po "\K[0-9]+\}.+tmp-stash-$1$" | awk -F '}' '{ print $1  }'
}

# retourne la branche courante
check_current_branch(){
  git branch -v | grep -Po "^\* \K[a-zA-Z0-9_-]+"
}

current_branch=$(check_current_branch)

# si je n'ai pas de modifs dans le stash
# alors je remise les possibles modifs de la branche courante dans le stash
# en nommant l'entrée du stash avec le nom de la branche courante
if [[ -z $(check_index $current_branch) ]]; then
  # -u : untracked files
  # -q : quiet
  # -m : message
  git stash push -u -q -m "tmp-stash-$current_branch"
fi

# je bascule sur la branche demandée
new_branch=$1
git switch $new_branch
# permet de se remettre sur la branche précédente !!!
if [[ "$1" == "-" ]]; then
  new_branch=$(check_current_branch)  
fi

# je récupère l'index du stash de la nouvelle branche s'il existe,
# car on ne peut pas restaurer un stash avec le message
index=$(check_index $new_branch)
# s'il y a un stash a restaurer
if [[ ! -z $index ]]; then
  git stash pop -q stash@{$index}
fi