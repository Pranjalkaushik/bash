# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

# Prompt: current path in muted night-sky-blue (guts #697a9a, matches dir color)
# followed by a soft green '$' (guts brand-green #a7d8b0).
if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[38;2;105;122;154m\]\w\[\033[0m\] \[\033[38;2;167;216;176m\]\$\[\033[0m\] '
else
    PS1='${debian_chroot:+($debian_chroot)}\w \$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
alias shell='docker exec -it app sh -c "(pip show flask-shell-ipython >/dev/null 2>&1 || pip install -q flask-shell-ipython) && flask --app mobygames/mobygames.py shell"'
# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export GPG_TTY=$(tty)
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"
. "$HOME/.cargo/env"
export PATH=$HOME/.npm-global/bin:$PATH
alias py="python3"

# --- Muted completion / ls colors, matched to guts.nvim (Berserk palette) ---
# Distinguishes commands (executables) from files at a glance. Used by both
# `ls` and readline's `colored-stats` tab-completion listing (see ~/.inputrc).
# Set *after* the dircolors block above so it isn't overwritten.
#   di dir=night_sky_blue  ex cmd/exec=griffith_purple  fi file=dragon_slayer_white
#   ln symlink=cliff_green  archives=eclipse_pink  media=campfire  missing=blood_red
export LS_COLORS="di=1;38;2;105;122;154:ln=38;2;122;131;124:ex=38;2;131;121;156:fi=38;2;159;158;153:or=38;2;111;46;42:mi=38;2;111;46;42:pi=38;2;130;136;160:so=38;2;131;121;156:bd=38;2;130;136;160:cd=38;2;130;136;160:su=38;2;153;126;149:sg=38;2;153;126;149:tw=1;38;2;105;122;154:ow=1;38;2;105;122;154:*.tar=38;2;153;126;149:*.tgz=38;2;153;126;149:*.zip=38;2;153;126;149:*.gz=38;2;153;126;149:*.bz2=38;2;153;126;149:*.xz=38;2;153;126;149:*.7z=38;2;153;126;149:*.jpg=38;2;172;127;123:*.jpeg=38;2;172;127;123:*.png=38;2;172;127;123:*.gif=38;2;172;127;123:*.svg=38;2;172;127;123:*.mp4=38;2;172;127;123:*.mp3=38;2;172;127;123:*.pdf=38;2;172;127;123"

# --- fzf: fuzzy interactive completion, themed to guts.nvim ------------------
export PATH="$HOME/.fzf/bin:$PATH"

# guts.nvim (Berserk) muted palette for the fzf popup.
export FZF_DEFAULT_OPTS="
  --height=40% --layout=reverse --border=rounded --info=inline
  --color=fg:#9f9e99,fg+:#e1ffe5,bg+:#161719,gutter:-1
  --color=hl:#a7d8b0,hl+:#a7d8b0,info:#697a9a,border:#554a62
  --color=prompt:#83799c,pointer:#a7d8b0,marker:#a7d8b0,spinner:#697a9a,header:#787487"

# fzf's own bindings: Ctrl-T (files), Ctrl-R (history), Alt-C (cd), **<Tab> trigger.
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --bash)"
fi
alias py="python3"
# lincheney/fzf-tab-completion: make the *plain Tab key* open the fzf picker.
# Must load after bash-completion and after `fzf --bash` above.
if [ -f "$HOME/.fzf-tab-completion/bash/fzf-bash-completion.sh" ]; then
  source "$HOME/.fzf-tab-completion/bash/fzf-bash-completion.sh"
  bind -x '"\t": fzf_bash_completion'
fi

# --- Fixed bottom-left git-branch status line (no tmux) ----------------------
# A terminal has no native status bar, so we fake one: reserve the bottom row
# via a scroll region (\e[1;Nr) so output never scrolls into it, then repaint
# the branch there on every prompt. Amber #d6b27a, matched to the prompt.
shopt -s checkwinsize            # keep $LINES/$COLUMNS current after each command

# Append "<symbol><count>" (colored) to the right-side string when count > 0.
# Uses the caller's $_sb_plain / $_sb_color locals (bash is dynamically scoped).
_sb_add() {  # $1 count  $2 symbol  $3 truecolor "R;G;B"
    (( $1 > 0 )) || return
    [[ -n $_sb_plain ]] && { _sb_plain+=' '; _sb_color+=' '; }
    _sb_plain+="$2$1"
    _sb_color+="\e[38;2;${3}m$2$1\e[0m"
}

_statusbar() {
    local branch rows cols line x y
    local staged=0 modified=0 untracked=0 conflict=0 tracked=0
    local _sb_plain='' _sb_color=''
    branch=$(git branch --show-current 2>/dev/null)
    rows=${LINES:-$(tput lines)}
    cols=${COLUMNS:-$(tput cols)}

    # One porcelain parse -> counts. XY: X=index/staged, Y=worktree.
    while IFS= read -r line; do
        x=${line:0:1}; y=${line:1:1}
        case "$x$y" in
            '??')                     ((untracked++)) ;;   # untracked
            DD|AU|UD|UA|DU|AA|UU)      ((conflict++))  ;;   # unmerged / conflict
            *) [[ $x != ' ' ]] && ((staged++))              # anything in the index
               [[ $y != ' ' ]] && ((modified++)) ;;         # worktree change
        esac
    done < <(git status --porcelain 2>/dev/null)

    # Total files git is tracking (committed + staged), not just changed ones.
    tracked=$(git ls-files 2>/dev/null | wc -l)

    _sb_add "$tracked"   '#' '150;160;180'   # slate  = tracked (total)
    _sb_add "$staged"    '+' '167;216;176'   # green  = staged
    _sb_add "$modified"  '~' '214;178;122'   # amber  = modified (unstaged)
    _sb_add "$untracked" '?' '105;122;154'   # blue   = untracked
    _sb_add "$conflict"  '!' '204;102;92'    # red    = merge conflict

    printf '\e7'                       # save cursor
    printf '\e[1;%dr' "$((rows - 1))"  # (re)reserve the bottom row
    printf '\e[%d;1H\e[K' "$rows"      # jump bottom-left, clear the row
    [ -n "$branch" ] && printf '\e[38;2;214;178;122m %s\e[0m' "$branch"
    if [ -n "$_sb_plain" ]; then       # right-align counts (1-col right margin)
        local col=$(( cols - ${#_sb_plain} ))
        (( col < 1 )) && col=1
        printf '\e[%d;%dH' "$rows" "$col"
        printf '%b' "$_sb_color"
    fi
    printf '\e8'                        # restore cursor
}

_statusbar_off() {                     # reset region + clear the row on exit
    local rows=${LINES:-$(tput lines)}
    printf '\e[r\e[%d;1H\e[K' "$rows"
}

case "$TERM" in
  xterm*|rxvt*|screen*|tmux*|vte*|alacritty|foot*)
    PROMPT_COMMAND="_statusbar${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
    trap '_statusbar' WINCH            # redraw + re-reserve on resize
    trap '_statusbar_off' EXIT
    # Ctrl-L clears the screen (and our region), so redraw after it.
    bind -x '"\C-l": clear; _statusbar' 2>/dev/null
    ;;
esac

# AI commit message on Tab (git commit -m "<TAB>)
# Resolve path relative to this file so it works wherever the repo lives.
_bashrc_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -f "$_bashrc_dir/.git_ai_commit.sh" ] && source "$_bashrc_dir/.git_ai_commit.sh"
unset _bashrc_dir
