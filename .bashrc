alias gst='git status'
__git_complete gst _git_status
alias gci='git commit'
__git_complete gci _git_commit
alias gco='git checkout'
__git_complete gco _git_checkout
alias gadd='git add .'
alias push='git push'
__git_complete push _git_push
alias pull='git pull'
__git_complete pull _git_pull
alias fetch='git fetch'
__git_complete fetch _git_fetch
alias gbr='git branch'
__git_complete gbr _git_branch
# alias gsw='auto-stash.sh'
# __git_complete gsw _git_switch


# en cas de passphrase de clé privée ssh
# eval `ssh-agent -s`
# ssh-add ~/.ssh/<key_name>

ac(){
  if [ $# -ne 1 ]; then echo "bad message !!!"
  elif [ $# -eq 1 ]; then gadd && gci -m "$1"; fi
}

acp(){
  current_branch=$(check_current_branch)
  cat .git/config | grep -q "merge = refs/heads/$current_branch"        
  if [ "$?" -ne 0 ]; then echo "begin with git push -u <repo> $current_branch !!!"
  elif [ $# -ne 1 ]; then echo "bad message !!!"
  else  ac "$1" && push; fi
}