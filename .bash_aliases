alias reboot='sudo reboot'
alias pacman='sudo pacman'
alias apt-get='sudo apt-get'
alias apt-cache='sudo apt-cache'
alias agi='apt-get install'
alias acs='apt-cache search'
alias jj='java -jar'
alias home='ssh -X home'
alias service='sudo service'
alias update='apt-get update; apt-get upgrade -y || yaourt -Syyuua'
alias cp='rsync -azvP'
alias tmuxa='tmux attach-session -t Admin'
alias vim='vim -p'
alias sudo='sudo env PATH=$PATH $@'
alias unban='sudo fail2ban-client set ssh unbanip'

# Entering a directory name as a bare word will change into that directory
shopt -s autocd
# Automatically correct off-by-one typing mistakes when changing directories
shopt -s cdspell
# Correct off-by-one typing mistakes when tab-completing directories
shopt -s dirspell
