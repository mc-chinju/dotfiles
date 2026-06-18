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

# Cursor: 普段は PATH の `cursor`。別アカウントは `cursor-profile`（fzf でプロファイル選択、以降は cursor と同じ引数）。
# プロファイル定義はリポジトリ外（既定: ~/.cursor-profiles.zsh、CURSOR_PROFILES_FILE で変更可）
# `team` は旧 cursor-team 相当（$CURSOR_TEAM_USER_DATA_DIR で上書き可）
typeset -gA CURSOR_PROFILES
typeset -g CURSOR_PROFILES_FILE="${CURSOR_PROFILES_FILE:-$HOME/.cursor-profiles.zsh}"
typeset -g CURSOR_TEAM_USER_DATA_DIR="${CURSOR_TEAM_USER_DATA_DIR:-$HOME/Library/Application Support/Cursor-team}"
typeset -g CURSOR_PROFILE_BUILTIN_DEFAULT=default
typeset -g CURSOR_DEFAULT_USER_DATA_DIR="${CURSOR_DEFAULT_USER_DATA_DIR:-$HOME/Library/Application Support/Cursor}"

_cursor_profile_is_builtin() {
  [[ "$1" = "$CURSOR_PROFILE_BUILTIN_DEFAULT" ]]
}

_cursor_profile_bin() {
  local bin
  bin="$(whence -p cursor 2>/dev/null)"
  if [ -z "$bin" ]; then
    bin="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
  fi
  if [ ! -x "$bin" ]; then
    echo "cursor not found" >&2
    return 1
  fi
  print -r -- "$bin"
}

_cursor_profiles_load() {
  typeset -gA CURSOR_PROFILES
  CURSOR_PROFILES=()
  [[ -r "$CURSOR_PROFILES_FILE" ]] || return 0
  eval "$(
    <"$CURSOR_PROFILES_FILE" \
    | grep -v '^[[:space:]]*#' \
    | grep -v '^[[:space:]]*$' \
    | sed 's/typeset -A CURSOR_PROFILES/typeset -gA CURSOR_PROFILES/'
  )"
}

_cursor_profiles_save() {
  local f="$CURSOR_PROFILES_FILE" name
  {
    print "# Cursor profile definitions (not tracked in dotfiles)."
    print "# Managed by cursor-profile add/rm."
    print "typeset -gA CURSOR_PROFILES"
    print -n "CURSOR_PROFILES=("
    for name in ${(ko)CURSOR_PROFILES}; do
      print -n " $name ${(qq)CURSOR_PROFILES[$name]}"
    done
    print ")"
    print ""
  } >| "$f" || {
    echo "cursor-profile: could not write $f" >&2
    return 1
  }
}

