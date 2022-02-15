#!/bin/sh
# -----------------------------------------------------------------------------
# xinit 可用作简易 Display Manager，管理多个不同的 Window Mmangers/Desktop Environments
# 当然也可以不用 WM 直接 xinit 运行 GUI 应用
# 视情况 DM 会 source xprofile，比如 xinit 会，但 gdm 不会

# xinit 和 startx 可以后面带参数，不带就默认用这个 $HOME/.xinitrc 中的处理方式

# $HOME/.xinitrc is handy to run programs depending on X and set environment variables on X server startup.
# If it is present in a user's home directory, startx and xinit execute it.
# Otherwise startx will run the default /etc/X11/xinit/xinitrc.
#
# Note: Xinit has its own default behaviour instead of executing the file.
# See xinit(1) for details.
#
# This default xinitrc will start a basic environment with Twm,
# xorg-xclock and Xterm (assuming that the necessary packages are installed).
# Therefore, to start a different window manager or desktop environment,
# first create a copy of the default xinitrc in your home directory:
#
#   cp /etc/X11/xinit/xinitrc $HOME/.xinitrc
#
# Then edit the file and replace the default programs with desired commands.
# Remember that lines following a command using exec would be IGNORED.
# For example, to start xscreensaver in the background and then start openbox, use the following:
#
# $HOME/.xinitrc
# ...
# xscreensaver &
# exec openbox-session
#
# Note: At the very least, ensure that the last if block in /etc/X11/xinit/xinitrc
# is PRESENT in your $HOME/.xinitrc file to ensure that the scripts in
# /etc/X11/xinit/xinitrc.d are sourced.
#
# Long-running programs started before the window manager,
# such as a screensaver and wallpaper application,
# must either fork themselves or be run in the background by appending an & sign.
# Otherwise, the script would halt and wait for each program to exit before executing the window manager or desktop environment.
#
# 使用 exec 作为前缀会替换当前的进程，这样进程进入后台时 X 不会退出。
# Note that some programs should instead not be forked, to avoid race bugs,
# as is the case of xrdb.
#
# Prepending(前缀) exec will replace the script process with the window manager process,
# so that X does not exit even if this process forks to the background.
#

# 使用

# - 普通用户身份启动 Xorg 服务器：startx
# - Or if #xserverrc is configured: xinit -- :1
# Note: xinit 无法在其它 X server 启动时处理多个显示，要使用多显示，
# 需要通过 -- :display_number 指定，display_number 是 1 或更高的数值
#
# - 退出 X 一般由 WM 提供注销功能，如果 WM 没这功能，
#   可以用 pkill -15 Xorg 杀死所有运行的 X 实例
#   或者 pkill -15 -t tty"$XDG_VTNR" Xorg 杀死当前 tty 中的 X 示例
#
# 参见 signal(7)
#
# [ -d /etc/X11/xinit/xinitrc.d ] && for _f in /etc/X11/xinit/xinitrc.d/?*.sh; do
#     [ -x "$_f" ] && . "$_f" # Arch Linux
# done
# [ -s /etc/X11/xinit/xinitrc.common ] && . /etc/X11/xinit/xinitrc.common # OpenSUSE
#
# ! 如想用 $1 变量，而不是只写一个 exec session_name
# ! 那么必须 xinit session_name 或 startx $HOME/.xinitrc session_name
# ! 绝不可 startx session_name


# GDM 特有的 $HOME/.xprofile 是会话启动脚本 startup 的一部分，
# 类似于 Debian 系特有的 .xsessionrc 文件，因此不是所有 DM 都会读取：
#
# 会自动 source xprofile 的（这些 DM 一般会绕过 $HOME/.xinitrc 和 $HOME/.xsession）
#   - GDM - /etc/gdm/Xsession
#   - KDM - /usr/share/config/kdm/Xsession
#   - LightDM - /etc/lightdm/Xsession
#   - LXDM - /etc/lxdm/Xsession
# with modern display managers that give the user a choice of session type,
# you usually need to pick “custom” for .xsession to run.
#
# 而使用 $HOME/.xinitrc (or sometimes $HOME/.xsession or both) 的 DM，如:
#   - startx
#   - xinit
#   - XDM
# 可以在 $HOME/.xinitrc (or sometimes $HOME/.xsession or both) 中手动添加 . $HOME/.xprofile
# -----------------------------------------------------------------------------

exist_cmd(){
    command -v $* > /dev/null 2>&1
}

auto_start() {
    exist_cmd $@ && $@ &
}

start_fcitx() {
    [ -z "$my_ime" ] && my_ime=fcitx || return 1
    exist_cmd fcitx-autostart && fcitx-autostart || fcitx -d
}

