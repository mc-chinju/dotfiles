# GLOBAL
export LSCOLORS=Dxfxcxdxbxegedabagacad

# Terminal name
export PS1="%n %~ \$ "

# Homebrew
export PATH=/usr/local/bin:$PATH
export PATH=/usr/local/sbin:$PATH

# python
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"

# rbenv
export PATH="$HOME/.rbenv/shims:${PATH}"
eval "$(rbenv init -)"

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

wt() {
  local dir
  dir=$(git worktree list | awk '{print $1}' | fzf) || return
  cd "$dir"
  cursor -a .
}

wtrm() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

  local line wt_dir wt_branch
  line=$(
    git worktree list --porcelain \
    | awk '
      BEGIN{dir=""; branch=""; locked=0}
      $1=="worktree"{dir=$2}
      $1=="branch"{branch=$2}
      $1=="locked"{locked=1}
      $1==""{
        b=branch
        sub(/^refs\/heads\//,"",b)
        if (b=="") b="(detached)"
        printf "%s\t%s\t%s\n", dir, b, (locked? "LOCKED":"")
        dir=""; branch=""; locked=0
      }
    ' \
    | fzf --with-nth=2,1,3 --delimiter=$'\t' --prompt="Remove worktree> " \
      --header="Shows: branch / path / lock"
  ) || return

  wt_dir=$(printf "%s" "$line" | awk -F'\t' '{print $1}')
  wt_branch=$(printf "%s" "$line" | awk -F'\t' '{print $2}')

  # 本丸の作業ディレクトリは消さない
  if [ "$wt_dir" = "$(git rev-parse --show-toplevel)" ]; then
    echo "Refuse: cannot remove main working tree: $wt_dir"
    return 1
  fi

  echo "Removing worktree: $wt_dir (branch: $wt_branch)"
  git worktree remove "$wt_dir" || return 1
  git worktree prune >/dev/null 2>&1 || true
}

# wtrm-multi() {
#   git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

#   local selected
#   selected=$(
#     git worktree list --porcelain \
#     | awk '
#       BEGIN{path=""; branch=""; locked=0}
#       $1=="worktree"{path=$2}
#       $1=="branch"{branch=$2}
#       $1=="locked"{locked=1}
#       $1==""{
#         b=branch
#         sub(/^refs\/heads\//,"",b)
#         if (b=="") b="(detached)"
#         printf "%s\t%s\t%s\n", path, b, (locked? "LOCKED":"")
#         path=""; branch=""; locked=0
#       }
#     ' \
#     | fzf -m --with-nth=2,1,3 --delimiter=$'\t' --prompt="Remove worktrees> " \
#       --header="MULTI: TAB to mark, ENTER to remove"
#   ) || return

#   local main
#   main="$(git rev-parse --show-toplevel)"

#   printf "%s\n" "$selected" | while IFS=$'\t' read -r path branch locked; do
#     [ -z "$path" ] && continue
#     if [ "$path" = "$main" ]; then
#       echo "Skip main working tree: $path"
#       continue
#     fi
#     echo "Removing: $path (branch: $branch) $locked"
#     git worktree remove "$path" || exit 1
#   done

#   git worktree prune >/dev/null 2>&1 || true
# }

# wtrm-merged() {
#   git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return

#   local base="${1:-main}"
#   git show-ref --verify --quiet "refs/heads/$base" || {
#     echo "Base branch not found: $base"
#     return 1
#   }

#   local main
#   main="$(git rev-parse --show-toplevel)"

#   # worktree一覧（path + branch）を作る
#   git worktree list --porcelain \
#   | awk '
#     BEGIN{path=""; branch=""}
#     $1=="worktree"{path=$2}
#     $1=="branch"{branch=$2}
#     $1==""{
#       b=branch; sub(/^refs\/heads\//,"",b)
#       if (b!="") printf "%s\t%s\n", path, b
#       path=""; branch=""
#     }
#   ' | while IFS=$'\t' read -r path br; do
#     [ -z "$path" ] && continue
#     [ "$path" = "$main" ] && continue
#     [ -z "$br" ] && continue

#     # baseにマージ済みか？
#     if git merge-base --is-ancestor "$br" "$base" 2>/dev/null; then
#       echo "Removing merged worktree: $path (branch: $br -> $base)"
#       git worktree remove "$path" || exit 1
#     fi
#   done

#   git worktree prune >/dev/null 2>&1 || true
# }

export PATH="/usr/local/opt/openssl@3/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/openssl@3/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@3/include"
export PATH="/usr/local/opt/postgresql@17/bin:$PATH"

# Added by Antigravity
export PATH="/Users/chinju/.antigravity/antigravity/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
