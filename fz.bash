#!/usr/bin/env bash

__fz_fzf_prog() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ] &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

__fz_matched_history_list() {
  _z -l "$@" 2>&1 | sed '/^common/ d' | sed '1!G;h;$!d' | cut -b 12-
}

__fz_matched_subdir_list() {
  local dir seg starts_with_dir
  if [[ "$1" == */ ]]; then
    dir="${1}"
    find -L "$(cd "$dir" 2>/dev/null && pwd)" -mindepth 1 -maxdepth 1 -type d \
        2>/dev/null | while read -r line; do
      base="${line##*/}"
      if [[ "${base::1}" == "." ]]; then
        continue
      fi
      echo "$line"
    done
  else
    dir=$(dirname "${1}")
    seg=$(basename "${1}")
    starts_with_dir=$( \
      find -L "$(cd "$dir" 2>/dev/null && pwd)" -mindepth 1 -maxdepth 1 \
          -type d 2>/dev/null | while read -r line; do \
        base="${line##*/}"
        if [[ "${seg::1}" != "." && "${base::1}" == "." ]]; then
          continue
        fi
        if [[ "$base" == "$seg"* ]]; then
          echo "$line"
        fi
      done
    )
    if [ -n "$starts_with_dir" ]; then
      echo "$starts_with_dir"
    else
      find -L "$(cd "$dir" 2>/dev/null && pwd)" -mindepth 1 -maxdepth 1 \
          -type d 2>/dev/null | while read -r line; do \
        base="${line##*/}"
        if [[ "${seg::1}" != "." && "${base::1}" == "." ]]; then
          continue
        fi
        if [[ "$base" == *"$seg"* ]]; then
          echo "$line"
        fi
      done
    fi
  fi
}

_fz_list_generator() {
  local l
  l=$(__fz_matched_history_list "$@")
  if [ "$FZ_SUB_DIR_TRAVERSAL_ENABLED" = 1 ]; then
    if [ "$1" = "-c" ]; then
      shift
    fi
    l="$l
$(__fz_matched_subdir_list "$@")"
  fi
  echo "$l" | sed '/^$/d' | awk '!seen[$0]++'
}

_fz_complete() {
  COMPREPLY=()
  local l fzf selected

  l=$(_fz_list_generator "$@")

  if [[ -z "${COMP_WORDS[COMP_CWORD]}" \
      && ! "${COMP_WORDS[@]}" =~ ^\ *fz\ +$ ]]; then
    return
  fi

  local line="${COMP_WORDS[@]:1}"
  line="${line/#\~/$HOME}"

  if [ -z "$(_fz_list_generator $line)" ]; then
    return
  fi

  fzf=$(__fz_fzf_prog)

  if [ "$(_fz_list_generator $line | wc -l)" -eq 1 ]; then
    selected=$(_fz_list_generator $line)
  else
    selected=$(_fz_list_generator $line \
      | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} \
        --reverse $FZF_DEFAULT_OPTS $FZF_COMPLETION_OPTS \
        --bind 'shift-tab:up,tab:down'" $fzf)
  fi
  printf '\e[5n'

  if [ -n "$selected" ]; then
    COMPREPLY=( "$selected"/ )
    return 0
  fi
}

fz() {
  local rc
  if [ "$(_z -l "$@" 2>&1 | wc -l)" -gt 0 ]; then
    _z "$@"
  else
    if [ "$FZ_SUB_DIR_TRAVERSAL_ENABLED" = 1 ]; then
      err=$(cd "${@: -1}" 2>&1)
      rc=$?
      if ! cd "${@: -1}" 2>/dev/null; then
        echo ${err#* } >&2
        return $rc
      fi
    fi
  fi
}

complete -F _fz_complete -o nospace fz
