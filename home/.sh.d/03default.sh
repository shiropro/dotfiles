if [ "$TERM" = linux ] && command -v yaft > /dev/null 2>&1; then
  command -v idump > /dev/null 2>&1 && [ -s "$XDG_DATA_HOME/backgrounds/console" ] &&
    alias yaft="idump $XDG_DATA_HOME/backgrounds/console && \
        tput civis && FRAMEBUFFER=/dev/fb0 YAFT=wall yaft"
fi

# 自动识别 Gentoo Prefix，然后选择是 Gentoo 里的 root 好呢还是 HOME 下面好呢
# 1. Gentoo ROOT 中的好处是，Gentoo 编译如果用到 Perl 模块不会调用错，坏处是
#    鲁棒性很差，如果 Gentoo Prefix 没启动起来，那么所有 Perl 模块都没法用
# 2. 自己 export 的好处和坏处自然和上面相反，并且自己 export 所有模块都只要
#    装一次即可
#
# 但 cpanm 安装模块有一个特性，所有 Perl 模块前面的解释器部分都是 perl
# 二进制程序的绝对地址，即不同环境下安装的模块之间并不能通用，也就是
# 方法 2 失效或没有意义
#
# 因此，通过这个办法自动区分当前是 Gentoo Prefix 还是普通环境:
[ "${SHELL#${shiropro_GENTOO_HOME}}" != "$SHELL" ] && return 0

# ? 放在 profile 或这里
# 如果使用 "~/perl5" 里的 perl 模块，即安装在用户家目录下的 perl 模块
# 取代系统目录中的，那么取消这个文件隐藏或者取消下面的相关注释
# - Automatically added by command "cpan App::cpanminus"
# if [ -d ~/perl5 ]; then
#   export PATH=~/perl5/bin${PATH:+:${PATH}}
#   export PERL5LIB=~/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}
#   export PERL_LOCAL_LIB_ROOT=~/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}
#   export PERL_MB_OPT="--install_base \"$HOME/perl5\""
#   export PERL_MM_OPT="INSTALL_BASE=$HOME/perl5"
# fi

# 每次合成器启动的情况下启动的 xterm 会自动透明，以这种方式启动 shell 以外的程序，终端不会透明
command -v transset-df > /dev/null 2>&1 && [ -n "$XTERM_VERSION" ] && transset-df --id "$WINDOWID" >/dev/null