_cursor_profile_list() {
  local name dir
  printf "%s\t%s\n" "$CURSOR_PROFILE_BUILTIN_DEFAULT" "$CURSOR_DEFAULT_USER_DATA_DIR"
  if [ ${#CURSOR_PROFILES[@]} -eq 0 ]; then
    return 0
  fi
  for name in ${(ko)CURSOR_PROFILES}; do
    dir="$(_cursor_profile_dir "$name")"
    printf "%s\t%s\n" "$name" "$dir"
  done
}

_cursor_profile_dir_for_name() {
  local name="$1"
  if [ "$name" = team ]; then
    print -r -- "$CURSOR_TEAM_USER_DATA_DIR"
  else
    print -r -- "$HOME/Library/Application Support/Cursor-$name"
  fi
}

_cursor_profile_add() {
  local name="$1" dir="$2"

  if [[ -t 0 ]] && [ -z "$name" ]; then
    cat <<'EOF' >&2
Creating a new Cursor profile.
A profile is identified by a short name and stored in its own user-data-dir
(login, settings, and extensions are kept separate from other profiles).

EOF
  fi

  if [ -z "$name" ]; then
    if [[ ! -t 0 ]]; then
      echo "cursor-profile: profile name required (e.g. cursor-profile add second)" >&2
      return 1
    fi
    printf "Profile name (e.g. team, work; letters, numbers, _, - only): " >&2
    IFS= read -r name
    [ -z "$name" ] && { echo "Canceled" >&2; return 1; }
  fi

  if [[ ! "$name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "cursor-profile: invalid name (use letters, numbers, _, -)" >&2
    return 1
  fi

  if _cursor_profile_is_builtin "$name"; then
    echo "cursor-profile: reserved profile name: $name" >&2
    return 1
  fi

  if [[ -n "${CURSOR_PROFILES[$name]}" ]]; then
    echo "cursor-profile: profile already exists: $name" >&2
    return 1
  fi

  dir="$(_cursor_profile_dir_for_name "$name")"

  CURSOR_PROFILES[$name]="$dir"
  _cursor_profiles_save || return 1
  typeset -g _cursor_profile_last_added="$name"
  echo "Added profile: $name -> $dir" >&2
}

_cursor_profile_dir() {
  local profile="$1"
  if _cursor_profile_is_builtin "$profile"; then
    print -r -- "$CURSOR_DEFAULT_USER_DATA_DIR"
    return 0
  fi
  local dir="${CURSOR_PROFILES[$profile]}"
  if [ "$profile" = team ]; then
    dir="$CURSOR_TEAM_USER_DATA_DIR"
  fi
  print -r -- "$dir"
}

_cursor_profile_rm() {
  local name="$1"

  if [ ${#CURSOR_PROFILES[@]} -eq 0 ]; then
    echo "cursor-profile: no profiles to remove" >&2
    return 1
  fi

  if [ -z "$name" ]; then
    name="$(
      local n d
      for n in ${(ko)CURSOR_PROFILES}; do
        d="$(_cursor_profile_dir "$n")"
        printf "%s\t%s\n" "$n" "$d"
      done | fzf --prompt="remove> " --with-nth=1,2 --delimiter="$(printf '\t')" \
             --header="Choose profile to remove"
    )" || return 1
    name="${name%%$'\t'*}"
  fi

  if _cursor_profile_is_builtin "$name"; then
    echo "cursor-profile: cannot remove built-in profile: $name" >&2
    return 1
  fi

  if [[ -z "${CURSOR_PROFILES[$name]}" ]]; then
    echo "cursor-profile: unknown profile: $name" >&2
    return 1
  fi

  unset "CURSOR_PROFILES[$name]"
  _cursor_profiles_save || return 1
  echo "Removed profile: $name"
}

_cursor_profile_launch() {
  local profile="$1"
  shift

  local bin
  bin="$(_cursor_profile_bin)" || return 1

  if _cursor_profile_is_builtin "$profile"; then
    "$bin" "$@"
    return
  fi

  local dir
  dir="$(_cursor_profile_dir "$profile")"
  if [ -z "$dir" ]; then
    echo "cursor-profile: unknown profile: $profile" >&2
    echo "Available: $CURSOR_PROFILE_BUILTIN_DEFAULT ${(k)CURSOR_PROFILES[*]}" >&2
    return 1
  fi

  "$bin" --user-data-dir "$dir" "$@"
}

_cursor_profile_pick() {
  local picked
  picked="$(
    {
      printf "(+)\t[+] create new profile\n"
      printf "%s\t%s (same as \`cursor\`)\n" \
        "$CURSOR_PROFILE_BUILTIN_DEFAULT" "$CURSOR_DEFAULT_USER_DATA_DIR"
      local name dir
      for name in ${(ko)CURSOR_PROFILES}; do
        dir="$(_cursor_profile_dir "$name")"
        printf "%s\t%s\n" "$name" "$dir"
      done
    } | fzf --prompt="profile> " --with-nth=2 --delimiter="$(printf '\t')" \
           --header="Choose Cursor profile / Select (+) to create"
  )" || return 1

  picked="${picked%%$'\t'*}"

  if [ "$picked" = "(+)" ]; then
    _cursor_profile_add || return 1
    picked="$_cursor_profile_last_added"
    [ -z "$picked" ] && return 1
  fi
  typeset -g _cursor_profile_picked="$picked"
}

cursor-profile() {
  emulate -L zsh

  local cmd="$1" profile
  case "$cmd" in
    add)
      shift
      _cursor_profile_add "$@"
      ;;
    rm|remove|del)
      shift
      _cursor_profile_rm "$@"
      ;;
    list|ls)
      _cursor_profile_list
      ;;
    help|-h|--help)
      cat <<'EOF'
Usage:
  cursor-profile [args...]          Choose profile with fzf, then launch Cursor
  cursor-profile .                  Choose profile with fzf, open current directory
  cursor-profile -n .               Choose profile with fzf, open in new window
  cursor-profile add [name]
  cursor-profile rm [name]
  cursor-profile list

Profiles are stored in ~/.cursor-profiles.zsh (or $CURSOR_PROFILES_FILE).
EOF
      ;;
    *)
      _cursor_profile_pick || return 1
      profile="$_cursor_profile_picked"
      _cursor_profile_launch "$profile" "$@"
      ;;
  esac
}

