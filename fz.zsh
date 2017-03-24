#!/usr/bin/env zsh

SCRIPT_DIR=$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)

source "$SCRIPT_DIR/fz.sh"

_fz_list_generator() {
  __fz_matched_history_list $@
  if [ "$FZ_SUB_DIR_TRAVERSAL_ENABLED" -eq 1 ]; then
    __fz_matched_subdir_list $@
  fi
}

_fz_complete() {
  setopt localoptions nonomatch

  local l=$(_fz_list_generator $@)

  if [ -z "$l" ]; then
    return
  fi

  local matches
  local fzf=$(__fz_fzf_prog)

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
    local tokens=(${(z)LBUFFER})
    LBUFFER=${tokens[1]}
    if [[ "${tokens[2]}" == "-c" ]]; then
      LBUFFER="$LBUFFER ${tokens[2]}"
    fi
    LBUFFER="$LBUFFER $matches"
  fi
  zle redisplay
  typeset -f zle-line-init >/dev/null && zle zle-line-init
}

fz-completion() {
  setopt localoptions noshwordsplit noksh_arrays noposixbuiltins

  local tokens=(${(z)LBUFFER})
  local cmd=${tokens[1]}

  if [[ "$LBUFFER" =~ "^\ *fz$" ]]; then
    zle ${__fz_default_completion:-expand-or-complete}
  elif [[ "$LBUFFER" =~ "^\ +fz\ +-c$" ]]; then
    LBUFFER="$LBUFFER "
    zle redisplay
    typeset -f zle-line-init >/dev/null && zle zle-line-init
  elif [ $cmd = fz ]; then
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
  if [ "$(__fz_z_list "$@" 2>/dev/null | wc -l)" -gt 0 ]; then
    _z "$@"
  else
    if [ "$FZ_SUB_DIR_TRAVERSAL_ENABLED" -eq 1 ]; then
      err=$(cd "${@[-1]}" 2>&1)
      local rc=$?
      if ! cd "${@[-1]}" 2>/dev/null; then
        echo ${err#* } >&2
        return $rc
      fi
    fi
  fi
}

zle -N fz-completion
bindkey '^I' fz-completion
