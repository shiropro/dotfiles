# - used by script -------------------------------------------------------------

exist_cmd(){
  command -v $* > /dev/null 2>&1
}

reg_alias() {
  local entry=$1 && shift && local cmd="$*"
  ! exist_cmd $entry && eval 'alias '"$entry"=\'"$cmd"\'
}

# - used by shell --------------------------------------------------------------

font-search(){
  fc-list | grep "$*" | cut -d: -f2-3
}

ls-subdir() { # list subfolder of given dir $* as an array
    ls -F "${*:-$PWD}" | grep -E '/$' | sed -E 's/\/$//g'
}

check-array() { # check the value of array named "$*"
    local arr_name=$*
    eval '
    if [ ! "${'${arr_name}'}" ]; then
        printf "'${arr_name}' is empty.\n"
    else
        i=0
        for index in $(seq 0 ${#'${arr_name}'[@]}); do
            printf "'${arr_name}'[$((i++))]: ${'${arr_name}'[${index}]}\n"
        done
    fi
'
}

debug-array() { # print details of array named "$*"
    local arr_name=$*
    printf "Array Name: %s\n" "${arr_name}"
    eval '
    printf "Element Num: %s\n" "${#'${arr_name}'[@]}"
    printf "%s[@]: %s\n"  "'${arr_name}'" "${'${arr_name}'[@]}"
    printf "%s[*]: %s\n"  "'${arr_name}'" "${'${arr_name}'[*]}"
    printf "\n"
    if [ ! "${'${arr_name}'}" ]; then
        printf "%s is empty\n" "'${arr_name}'"
    else
        i=1
        for element in ${'${arr_name}'[@]}; do
            printf "Element $((i++)): ${element}\n"
        done; printf "\n"
        i=0
        for index in $(seq 0 ${#'${arr_name}'[@]}); do
            printf "%s[$((i++))]: ${'${arr_name}'[${index}]}\n" "'${arr_name}'"
        done
    fi
'
}

dl() { # a smarter downloader wrapper
    [ $# -ne 1 ] && [ $# -ne 2 ] && [ $# -ne 3 ] &&
    printf "usage: dl (url) [<destination path>] [<saved file name>]\n" && return 1
    ! command -v nproc >/dev/null 2>&1 && printf "nproc command not found, maybe you are using BSD?\n" && exit 1

    local url=$1; local dest=${2:-$PWD}; local name=$3; local concurrent_n=$(nproc)
    if [ $concurrent_n -le 5 ]; then concurrent_n=$((concurrent_n-1))
    elif [ $concurrent_n -lt 12 ]; then concurrent_n=5
    else concurrent_n=$((concurrent_n/2))
    fi
    if command -v aria2c >/dev/null 2>&1; then
      aria2c  --max-concurrent-downloads=$concurrent_n \
              --split=$([ $concurrent_n -lt 8 ] && echo $concurrent_n || echo 8) \
              --dir="$dest" --out="$name" --no-conf=true ${http_proxy:+--all-proxy=$http_proxy} "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget --continue --timestamping --directory-prefix="$dest" --output-document="$name" "$url"
    else
        printf "please install aria2 or wget first!" && return 1
    fi
    return 0
}

rsync-sys(){ # backup/recovery system with one command
  local act=$1; [ $? -gt 0 ] && shift
  local opts='--archive -hhh --acls --xattrs --verbose --exclude={"*~","*/log","*/lock","*/syslog\.*","/dev/*","/proc/*","/sys/*","/tmp/*","*/tmp","/run/*","*/run","/mnt/*","/media/*","/lost+found","*swapfile"}'
  case $act in
  bak|backup)
    local mnt_point=$(mktemp)
    sudo mount "$*" $mnt_point
    sudo rsync $opts /* $mnt_point
    sudo umount $mnt_point && rm -rf $mnt_point
  ;;
  rec|recovery|restore)
    local mnt_point=$(mktemp)
    sudo mount "$*" $mnt_point
    sudo rsync $opts --exclude /etc/fstab $mnt_point / && sudo genfstab /
    sudo umount $mnt_point && rm -rf $mnt_point
  ;;
  *)
    printf "
Rsync system tools

  bak   Backup system
  rec   Recovery system\n"
  ;;
  esac
}

dl-bing-wallpaper(){
  # market options: en-US, zh-CN, ja-JP, en-AU, en-UK, de-DE, en-NZ
  # resolution options: 1366×768, 1920×1080, 1920×1200
  local market="en-US"
  local resolution="1920x1080"
  local fname="bing_wallpaper.jpg"
  local fname_png="bing_wallpaper.png"
  local url=($(curl -s 'http://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1&mkt='"$_market" |
      python -c "import json,sys;obj=json.load(sys.stdin);print(obj['images'][0]['urlbase']);"))

  curl -so ~/$fname "http://www.bing.com/${url}_${resolution}.jpg"
  convert ~/$fname ~/$fname_png
  rm -f ~/$fname
}

clean-home(){
  local check_list=(
    ~/.adobe              # Flash crap
    ~/.asy/
    ~/.bazaar/           # bzr insists on creating files holding default values
    ~/.bzr.log
    ~/.cache/ibus/                # ibus cache
    ~/.cache/thumbnails/neofetch/ # neofetch cache
    ~/.cmake/
    ~/.config/enchant
    ~/.dbus
    ~/.distlib/          # contains another empty dir, don't know which software creates it
    ~/.dropbox-dist
    ~/.esd_auth
    ~/.FRD/links.txt     # FRD
    ~/.FRD/log/app.log   # FRD
    ~/.gconf
    ~/.gconfd
    ~/.gnome/
    ~/.gstreamer-0.10
    ~/.java/
    ~/.jssc/
    ~/.local/share/gegl-0.2
    ~/.local/share/recently-used.xbel
    ~/.macromedia         # Flash crap
    ~/.npm/              # npm cache
    ~/.nv/
    ~/.objectdb          # FRD
    ~/.oracle_jre_usage/
    ~/.parallel
    ~/.pulse
    ~/.pylint.d/
    ~/.QtWebEngineProcess/
    ~/.qute_test/
    ~/.qutebrowser/      # created empty, only with webengine backend
    ~/.recently-used
    ~/.spicec            # contains only log file; unconfigurable
    ~/.subversion/
    ~/.texlive/
    ~/.thumbnails
    ~/.tox/              # cache directory for tox
    ~/.viminfo   # configured to be moved to ~/.cache/vim/viminfo, but it is still sometimes created
    ~/.w3m/
    ~/.xsession-errors.old
    ~/ca2                # WTF?
    ~/ca2~               # WTF?
    ~/nvvp_workspace/    # created empty even when the path is set differently in nvvp
    ~/unison.log
  )
  local confirm_list=()

  for entry_i in $check_list; do
    [ -e "$entry_i" ] && echo "found: $entry_i" && confirm_list=($confirm_list $entry_i)
  done

  [ ${#confirm_list} -eq 0 ] && echo "good! no shitty entry found" && return 0

  printf "remove all?[y/N]:" && read ans

  [ "$ans" = "y" ] || [ "$ans" = "yes" ] &&
    for entry_i in $confirm_list; do rm -rf "$entry_i"; done &&
    echo "all cleaned" && return 0

  echo "abort by user" && return 1
}

gitignore_io(){
  curl -fLw '\n' https://www.gitignore.io/api/$(echo $* | sed s/\ /,/g)
}

exist_cmd i3-msg &&
i3-ws-icon() {
  local count=0
  i3-msg -t get_workspaces | tr ',' '\n' | sed -nr 's/"name":"([^"]+)"/\1/p' | while read -r name; do
    printf 'ws-icon-%i = "%s;<insert-icon-here>"\n' $((count++)) $name
  done
}

dockerls-container(){
  docker container ls --filter "name=$*" --format "docker container named pattern \"$*\" with id {{.ID}} found"
}

dockerls-image(){
  docker image ls --format "docker image named \"$*\" with id {{.ID}} found" $*
}