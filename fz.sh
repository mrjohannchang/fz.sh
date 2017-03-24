#!/usr/bin/env bash

__fz_fzf_prog() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ] &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

__fz_matched_history_list() {
  _z -l "$@" 2>&1 | sed '/^common/ d' | sed '1!G;h;$!d' | cut -b 12-
}

__fz_matched_subdir_list() {
  local base length
  if [[ "$1" == */ ]]; then
    if [ "$(echo -n $1 | wc -c)" -gt 1 ]; then
      base="${1: : -1}"
    else
      base="$1"
    fi
    length=$(echo -n $1 | wc -c)
    find -L "$base" -maxdepth 1 -type d 2>/dev/null \
      | cut -b $(( ${length} + 1 ))- | sed '/^$/d'
  else
    dir=$(dirname "$1")
    if [ "$dir" = "/" ]; then
      length=0
    else
      length=$(echo -n $dir | wc -c)
    fi
    seg=$(basename "$1")
    starts_with_dir=$( \
      find -L "$dir" -maxdepth 1 -type d 2>/dev/null \
      | cut -b $(( ${length} + 2 ))- | sed '/^$/d' \
      | while read -r line; do \
        if [[ "$line" = "$seg"* ]]; then
          echo "$line"
        fi
      done
    )
    if [ -n "$starts_with_dir" ]; then
      echo "$starts_with_dir"
    else
      find -L "$dir" -maxdepth 1 -type d 2>/dev/null \
        | cut -b $(( ${length} + 2 ))- | sed '/^$/d' \
        | grep --color=never -F "$seg"
    fi
  fi
}
