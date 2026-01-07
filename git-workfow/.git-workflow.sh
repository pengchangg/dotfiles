#!/usr/bin/env bash
# =========================================================
# Personal Git Workflow Helpers
# Target: Single-user, main + feat/fix branches
# Shell: bash
# =========================================================

# ---------- internal helpers ----------

_git_branch() {
  git symbolic-ref --short HEAD 2>/dev/null
}

_git_on_repo() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

_git_require_repo() {
  if ! _git_on_repo; then
    echo "not a git repository"
    return 1
  fi
}

# ---------- base aliases ----------

alias gad='git add .'
alias gs='git status'
alias gco='git checkout'
alias gbr='git branch'
alias glast='git log -1 --oneline'
alias glg='git log --graph --oneline --decorate'
alias gtl="git ls-remote --tags origin | awk '!/\^\{\}/'"

# ---------- branch creation ----------

gfeat() {
  _git_require_repo || return 1
  [ -z "$1" ] && echo "usage: gfeat <name>" && return 1

  git checkout main || return 1
  git pull --ff-only || return 1
  git checkout -b "feat/$1"
}

gfix() {
  _git_require_repo || return 1
  [ -z "$1" ] && echo "usage: gfix <name>" && return 1

  git checkout main || return 1
  git pull --ff-only || return 1
  git checkout -b "fix/$1"
}

# ---------- commit ----------

gcm() {
  _git_require_repo || return 1
  [ -z "$1" ] && echo 'usage: gcm "type: message"' && return 1

  git status
  echo

  printf "Continue and stage ALL changes? [y/N]: "
  read -r -n 1 confirm
  echo

  case "$confirm" in
    y|Y)
      git add . || return 1
      git commit -m "$1"
      ;;
    *)
      echo "aborted"
      return 1
      ;;
  esac
}



# ---------- status / context ----------


gwhere() {
  _git_require_repo || return 1
  local branch
  branch="$(_git_branch)"
  echo "branch: $branch"
  git status --short
}

# ---------- merge workflow ----------

gmerge() {
  _git_require_repo || return 1

  local current
  current=$(_git_branch)

  if [ "$current" = "main" ]; then
    echo "already on main"
    return 1
  fi

  git checkout main || return 1
  git pull --ff-only || return 1
  git merge "$current"
}

gclean() {
  _git_require_repo || return 1

  git branch --merged main \
    | grep -vE '^\*|main' \
    | xargs -r git branch -d

  if [ "$(_git_branch)" != "main" ]; then
    git checkout main
  fi
}

gdone() {
  gmerge && gclean
}

# ---------- tag ----------

gtag() {
  _git_require_repo || return 1
  [ -z "$1" ] && echo "usage: gtag-annotated vX.Y.Z" && return 1
  [ -z "$2" ] && echo "usage: gtag-annotated vX.Y.Z \"message\"" && return 1

  git tag -a "$1" -m "$2" || return 1
  git push origin "$1" || return 1
  echo "annotated tag $1 created with message: $2"
}

# ---------- safety ----------

# Explicitly discourage direct commit on main
gcm-main() {
  echo "direct commit on main is discouraged"
  return 1
}

# ---------- help ----------

ghelp() {
  cat <<EOF
Git Workflow Commands:

  gfeat <name>          create feat/<name> from main
  gfix <name>           create fix/<name> from main
  gcm "msg"             commit with message
  gwhere                show current branch and status
  gmerge                merge current branch into main
  gclean                delete merged branches
  gdone                 gmerge + gclean
  gtag vX.Y.Z "msg"     create and push tag

Base aliases:
 gad, gs, gco, gbr, glast, glg, gtl
EOF
}

