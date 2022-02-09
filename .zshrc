# GLOBAL
export LSCOLORS=Dxfxcxdxbxegedabagacad

# Terminal name
export PS1="%n %~ \$ "

# Homebrew
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH

# rbenv
export PATH="$HOME/.rbenv/shims:${PATH}"
# eval "$(rbenv init -)"

# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"

# alias
alias be='bundle exec'
alias bi='bundle install'
alias ls='ls -G'
alias rs='be rails s -b 0.0.0.0'
alias :q='exit'

# alias:cd
alias cdd="cd $HOME/Desktop"

# alias:git
alias g="git"
alias l="git log"
alias s="git status"
alias a="git add"
alias re="git reset"
alias f="git fetch --prune"
alias rb="git rebase"
alias cm="git commit"
alias m="git merge"
alias b="git branch"
alias br="git branch -r"
alias bdall="git branch --merged | grep -v '*' | xargs -I % git branch -d %"
alias ch="git cherry-pick"
alias co="git checkout"
alias sw="git switch"
alias rt="git restore"
alias cow="git checkout working"
alias cod="git checkout develop"
alias com="git checkout master"
alias sww="git switch working"
alias swd="git switch develop"
alias swm="git switch main"
alias d="git diff"
alias ds="git diff --staged"
alias f="git fetch --prune"
alias push="git push origin HEAD"
alias fpush='git push -f origin HEAD'
alias pull="git pull origin HEAD"
alias show="git show"
alias st="git stash"

export PATH="/usr/local/opt/openssl@3/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/openssl@3/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@3/include"
