alias reboot='sudo reboot'
alias pacman='sudo pacman'
alias apt-get='sudo apt-get'
alias apt-cache='sudo apt-cache'
alias agi='apt-get install'
alias acs='apt-cache search'
alias jj='java -jar'
alias home='ssh home'
alias service='sudo service'
alias update='apt-get update; apt-get upgrade'
alias sudo='sudo env PATH=$PATH $@'
alias wow='wine "C:\Program Files\World of Warcraft\Wow.exe"'
alias cp='rsync -azvP'
alias tmuxa='tmux attach-session -t Admin'

# Entering a directory name as a bare word will change into that directory
shopt -s autocd
# Automatically correct off-by-one typing mistakes when changing directories
shopt -s cdspell
# Make Bash wrap text properly if the terminal size changes
shopt -s checkwinsize
# Correct off-by-one typing mistakes when tab-completing directories
shopt -s dirspell
# Don't clobber other sessions' changes to global history when exiting
shopt -s histappend
