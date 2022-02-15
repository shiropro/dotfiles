" Environment {

    " Basics {
        set nocompatible        " Must be first line
        set background=dark     " Assume a dark background
    " }

    " Windows Compatible {
        " On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
        " across (heterogeneous) systems easier.
        if has('win32') || has('win64')
            set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after

            " Be nice and check for multi_byte even if the config requires
            " multi_byte support most of the time
            if has("multi_byte")
                " Windows cmd.exe still uses cp850. If Windows ever moved to
                " Powershell as the primary terminal, this would be utf-8
                set termencoding=cp850
                " Let Vim use utf-8 internally, because many scripts require this
                set encoding=utf-8
                setglobal fileencoding=utf-8
                " Windows has traditionally used cp1252, so it's probably wise to
                " fallback into cp1252 instead of eg. iso-8859-15.
                " Newer Windows files might contain utf-8 or utf-16 LE so we might
                " want to try them first.
                set fileencodings=ucs-bom,utf-8,utf-16le,cp1252,iso-8859-15
            endif
        endif
    " }

    " Setup Plugin Support {
        " The next three lines ensure that the $HOME/.vim/bundle/ system works
        filetype off
        set rtp+=$HOME/.vim/bundle/Vundle.vim
        call vundle#rc()
    " }

    " Add an UnPlugin command {
    function! UnPlugin(arg, ...)
        let bundle = vundle#config#init_bundle(a:arg, a:000)
        call filter(g:vundle#bundles, 'v:val["name_spec"] != "' . a:arg . '"')
    endfunction

    com! -nargs=+           UnPlugin
    \ call UnPlugin(<args>)
    " }

" }

" Plugins {

    " Deps {
        Plugin 'VundleVim/Vundle.vim'
        Plugin 'MarcWeber/vim-addon-mw-utils'
        Plugin 'tomtom/tlib_vim'
        if executable('ag')
            Plugin 'mileszs/ack.vim'
            let g:ackprg = 'ag --nogroup --nocolor --column --smart-case'
        elseif executable('ack-grep')
            let g:ackprg="ack-grep -H --nocolor --nogroup --column"
            Plugin 'mileszs/ack.vim'
        elseif executable('ack')
            Plugin 'mileszs/ack.vim'
        endif
    " }

    " In your .vimrc.before.local file
    " list only the plugin groups you will use
    if !exists('g:shiropro_bundle_groups')
        let g:shiropro_bundle_groups=['general', 'writing', 'neocomplete', 'programming', 'snipmate', 'python', 'php', 'ruby', 'go', 'javascript', 'html', 'misc',]
    endif

    " To override all the included bundles, add the following to your
    " .vimrc.bundles.local file:
    "   let g:override_shiropro_bundles = 1
    if !exists("g:override_shiropro_bundles")

    " General {
        if count(g:shiropro_bundle_groups, 'general')
            Plugin 'scrooloose/nerdtree'
            Plugin 'altercation/vim-colors-solarized'
            Plugin 'spf13/vim-colors'
            Plugin 'tpope/vim-surround'
            Plugin 'tpope/vim-repeat'
            Plugin 'rhysd/conflict-marker.vim'
            Plugin 'jiangmiao/auto-pairs'
            Plugin 'ctrlpvim/ctrlp.vim'
            Plugin 'tacahiroy/ctrlp-funky'
            Plugin 'terryma/vim-multiple-cursors'
            Plugin 'vim-scripts/sessionman.vim'
            Plugin 'matchit.zip'
            if (has("python") || has("python3")) && exists('g:shiropro_use_powerline') && !exists('g:shiropro_use_old_powerline')
                Plugin 'Lokaltog/powerline', {'rtp':'/powerline/bindings/vim'}
            elseif exists('g:shiropro_use_powerline') && exists('g:shiropro_use_old_powerline')
                Plugin 'Lokaltog/vim-powerline'
            else
                Plugin 'vim-airline/vim-airline'
                Plugin 'vim-airline/vim-airline-themes'
            endif
            Plugin 'powerline/fonts'
            Plugin 'bling/vim-bufferline'
            Plugin 'easymotion/vim-easymotion'
            Plugin 'jistr/vim-nerdtree-tabs'
            Plugin 'flazz/vim-colorschemes'
            Plugin 'mbbill/undotree'
            Plugin 'nathanaelkane/vim-indent-guides'
            if !exists('g:spf13_no_views')
                Plugin 'vim-scripts/restore_view.vim'
            endif
            Plugin 'mhinz/vim-signify'
            Plugin 'tpope/vim-abolish.git'
            Plugin 'osyo-manga/vim-over'
            Plugin 'kana/vim-textobj-user'
            Plugin 'kana/vim-textobj-indent'
            Plugin 'gcmt/wildfire.vim'
        endif
    " }

    " Writing {
        if count(g:shiropro_bundle_groups, 'writing')
            let s:fcitxsocketfile = '/tmp/fcitx-socket-' . $DISPLAY
            if !filewritable(s:fcitxsocketfile) "try again
                if strridx(s:fcitxsocketfile, '.') > 0
                    let s:fcitxsocketfile = strpart(s:fcitxsocketfile, 0,strridx(s:fcitxsocketfile, '.'))
                    Plugin 'lilydjwg/fcitx.vim'
                else
                    let s:fcitxsocketfile = s:fcitxsocketfile . '.0'
                    if filewritable(s:fcitxsocketfile)
                        Plugin 'lilydjwg/fcitx.vim'
                        finish
                    endif
                endif
            else
                Plugin 'lilydjwg/fcitx.vim'
            endif
            Plugin 'h-youhei/vim-ibus'
            Plugin 'reedes/vim-litecorrect'
            Plugin 'reedes/vim-textobj-sentence'
            Plugin 'reedes/vim-textobj-quote'
            Plugin 'reedes/vim-wordy'
        endif
    " }

    " General Programming {
        if count(g:shiropro_bundle_groups, 'programming')
            " Pick one of the checksyntax, jslint, or syntastic
            Plugin 'scrooloose/syntastic'
            Plugin 'tpope/vim-fugitive'
            Plugin 'mattn/webapi-vim'
            Plugin 'mattn/gist-vim'
            Plugin 'scrooloose/nerdcommenter'
            Plugin 'tpope/vim-commentary'
            Plugin 'godlygeek/tabular'
            Plugin 'luochen1990/rainbow'
            Plugin 'ryanoasis/vim-devicons'
            if executable('ctags')
                Plugin 'majutsushi/tagbar'
            endif
            " Plugin 'rizzatti/dash.vim' " Vim 整合使用 Dash.app，只支持 macOS
            Plugin 'KabbAmine/zeavim.vim' " 让 Vim 整合使用 Zeal
        endif
    " }

    " Snippets & AutoComplete {
        if count(g:shiropro_bundle_groups, 'snipmate')
            "Plugin 'garbas/vim-snipmate' "FIXME: The legacy SnipMate parser is deprecated. Please see :h SnipMate-deprecate.
            Plugin 'honza/vim-snippets'
            " Source support_function.vim to support vim-snippets.
            if filereadable(expand("$HOME/.vim/bundle/vim-snippets/snippets/support_functions.vim"))
                source $HOME/.vim/bundle/vim-snippets/snippets/support_functions.vim
            endif
        elseif count(g:shiropro_bundle_groups, 'youcompleteme')
            Plugin 'valloric/youcompleteme' " 自动补齐文字
            Plugin 'SirVer/ultisnips'
            Plugin 'honza/vim-snippets'
        elseif count(g:shiropro_bundle_groups, 'neocomplcache')
            Plugin 'Shougo/neocomplcache'
            Plugin 'Shougo/neosnippet'
            Plugin 'Shougo/neosnippet-snippets'
            Plugin 'honza/vim-snippets'
        elseif count(g:shiropro_bundle_groups, 'neocomplete')
            Plugin 'Shougo/neocomplete.vim.git'
            Plugin 'Shougo/neosnippet'
            Plugin 'Shougo/neosnippet-snippets'
            Plugin 'honza/vim-snippets'
        endif
    " }

    " PHP {
        if count(g:shiropro_bundle_groups, 'php')
            Plugin 'spf13/PIV'
            Plugin 'arnaud-lb/vim-php-namespace'
            Plugin 'beyondwords/vim-twig'
        endif
    " }

    " Python {
        if count(g:shiropro_bundle_groups, 'python')
            " Pick either python-mode or pyflakes & pydoc
            Plugin 'klen/python-mode'
            Plugin 'yssource/python.vim'
            Plugin 'python_match.vim'
            Plugin 'pythoncomplete'
        endif
    " }

    " Javascript {
        if count(g:shiropro_bundle_groups, 'javascript')
            Plugin 'elzr/vim-json'
            Plugin 'groenewege/vim-less'
            Plugin 'pangloss/vim-javascript'
            Plugin 'briancollins/vim-jst'
            Plugin 'kchmck/vim-coffee-script'
        endif
    " }

    " Scala {
        if count(g:shiropro_bundle_groups, 'scala')
            Plugin 'derekwyatt/vim-scala'
            Plugin 'derekwyatt/vim-sbt'
            Plugin 'xptemplate'
        endif
    " }

    " Haskell {
        if count(g:shiropro_bundle_groups, 'haskell')
            Plugin 'travitch/hasksyn'
            Plugin 'dag/vim2hs'
            Plugin 'Twinside/vim-haskellConceal'
            Plugin 'Twinside/vim-haskellFold'
            Plugin 'lukerandall/haskellmode-vim'
            Plugin 'eagletmt/neco-ghc'
            Plugin 'eagletmt/ghcmod-vim'
            Plugin 'Shougo/vimproc.vim'
            Plugin 'adinapoli/cumino'
            Plugin 'bitc/vim-hdevtools'
        endif
    " }

    " HTML {
        if count(g:shiropro_bundle_groups, 'html')
            Plugin 'heracek/HTML-AutoCloseTag'
            Plugin 'hail2u/vim-css3-syntax'
            Plugin 'gorodinskiy/vim-coloresque'
            Plugin 'tpope/vim-haml'
            Plugin 'mattn/emmet-vim'
        endif
    " }

    " Ruby {
        if count(g:shiropro_bundle_groups, 'ruby')
            Plugin 'tpope/vim-rails'
            let g:rubycomplete_buffer_loading = 1
            "let g:rubycomplete_classes_in_global = 1
            "let g:rubycomplete_rails = 1
        endif
    " }

    " Puppet {
        if count(g:shiropro_bundle_groups, 'puppet')
            Plugin 'rodjek/vim-puppet'
        endif
    " }

    " Go Lang {
        if count(g:shiropro_bundle_groups, 'go')
            "Plugin 'Blackrush/vim-gocode'
            "Plugin 'fatih/vim-go' " FIXME: Some old version of vim/neovim does not
                                   "        support vim-go
        endif
    " }

    " Elixir {
        if count(g:shiropro_bundle_groups, 'elixir')
            Plugin 'elixir-lang/vim-elixir'
            Plugin 'carlosgaldino/elixir-snippets'
            Plugin 'mattreduce/vim-mix'
        endif
    " }

    " Misc {
        if count(g:shiropro_bundle_groups, 'misc')
            Plugin 'pearofducks/ansible-vim' " Ansible syntax highlighting
            Plugin 'rust-lang/rust.vim'
            Plugin 'tpope/vim-markdown'
            Plugin 'spf13/vim-preview'
            Plugin 'tpope/vim-cucumber'
            Plugin 'cespare/vim-toml'
            Plugin 'quentindecock/vim-cucumber-align-pipes'
            Plugin 'saltstack/salt-vim'
            Plugin 'junegunn/fzf'
            Plugin 'tpope/vim-obsession'
            Plugin 'francoiscabrol/ranger.vim'
            " Plugin 'ActivityWatch/aw-watcher-vim'
        endif
    " }

    endif

" }

" Use fork bundles config if available {
    if filereadable(expand("$HOME/.vimrc.bundles.fork"))
        source $HOME/.vimrc.bundles.fork
    endif
" }

" Use local bundles config if available {
    if filereadable(expand("$HOME/.vimrc.bundles.local"))
        source $HOME/.vimrc.bundles.local
    endif
" }
