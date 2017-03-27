#!/usr/bin/env zsh

__fz_fzf_prog() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ] \
    && echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

__fz_matched_history_list() {
  _z -l $@ 2>&1 | sed '/^common/ d' | sed '1!G;h;$!d' | cut -b 12-
}

__fz_matched_subdir_list() {
  local dir seg starts_with_dir
  if [[ "$1" == */ ]]; then
    dir="${1}"
    find -L "$(cd "$dir" 2>/dev/null && pwd)" -mindepth 1 -maxdepth 1 -type d \
        2>/dev/null | while read -r line; do
      base="${line##*/}"
      if [[ "${base[1]}" == "." ]]; then
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
        if [[ "${seg[1]}" != "." && "${base[1]}" == "." ]]; then
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
        if [[ "${seg[1]}" != "." && "${base[1]}" == "." ]]; then
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
  if [ "$FZ_SUB_DIR_TRAVERSAL_ENABLED" -eq 1 ]; then
    if [ "$1" = "-c" ]; then
      shift
    fi
    l="$l
$(__fz_matched_subdir_list "$@")"
  fi
  echo "$l" | sed '/^$/d' | awk '!seen[$0]++'
}

_fz_complete() {
  setopt localoptions nonomatch
  local l matches fzf tokens

  l=$(_fz_list_generator $@)

  if [ -z "$l" ]; then
    return
  fi

  fzf=$(__fz_fzf_prog)

  if [ $(echo $l | wc -l) -eq 1 ]; then
    matches=${(q)l}
  else
    matches=$(echo $l \
        | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} \
          --reverse $FZF_DEFAULT_OPTS $FZF_COMPLETION_OPTS \
          --bind 'shift-tab:up,tab:down'" ${=fzf} \
        | while read -r item; do
      echo -n "${(q)item} "
    done)
  fi

  matches=${matches% }
  if [ -n "$matches" ]; then
    tokens=(${(z)LBUFFER})
    LBUFFER=${tokens[1]}
    if [[ "${tokens[2]}" == "-c" ]]; then
      LBUFFER="$LBUFFER ${tokens[2]}"
    fi
    LBUFFER="$LBUFFER $matches/"
  fi
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
}

fz-completion() {
  setopt localoptions noshwordsplit noksh_arrays noposixbuiltins
  local tokens cmd

  tokens=(${(z)LBUFFER})
  cmd=${tokens[1]}

  if [[ "$LBUFFER" =~ "^\ *fz$" ]]; then
    zle ${__fz_default_completion:-expand-or-complete}
  elif [[ "$LBUFFER" =~ "^\ *fz\ +-c$" ]]; then
    LBUFFER="$LBUFFER "
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
  elif [ "$cmd" = fz ]; then
    _fz_complete ${tokens[2,${#tokens}]/#\~/$HOME}
  else
    zle ${__fz_default_completion:-expand-or-complete}
  fi
}

[ -z "$__fz_default_completion" ] && {
  binding=$(bindkey '^I')
  # $binding[(s: :w)2]
  # The command substitution and following word splitting to determine the
  # default zle widget for ^I formerly only works if the IFS parameter contains
  # a space via $binding[(w)2]. Now it specifically splits at spaces, regardless
  # of IFS.
  [[ $binding =~ 'undefined-key' ]] || __fz_default_completion=$binding[(s: :w)2]
  unset binding
}

fz() {
  local rc
  if [ "$(_z -l "$@" 2>&1 | wc -l)" -gt 0 ]; then
    _z "$@"
  else
    if [ "$FZ_SUB_DIR_TRAVERSAL_ENABLED" -eq 1 ]; then
      err=$(cd "${@[-1]}" 2>&1)
      rc=$?
      if ! cd "${@[-1]}" 2>/dev/null; then
        echo ${err#* } >&2
        return $rc
      fi
    fi
  fi
}

zle -N fz-completion
bindkey '^I' fz-completion
