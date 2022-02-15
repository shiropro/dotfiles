# Gentoo Prefix, 变量要最先导出，但命令最后执行
export shiropro_GENTOO_HOME=$HOME/gentoo

PATH=$HOME/.local/bin:$HOME/.local/usr/bin${PATH:+:$PATH}
[ -d $HOME/go/bin ] && PATH=$PATH:$HOME/go/bin GOPATH=$HOME/go
[ -d $HOME/.node_modules/bin ] && PATH=$PATH:$HOME/.node_modules/bin
[ -x $HOME/.jenv/bin/jenv ] && PATH=$PATH:$HOME/.jenv/bin
# added by https://github.com/rust-lang/rustup.rs
[ -d $HOME/.cargo/bin ] && PATH=$PATH:$HOME/.cargo/bin
[ -x $HOME/.local/share/junest/bin/junest ] && PATH=$HOME/.local/share/junest/bin:$PATH

# https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#post-installation-actions
if [ -d /usr/local/cuda ]; then
    export PATH=/usr/local/cuda/bin${PATH:+:${PATH}}
    if [ -d /usr/local/cuda/lib64 ]; then
        export LD_LIBRARY_PATH=/usr/local/cuda/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    elif [ -d /usr/local/cuda/lib ]; then
        export LD_LIBRARY_PATH=/usr/local/cuda/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    fi
fi

[ -d /opt/rocm ] && export PATH=${PATH:+${PATH}:}/opt/rocm/bin:/opt/rocm/rocprofiler/bin:/opt/rocm/opencl/bin

[ "$TERM" = linux ] && [ -s /usr/share/kbd/consolefonts/ter-powerline-v14b.psf.gz ] &&
    setfont /usr/share/kbd/consolefonts/ter-powerline-v14b.psf.gz

# let sh(1) know it's at home, despite /home being a symlink.
[ "$PWD" != "$HOME" ] && [ "$PWD" -ef "$HOME" ] && cd

# [for BSD] set ENV to a file invoked each time sh is started for interactive use.
# ENV=$HOME/.shrc; export ENV

# query terminal size, useful for serial lines
[ -x /usr/bin/resizewin ] && /usr/bin/resizewin -z

# export ARCHFLAGS='-arch x86_64' # compilation flags
export AUR_BUILD=$HOME/.aur_build # AUR makepkg defined

# FIXME: homebrew 会把自己插入所有 PATH 前，可能导致一些问题（如 python）
[ -x /home/linuxbrew/.linuxbrew/bin/brew ] && eval $(/home/linuxbrew/.linuxbrew/bin/brew shellenv) ||
    [ -x $HOME/.linuxbrew/bin/brew ] && eval $($HOME/.linuxbrew/bin/brew shellenv)

# export _JAVA_OPTIONS='-Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel'  # Java 反锯齿

# nvm, 如果直接加 rc 文件里每次 shell 启动都会 export ，会拖慢性能
export NVM_DIR=$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")

export RANGER_LOAD_DEFAULT_RC=FALSE # Ranger 防止额外加载 /etc/ranger/rc.conf

command -v ruby >/dev/null 2>&1 && ruby_path=$(ruby -e 'puts Gem.user_dir') && PATH=${ruby_path:+${ruby_path}/bin:}$PATH # Ruby

# FIXME: Rust ? 和 Gentoo Prefix 里的冲突？
[ "${SHELL#${shiropro_GENTOO_HOME}}" != "$SHELL" ] && return 0

for _f in $HOME/.profile.d/*.sh; do [ -s "$_f" ] && . $_f; done

# format: [ $(tty) = \/dev\/tty[0-9]* ] && do something
# FIXME: DO NOT USE exec fbterm!
# [ "$TERM" = linux ] && [ "$(tty)" = '/dev/tty5' ] && fbterm   # logout only when $? = 0

# launch X login TTY6 (only works when login without DM)
# systemctl -q is-active graphical.target && [ "$TERM" = linux ] &&  [ -n "$DISPLAY" ] && [ -n "$XDG_VTNR" ] && [ $XDG_VTNR -eq 6 ] && exec startx
systemctl -q is-active graphical.target && [ "$TERM" = linux ] && [ -n "$XDG_VTNR" ] && [ $XDG_VTNR -eq 6 ] && exec startx
