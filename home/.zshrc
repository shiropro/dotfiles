[[ $- != *i* ]] && return # If not running interactively, do nothing

[ "${TERM#*fbterm}" = "$TERM" ] && [ "${TERM#*screen}" = "$TERM" ] &&
    command -v neofetch > /dev/null 2>&1 && neofetch # neofetch + fbterm = 乱码

# enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  . "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH=~/.oh-my-zsh/

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  bower       # completion for Bower and a few useful aliases for common Bower commands
  colored-man-pages # make man page colorful!
  colorize    # 应该是由于 powerlevel 的缘故，用处不大
  command-not-found # Arch 下用处不大
  compleat    # looks for compleat and loads completion
  copybuffer  # <Ctrl+O> 复制当前命令行输入的内容到系统剪贴板
  copyfile
  cp
  cpanm
  debian
  dirhistory  # keyboard shortcuts for navigating directory history and hierarchy
  dirpersist
  docker
  docker-compose
  docker-machine
  doctl
  extract
  fancy-ctrl-z # Ctrl+Z 可以把当前进程放到后台
  firewalld
  # frontend-search # 搜索前端开发文档的系列命令
  gem
  # globalias # 自动展开命令行中所有变量、别名
  # gnu-utils # 在 BSD 上包装出 GNU 的一些工具
  golang # completion and aliases for Go
  # gpg-agent # enables GPG's gpg-agent if it is not running.
  httpie
  jhbuild
  jsontools
  kitchen
  kubectl
  last-working-dir
  lein
  lol
  magic-enter
  man
  mosh
  nmap
  percol
  perl
  perms
  pip # completion for pip
  pipenv
  pyenv
  pylint
  python
  rust
  themes
  tmux
  vagrant
  z
  zsh-navigation-tools
)

ZSH_CACHE_DIR=$HOME/.cache/oh-my-zsh

[ ! -d $ZSH_CACHE_DIR ] && mkdir $ZSH_CACHE_DIR

# - user defined ---------------------------------------------------------------

for _f in ~/.sh.d/*.sh; do [ -s "$_f" ] && emulate sh -c ". \"$_f\""; done

[ "$TERM" = linux ] && ZSH_THEME=xiong-chiamiov-plus
[ "${TERM#*fbterm}" != "$TERM" ] || [ "${TERM#*yaft}" != "$TERM" ] || [ "$LANG" = 'C' ] && ZSH_THEME=agnoster

# Homebrew installation note
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ] || [ -x ~/.linuxbrew/bin/brew ]; then
  if ((!${fpath[(I) / usr / local / share / zsh / site - functions]})); then
    FPATH=/usr/local/share/zsh/site-functions:$FPATH
  fi
fi

# setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS

MAGIC_ENTER_GIT_COMMAND='git status -u .'
# MAGIC_ENTER_OTHER_COMMAND='ls -h .'
MAGIC_ENTER_OTHER_COMMAND='ls -lh .'

ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_UNICODE=true # unicode support

[ -s "$ZSH/oh-my-zsh.sh" ] && . $ZSH/oh-my-zsh.sh

[ -s $ZSH/custom/themes/powerlevel10k/powerlevel10k.zsh-theme ] &&
  . $ZSH/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

# to reconfigure: run `p10k configure` or edit ~/.p10k.zsh
[ -s ~/.p10k.zsh ] &&
  sed -i 's|╭─|┌─|g; s|╰─|└ >|g; s|─╮|─┐|g; s|─╯| ┘|g' ~/.p10k.zsh && . ~/.p10k.zsh

if [ -d /usr/share/zsh/plugins ]; then
  root_plugin=/usr/share/zsh/plugins  # Arch
else
  root_plugin=/usr/share/zsh          # Ubuntu or maybe other Linux
fi

[ -s "$root_plugin/zsh-autosuggestions/zsh-autosuggestions.zsh" ] &&
  . "$root_plugin/zsh-autosuggestions/zsh-autosuggestions.zsh"

# https://github.com/zsh-users/zsh-syntax-highlighting#why-must-zsh-syntax-highlightingzsh-be-sourced-at-the-end-of-the-zshrc-file
[ -s "$root_plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] &&
  . "$root_plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# https://github.com/zsh-users/zsh-history-substring-search#usage
# If you want to use zsh-syntax-highlighting along with this script,
# then make sure that you load it before you load this script:
if [ -s "$root_plugin/zsh-history-substring-search/zsh-history-substring-search.zsh" ]; then
  . "$root_plugin/zsh-history-substring-search/zsh-history-substring-search.zsh"
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey -M vicmd 'k' history-substring-search-up
  bindkey -M vicmd 'j' history-substring-search-down
fi

if [ ! -x $ZSH/oh-my-zsh.sh ]; then

  [ "${TERM#*termite}" != "${TERM}" ] && [ -s /etc/profile.d/vte.sh ] &&
    . /etc/profile.d/vte.sh && __vte_osc7

  [ -s ~/.fzf.zsh ] && . ~/.fzf.zsh

  command -v fasd > /dev/null 2>&1 && eval "$(fasd --init auto)"
  command -v jenv >/dev/null 2>&1 && eval "$(jenv init -)"

  # Change the prompt when you open a shell from inside ranger
  [ -n "$RANGER_LEVEL" ] && PS1="$PS1"'(in ranger) '
fi

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

[[ -s ~/.zshrc.d/*.zsh ]] && for _f in ~/.zshrc.d/*.zsh; do [ -s "$_f" ] && . "$_f"; done