start_ibus() {
    [ -z "$my_ime" ] && my_ime=ibus || return 1
    [ -s /usr/lib/ibus/ibus-ui-gtk3 ] && ibus-daemon -drx --panel /usr/lib/ibus/ibus-ui-gtk3 || ibus-daemon -drx
}

# xrdb 命令放到后台运行可能导致比 xrdb 晚启动的程序在资源加载完成前查找资源，产生问题。
[ -s /etc/X11/xinit/.Xresources ] && xrdb /etc/X11/xinit/.Xresources
[ -s $HOME/.Xresources ] && xrdb -merge -I$HOME $HOME/.Xresources # ! -merge 选项导致配色覆盖？
[ -s $HOME/.Xresources.d/$(uname -n) ] && xrdb -merge $HOME/.Xresources.d/$(uname -n)

unset my_ime
start_fcitx
export XIM_PROGRAM="$my_ime"
export XIM="$my_ime"
export XIM_ARGS="-d"
export GTK_IM_MODULE="$my_ime"
export QT4_IM_MODULE="$my_ime"
export QT_IM_MODULE="$my_ime"
export ECORE_IMF_MODULE="xim"
export XMODIFIERS="@im=$my_ime"

auto_start slstatus
auto_start copyq
auto_start pasystray
auto_start tilda
auto_start nm-applet

pcmanfm -d &

/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &

# set dwm bar by shell script:
# while true; do
#     xsetroot -name "$(date)"
#     sleep 1s
# done &
# tint2 &

exist_cmd picom && picom -b

# Activate asking for ssh passphrase
# if test -S "$SSH_AUTH_SOCK" -a -x "$SSH_ASKPASS"; then
#       ssh-add < /dev/null
# fi

# multi-head: `xrandr --current` 查看当前显示器状况
# xrandr --output DP-1 --primary --mode 1920x1080 --rate 144 --rotate normal
# xrandr --output eDP1 --scale 1.5x1.5

# export GDK_SCALE=2
# export GDK_DPI_SCALE=0.5
# export QT_SCALE_FACTOR=

# gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "[{'Gdk/WindowScalingFactor', <2>}]"
# gsettings set org.gnome.desktop.interface scaling-factor 2
# gsettings set org.gnome.settings-daemon.plugins.xsettings overrides "{'Xft/DPI': <203600>}"
# gsettings set org.gnome.desktop.interface text-scaling-factor 2

enable_log=n
session=${1:-dwm}

case ${session} in
*i3 | *i3wm)
    if [ "$enable_log" = y ]; then
        [ ! -d $HOME/log/i3 ] && mkdir -p $HOME/log/i3
        _f_log=$HOME/log/i3/$(date +'%F-%k-%M-%S').log
        printf %s "\
------------------------------------------------------------------------------
$USER started i3 at $(date)
$(i3 --moreversion 2>&- || i3 --version)
------------------------------------------------------------------------------

" >>"$_f_log"
        $HOME/.config/i3/script/i3deploy &&
            exec i3 -V >>"$_f_log" 2>&1
        # - Debug mode:
        # exec i3 -V -d all >> "$_f_log"
        unset _f_log
    else
        exec i3
    fi
    ;;
*dwm)
    # https://wiki.archlinux.org/title/dwm#Fixing_misbehaving_Java_applications
    wmname LG3D # https://tools.suckless.org/x/wmname
    if [ "$enable_log" = y ]; then
        [ ! -d $HOME/log/dwm ] && mkdir -p $HOME/log/dwm
        _f_log=$HOME/log/dwm/$(date +'%F-%k-%M-%S').log
        printf %s "\
------------------------------------------------------------------------------
$USER started $(dwm -v) at $(date)
------------------------------------------------------------------------------

" >>"$_f_log"
        exec dwm >>"$_f_log" 2>&1
        unset _f_log
    else
        exec dwm
    fi
    ;;
# special for twm
*twm)
    xsetroot -solid darkslateblue
    exec twm ${1+"$@"}
    ;;
*)
    "$@" # unknown session, try to run it as command
    ;;
esac

# _fallback="xterm -ls -T Failsafe -geometry 80x32-0-0"

# trap "exec $_fallback" EXIT SIGHUP SIGINT SIGPIPE SIGTERM SIGIO

# if [ -n "$BASH_VERSION" ]; then
#     # - Some bash (1 and 2) settings to avoid trouble on a failed program call.
#     set +e > /dev/null 2>&1
#     set +u > /dev/null 2>&1
#     set +o posix  > /dev/null 2>&1
#     if type shopt > /dev/null 2>&1 ; then
#         shopt -s execfail
#     else
#         no_exit_on_failed_exec=1
#     fi
# fi
