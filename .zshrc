# GLOBAL
export LSCOLORS=Dxfxcxdxbxegedabagacad

# Terminal name
export PS1="%n %~ \$ "

# Homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# python (Homebrew: /opt/homebrew/bin/pyenv)
eval "$(pyenv init -)"

# rbenv (Homebrew: /opt/homebrew/bin/rbenv)
eval "$(rbenv init -)"

# nodenv (git clone: ~/.nodenv/bin, or Homebrew: /opt/homebrew/bin/nodenv)
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
  emulate -L zsh
  setopt localoptions interactivecomments

  # guard
  command -v git >/dev/null 2>&1 || { echo "git not found"; return 1; }
  command -v fzf >/dev/null 2>&1 || { echo "fzf not found"; return 1; }
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Not a git repo"; return 1; }

  local orig_dir pick wt_branch wt_dir
  orig_dir="$PWD"

  # open current dir in new window (Cursor preferred; fallback VS Code)
  _wt_open_here() {
    if command -v cursor >/dev/null 2>&1; then
      cursor -n .
    elif command -v code >/dev/null 2>&1; then
      code -n .
    fi
  }

  # Build list (TAB-separated): branch<TAB>dir
  pick="$(
    {
      # first line: create
      printf "(+)\t[+] create new worktree\n"

      # existing worktrees
      git worktree list --porcelain | awk '
        BEGIN{dir=""; branch=""}
        $1=="worktree"{dir=$2}
        $1=="branch"{branch=$2}
        $1==""{
          b=branch
          sub(/^refs\/heads\//,"",b)
          if (b=="") b="(detached)"
          if (dir!="") printf "%s\t%s\n", b, dir
          dir=""; branch=""
        }
      '
    } | fzf --prompt="wt> " --with-nth=1,2 --delimiter="$(printf '\t')" \
           --header="ENTER: open (cd temporarily + new window) / Select (+) to create"
  )" || return

  wt_branch="${pick%%$'\t'*}"
  wt_dir="${pick#*$'\t'}"

  # Create new
  if [ "$wt_branch" = "(+)" ]; then
    local br base_ref wt_root dir_safe new_dir current_branch

    printf "New branch name (e.g. feat/login-fix): "
    IFS= read -r br
    [ -z "$br" ] && { echo "Canceled"; return 0; }

    current_branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)"
    local is_detached=0
    [ -z "$current_branch" ] && { current_branch="$(git rev-parse --short HEAD)"; is_detached=1; }

    local fzf_header
    if [ "$is_detached" -eq 1 ]; then
      fzf_header="Base branch (detached HEAD: $current_branch)"
    else
      fzf_header="Base branch (default: $current_branch)"
    fi

    base_ref="$(
      {
        echo "$current_branch"
        git branch -a --format='%(refname:short)' | grep -vxF "$current_branch" | grep -v 'HEAD$'
      } | fzf --prompt="base> " --header="$fzf_header"
    )" || { echo "Canceled"; return 0; }

    wt_root="../wt"
    mkdir -p "$wt_root" 2>/dev/null || true

    dir_safe="${br//\//__}"
    new_dir="$wt_root/$dir_safe"

    if [ ! -d "$new_dir" ]; then
      git worktree add -b "$br" "$new_dir" "$base_ref" || { cd "$orig_dir"; return 1; }
    fi

    cd "$new_dir" || { cd "$orig_dir"; return 1; }
    _wt_open_here
    cd "$orig_dir"
    return 0
  fi

  # Open existing
  [ -z "$wt_dir" ] && return 0
  cd "$wt_dir" || { cd "$orig_dir"; return 1; }
  _wt_open_here
  cd "$orig_dir"
}

sw() {
  emulate -L zsh

  # 引数があれば git switch のエイリアスとして扱う（sw -c feature/foo 等）
  if [ $# -gt 0 ]; then
    git switch "$@"
    return
  fi

  command -v git >/dev/null 2>&1 || { echo "git not found"; return 1; }
  command -v fzf >/dev/null 2>&1 || { echo "fzf not found"; return 1; }
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Not a git repo"; return 1; }

  local pick branch
  pick="$(
    {
      printf "(+)\t[+] create new branch\n"
      git branch --format='%(refname:short)'
    } | fzf --prompt="sw> " --with-nth=1,2 --delimiter="$(printf '\t')" \
       --header="Switch branch / Select (+) to create"
  )" || return

  branch="${pick%%$'\t'*}"

  if [ "$branch" = "(+)" ]; then
    local br base_ref current_branch fzf_header
    printf "New branch name (e.g. feat/login-fix): "
    IFS= read -r br
    [ -z "$br" ] && { echo "Canceled"; return 0; }

    current_branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)"
    [ -z "$current_branch" ] && current_branch="$(git rev-parse --short HEAD)"

    fzf_header="Base branch (default: $current_branch)"
    base_ref="$(
      {
        echo "$current_branch"
        git branch -a --format='%(refname:short)' | grep -vxF "$current_branch" | grep -v 'HEAD$'
      } | fzf --prompt="base> " --header="$fzf_header"
    )" || { echo "Canceled"; return 0; }

    git switch -c "$br" "$base_ref"
    return 0
  fi

  git switch "$branch"
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

brm() {
  emulate -L zsh

  command -v git >/dev/null 2>&1 || { echo "git not found"; return 1; }
  command -v fzf >/dev/null 2>&1 || { echo "fzf not found"; return 1; }
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Not a git repo"; return 1; }

  local current_branch branch
  current_branch="$(git branch --show-current)"

  branch="$(
    git branch --format='%(refname:short)' \
    | fzf --prompt="brm> " --header="Delete branch (-D). Current: $current_branch"
  )" || return

  [ "$branch" = "$current_branch" ] && {
    echo "Refuse: cannot delete current branch: $branch"
    return 1
  }

  echo "Deleting branch: $branch"
  git branch -D "$branch"
}

export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/openssl@3/lib"
export CPPFLAGS="-I/opt/homebrew/opt/openssl@3/include"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
