set fileencodings=utf-8,euc-jp,sjis,cp932
set fileformats=unix,dos,mac
set number
set showcmd
set backspace=indent,eol,start
set expandtab " タブ入力を複数の空白入力に置き換える
set shiftwidth=4 " 自動インデントでずれる幅
set softtabstop=4 " 連続した空白に対してカーソルが動く幅
set autoindent " 改行時に前の行のインデントを継続する
set smartindent " 改行時に末尾に合わせて次の行のインデントを増減する
set cinwords=if,else,while,do,for,switch,elif,try,except,finally,def,class
syntax enable
set background=dark
" colorscheme solarized
set t_Co=256
set mouse=a
set tabstop=4

let g:python_host_prog = '~/.pyenv/versions/neovim2/bin/python'
let g:python3_host_prog = '~/.pyenv/versions/neovim3/bin/python'

if &compatible
  set nocompatible
endif

let s:dein_dir = expand('~/.config/nvim/dein')

let s:dein_repo_dir = s:dein_dir . '/repos/github.com/Shougo/dein.vim'

" dein.vimが存在していない場合はgithubからclone
if &runtimepath !~# '/dein.vim'
  if !isdirectory(s:dein_repo_dir)
    execute '!git clone https://github.com/Shougo/dein.vim' s:dein_repo_dir
  endif
  execute 'set runtimepath^=' . fnamemodify(s:dein_repo_dir, ':p')
endif

if dein#load_state(s:dein_dir)
  call dein#begin(s:dein_dir)

  let s:toml_dir = expand('~/.config/nvim')

  call dein#load_toml(s:toml_dir . '/dein.toml', {'lazy': 0})

  call dein#load_toml(s:toml_dir . '/dein_lazy.toml', {'lazy': 1})

  call dein#end()
  call dein#save_state()
endif

" filetype plugin indent on
syntax enable

" If you want to install not installed plugins on startup.
if dein#check_install()
  call dein#install()
endif

" NERDTree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif


" Denite用プレフィックス
nmap [denite] <Nop>
map <C-j> [denite]

" プロジェクト内のファイル検索
nmap <silent> [denite]<C-P> :<C-u>Denite file_rec -highlight-mode-insert=Search<CR>
" バッファに展開中のファイル検索
nmap <silent> [denite]<C-B> :<C-u>Denite buffer -highlight-mode-insert=Search<CR>
" ファイル内の関数/クラス等の検索
nmap <silent> [denite]<C-O> :<C-u>Denite outline -highlight-mode-insert=Search<CR>
" dotfiles配下をカレントにしてfile_rec起動
nmap <silent> [denite]<C-V> :<C-u>call denite#start([{'name': 'file_rec', 'args': ['~/.dotfiles']}]) -highlight-mode-insert=Search=Search<CR>
" 検索対象外のファイル指定
call denite#custom#filter('matcher_ignore_globs', 'ignore_globs',
    \ [ '.git/', '.ropeproject/', '__pycache__/',
    \   'venv/', 'images/', '*.min.*', 'img/', 'fonts/'])

" CheetSheet
let g:cheatsheet#cheat_file = '~/cheetsheet.md'

" ale
" 保存時のみ実行する
let g:ale_lint_on_text_changed = 0
" 表示に関する設定
let g:ale_sign_error = ''
let g:ale_sign_warning = ''
let g:airline#extensions#ale#open_lnum_symbol = '('
let g:airline#extensions#ale#close_lnum_symbol = ')'
let g:ale_echo_msg_format = '[%linter%]%code: %%s'
highlight link ALEErrorSign Tag
highlight link ALEWarningSign StorageClass
" Ctrl + kで次の指摘へ、Ctrl + jで前の指摘へ移動
nmap <silent> <C-k> <Plug>(ale_previous_wrap)
nmap <silent> <C-j> <Plug>(ale_next_wrap)

let g:sonictemplate_vim_template_dir = ['~/templates']


function! CPPCodeCleanup()
  " echo "Cleanup cpp code"
  let l:lines="all"
  let g:clang_format_fallback_style = 'Google'
  :pyf /usr/local/share/clang/clang-format.py
endfunction
command! CPPCodeCleanup call CPPCodeCleanup()

autocmd BufWrite *.{cpp} :CPPCodeCleanup
autocmd BufWrite *.{hpp} :CPPCodeCleanup
autocmd BufWrite *.{c} :CPPCodeCleanup
autocmd BufWrite *.{h} :CPPCodeCleanup


" disable auto completion for vim-clang
" let g:clang_auto = 1
" default 'longest' can not work with neocomplete
let g:clang_c_completeopt   = 'menuone'
let g:clang_cpp_completeopt = 'menuone'

function! s:get_latest_clang(search_path)
    let l:filelist = split(globpath(a:search_path, 'clang-*'), '\n')
    let l:clang_exec_list = []
    for l:file in l:filelist
        if l:file =~ '^.*clang-\d\.\d$'
            call add(l:clang_exec_list, l:file)
        endif
    endfor
    if len(l:clang_exec_list)
        return reverse(l:clang_exec_list)[0]
    else
        return 'clang'
    endif
endfunction

function! s:get_latest_clang_format(search_path)
    let l:filelist = split(globpath(a:search_path, 'clang-format-*'), '\n')
    let l:clang_exec_list = []
    for l:file in l:filelist
        if l:file =~ '^.*clang-format-\d\.\d$'
            call add(l:clang_exec_list, l:file)
        endif
    endfor
    if len(l:clang_exec_list)
        return reverse(l:clang_exec_list)[0]
    else
        return 'clang-format'
    endif
endfunction

let g:clang_exec = s:get_latest_clang('/usr/bin')
let g:clang_format_exec = s:get_latest_clang_format('/usr/bin')

let g:clang_c_options = '-std=c11'
let g:clang_cpp_options = '-std=c++11 -stdlib=libc++'
let g:clang_format_auto = 1

let g:neocomplete#enable_at_startup = 1