_cursor_profiles_load

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

  local orig_dir pick wt_branch wt_dir opener st
  orig_dir="$PWD"

  # fzf で cursor / cursor-profile / code を選ぶ（1列目がコマンド種別）
  _wt_pick_opener() {
    local line
    line="$(
      {
        printf "cursor\tCursor (default)\n"
        if typeset -f cursor-profile >/dev/null 2>&1; then
          printf "cursor-profile\tCursor (profile)\n"
        fi
        if command -v code >/dev/null 2>&1; then
          printf "code\tVisual Studio Code\n"
        fi
      } | fzf --prompt="open> " --with-nth=2 --delimiter="$(printf '\t')" \
             --header="Choose how to open this worktree"
    )" || return 1
    print -r -- "${line%%$'\t'*}"
  }

  _wt_run_opener() {
    local kind="$1"
    case "$kind" in
      cursor)
        if command -v cursor >/dev/null 2>&1; then
          cursor -n .
        else
          echo "cursor not in PATH" >&2
          return 1
        fi
        ;;
      cursor-profile)
        cursor-profile -n . || return 1
        ;;
      code)
        command -v code >/dev/null 2>&1 && code -n . || return 1
        ;;
      *)
        echo "wt: unknown opener: $kind" >&2
        return 1
        ;;
    esac
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
    local br base_ref repo_root wt_root dir_safe new_dir current_branch

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

    local git_common
    git_common="$(git rev-parse --git-common-dir)" || {
      echo "wt: could not resolve git common dir" >&2
      cd "$orig_dir" || true
      return 1
    }
    [[ $git_common = /* ]] || git_common="${PWD:A}/$git_common"
    repo_root="${git_common:A:h}"
    wt_root="$repo_root/.worktree"
    mkdir -p "$wt_root" || {
      echo "wt: could not create directory: $wt_root" >&2
      cd "$orig_dir" || true
      return 1
    }

    dir_safe="${br//\//__}"
    new_dir="$wt_root/$dir_safe"

    local did_add=0
    if [ ! -d "$new_dir" ]; then
      git worktree add -b "$br" "$new_dir" "$base_ref" || { cd "$orig_dir"; return 1; }
      did_add=1
    fi

    opener="$(_wt_pick_opener)" || {
      echo "wt: opener selection canceled" >&2
      [ -d "$new_dir" ] && echo "wt: worktree path: $new_dir" >&2
      if [ "$did_add" -eq 1 ]; then
        git worktree remove "$new_dir" 2>/dev/null || echo "wt: could not remove new worktree automatically: $new_dir" >&2
      fi
      return 1
    }
    cd "$new_dir" || { cd "$orig_dir"; return 1; }
    _wt_run_opener "$opener"
    st=$?
    cd "$orig_dir" || true
    [ $st -ne 0 ] && return "$st"
    return 0
  fi

  # Open existing
  [ -z "$wt_dir" ] && return 0
  opener="$(_wt_pick_opener)" || {
    echo "wt: opener selection canceled" >&2
    return 1
  }
  cd "$wt_dir" || { cd "$orig_dir"; return 1; }
  _wt_run_opener "$opener"
  st=$?
  cd "$orig_dir" || true
  [ $st -ne 0 ] && return "$st"
  return 0
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
