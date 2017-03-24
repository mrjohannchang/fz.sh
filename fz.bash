#!/usr/bin/env bash

[ -n "$FZ_JUMP_PROG" ] || FZ_JUMP_PROG=_z

__fz_fzf_complete() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ] &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

__fz_z_list() {
  _z -l "$@" 2>&1 | sed '/^common/ d' | sed '1!G;h;$!d' | cut -b 12-
}

_fz_default_list_generator() {
  # filter out line starting with common -> reverse order
  #   -> print second column only
  _z -l "$@" 2>&1 | sed '/^common/ d' | sed '1!G;h;$!d' | cut -b 12-

  if [ "$1" = "-c" -a -n "$2" ] || [ "${DIR:0:1}" != "/" ]; then
    find . -type d -name
  else
  fi
}

_fz_complete() {
  COMPREPLY=()

  local list_generator="${fz_list_generator:-_fz_default_list_generator}"

  if [[ -z "${COMP_WORDS[COMP_CWORD]}" \
      && ! "${COMP_WORDS[@]}" =~ ^\ *fz\ +$ ]]; then
    return
  fi

  local line="${COMP_WORDS[@]:1}"
  line="${line/#\~/$HOME}"

  if [ -z "$("$list_generator" $line)" ]; then
    return
  fi

  local selected
  local fzf=$(__fz_fzf_complete)

  if [ "$("$list_generator" $line | wc -l)" -eq 1 ]; then
    selected=$("$list_generator" $line)
  else
    selected=$("$list_generator" $line \
      | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} \
        --reverse $FZF_DEFAULT_OPTS $FZF_COMPLETION_OPTS \
        --bind 'shift-tab:up,tab:down'" $fzf)
  fi
  printf '\e[5n'

  if [ -n "$selected" ]; then
    COMPREPLY=( "$selected" )
    return 0
  fi
}

fz() {
  if [ "$(__fz_z_list "$@" 2>/dev/null | wc -l)" -gt 0 ]; then
    "$FZ_JUMP_PROG" "$@"
  else
    if [ "$FZ_SUB_DIR_TRAVERSAL_ENABLED" -eq 1 ]; then
      cd "$@" 2>/dev/null
    fi
  fi
}

complete -F _fz_complete -o nospace fz
