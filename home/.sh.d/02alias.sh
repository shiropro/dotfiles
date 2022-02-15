# for long running commands: `sleep 10; alert`
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# reg_alias clipboard clipmenu -i -l 24 -p  -fn monospace-10:SemiBold -nb '#fdf2e4' -nf '#544b49' -sb '#544b49' -sf '#fdf2e4' -bd 0
reg_alias cpr rsync --archive -hhh --partial --info=stats1 --info=progress2 --modify-window=1
reg_alias cpu-core-n grep -c "^processor" /proc/cpuinfo
reg_alias fm start-fm
reg_alias fmxq start-fmxq
reg_alias gen-tmpfile 'mktemp ${XDG_CACHE_HOME:-/tmp}/tmpfile.XXXXXX'
reg_alias git-overwrite 'git fetch --all && git reset --hard origin/master && git pull'
reg_alias gitignore_io_list 'curl -sfL https://www.gitignore.io/api/list'
reg_alias mvr rsync --archive -hhh --partial --info=stats1 --info=progress2 --modify-window=1 --remove-source-files
reg_alias src omz reload
reg_alias sstp-update 'sudo ss-tproxy update-gfwlist && sudo ss-tproxy update-chnroute && systemctl is-active --quiet ss-tproxy && sudo systemctl restart ss-tproxy'
reg_alias trizenskip trizen -S --skipinteg
reg_alias update-vim "[ ! -d ~/.vim/bundle/Vundle.vim ] && git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim || vim +PluginInstall! +PluginClean +qall"
reg_alias yayskipall yay -S --mflags --skipinteg
reg_alias yayskipsums yay -S --mflags --skipchecksums
reg_alias uid-full 'echo $UID:$(id -g ${USER})'
# generate user name
alias gen-name='echo -e "Enter the domain of your account (google.com etc.):\c" ; read dname ; echo "username: $(echo kanocyan@"$dname" | md5sum -t - | cut -f1 -d " " - | md5sum -t - | cut -f1 -d " " -)"'
# ! DO NOT use read domain

# using Font Awesome
cmd_dmenu='dmenu_path | dmenu -b -f -i -l 18 -p  -fn monospace-9:Medium -bd 1 -w 618 -c -F -H ${XDG_CACHE_HOME:-~/.cache}/runmenu.history | ${SHELL:-/bin/sh} & $@'
if exist_cmd i3-dmenu-desktop; then
  reg_alias runmenu i3-dmenu-desktop --entry-type=name --dmenu="$cmd_dmenu"
elif exist_cmd j4-dmenu-desktop; then
  # 有汉字，故 明确指定中文字体 较好。符号使用 Font Awesome
  # cmd_dmenu='(cat ; (stest -flx $(echo $PATH | tr : " ") | sort -u)) | dmenu -b -f -i -l 18 -p   -fn NotoSans-10:SemiBold -bd 0 -y 0 -w 600 -c -F -H ${XDG_CACHE_HOME:-~/.cache}/appmenu.history'
  cmd_dmenu='(cat ; (stest -flx $(echo $PATH | tr : " ") | sort -u)) | dmenu $@'
  # j4-dmenu 因为 C++ 写的，所以？颜色里带 # 要加转义符前缀
  reg_alias runmenu j4-dmenu-desktop --display-binary --usage-log=${XDG_CACHE_HOME:-~/.cache}/j4_dmenu.history --dmenu="$cmd_dmenu"
elif exist_cmd dmenu; then
  reg_alias runmenu $cmd_dmenu
fi
unset cmd_dmenu
