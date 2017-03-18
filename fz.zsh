#!/usr/bin/env zsh

[ -n "$FZ_JUMP_PROG" ] || FZ_JUMP_PROG=_z

__fz_fzf_complete() {
  [ -n "$TMUX_PANE" ] && [ "${FZF_TMUX:-0}" != 0 ] && [ ${LINES:-40} -gt 15 ] &&
    echo "fzf-tmux -d${FZF_TMUX_HEIGHT:-40%}" || echo "fzf"
}

_fz_default_list_generator() {
  # filter out line starting with common -> reverse order
  #   -> print second column only
  _z -l "$@" 2>&1 | sed '/^common/ d' | sed '1!G;h;$!d' | cut -b 12-
}

_fz_complete() {
  local list_generator="${fz_list_generator:-_fz_default_list_generator}"

  setopt localoptions nonomatch

  if [ -z "$("$list_generator" "$@")" ]; then
    return
  fi

  local matches
  local fzf="$(__fz_fzf_complete)"

  if [ "$("$list_generator" "$@" | wc -l)" -eq 1 ]; then
    matches=$("$list_generator" "$@")
  else
    matches=$("$list_generator" "$@" \
        | FZF_DEFAULT_OPTS="--height ${FZF_TMUX_HEIGHT:-40%} \
          --reverse $FZF_DEFAULT_OPTS $FZF_COMPLETION_OPTS \
          --bind 'shift-tab:up,tab:down'" ${=fzf} \
        | while read item; do
      echo -n "${(q)item} "
    done)
  fi
  matches=${matches% }
  if [ -n "$matches" ]; then
    LBUFFER="${LBUFFER% *} $matches"
  fi
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
}

fz-completion() {
  setopt localoptions noshwordsplit noksh_arrays noposixbuiltins

  local tokens=(${(z)LBUFFER})
  if [ ${#tokens} -lt 1 ]; then
    zle ${fz_default_completion:-expand-or-complete}
    return
  fi
  local cmd=${tokens[1]}

  if [[ "$LBUFFER" =~ "^\ *fz$" ]]; then
    zle ${fz_default_completion:-expand-or-complete}
  elif [[ "$LBUFFER" =~ "^\ +fz\ +-c$" ]]; then
    LBUFFER="$LBUFFER "
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
  elif [ $cmd = fz ]; then
    _fz_complete ${tokens[2,${#tokens}]/#\~/$HOME}
  else
    zle ${fz_default_completion:-expand-or-complete}
  fi
}

[ -z "$fz_default_completion" ] && {
  binding=$(bindkey '^I')
  [[ $binding =~ 'undefined-key' ]] || fz_default_completion=$binding[(s: :w)2]
  unset binding
}

fz() {
  "$FZ_JUMP_PROG" "$@" 2>&1
}

zle -N fz-completion
bindkey '^I' fz-completion
