eval "$(rbenv init -)"
export PATH="/usr/local/share/npm/bin:$PATH"
export PATH="$HOME/.rbenv/bin:$PATH"
export PATH=$HOME/.nodebrew/current/bin:$PATH

# alias
alias be='bundle exec'
alias bi='bundle install --path vendor/bundle --jobs=4'
alias ls='ls -G'
alias rs='be rails s -b 0.0.0.0'

# alias:cd
alias cdni='cd $HOME/git/niqiita-angular'
alias cdn='cd $HOME/git/nbs'
alias cdd='cd $HOME/Desktop'
alias cdmine='cd $HOME/Library/Application\ Support/minecraft/versions/1.7.10-Forge'
alias cdserver='cd $HOME/Desktop/minecraft_server1.9'
alias cdnv='cd $HOME/vms/vagrant-niqiita'
alias cdalice='cd $HOME/git/alice'
alias cdalicechef='cd $HOME/git/alice-chef'
alias cdalicevagrant='cd $HOME/vms/alice-vagrant'
alias cdli='cd $HOME/git/like-slack'

# alias
alias be='bundle exec'
alias bi='bundle install --path vendor/bundle --jobs=4'
alias ls='ls -G'
alias rs='be rails s -b 0.0.0.0'

# alias:git
alias g="git"
alias s="git status"
alias a="git add"
alias rb="git rebase -i"
alias cm="git commit -m"
alias b="git branch"
alias br="git branch -r"
alias bg="git branch |grep"
alias brg="git branch -r |gpep"
alias co="git checkout"
alias cow="git checkout working"
alias cod="git checkout development"
alias com="git checkout master"
alias push="git push origin HEAD"
alias pull="git pull origin HEAD"
alias show="git show"

alias fpush='git push -f origin HEAD'

# chef settings
alias zeroknife_vagrant="chef exec knife zero bootstrap 192.168.33.10 -x vagrant -i /Users/t-kaneko/vms/vagrant-niqiita/.vagrant/machines/niqiita/virtualbox/private_key --sudo -r 'role[vagrant]'"
alias zeroknife_vagrant_niqiita="chef exec knife zero bootstrap 192.168.33.11 -x vagrant -i /Users/t-kaneko/vms/niqiita-production-test/.vagrant/machines/niqiita/virtualbox/private_key --sudo -r 'role[vagrant]'"
alias zeroknife_alice_staging="chef exec knife zero bootstrap 160.16.77.146 -x aliceadmin -i /Users/t-kaneko/.ssh/alice --sudo -r 'role[alice-staging]'"
#alias zeroknife_alice_staging="chef exec knife zero bootstrap 160.16.77.146 -x root -P alice0905 --sudo -r 'role[alice-staging]'"
alias zeroknife_alice="chef exec knife zero bootstrap 153.126.196.253 -x aliceadmin -i /Users/t-kaneko/.ssh/alice --sudo -r 'role[alice-production]'"
# alias zeroknife_alice="chef exec knife zero bootstrap 153.126.196.253 -x root -P alice0905 --sudo -r 'role[alice-production]'"
alias zeroknife_niqiita="chef exec knife zero bootstrap 52.199.0.193 -x ec2-user -i /Users/t-kaneko/.ssh/niqiita.pem --sudo -r 'role[niqiita-production]'"
alias zeroknife_magic="chef exec knife zero bootstrap 52.198.180.96 -x ec2-user -i /Users/t-kaneko/.ssh/niqiita.pem --sudo -r 'role[magic_history_alpha]'"

