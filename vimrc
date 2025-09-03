" Configuration Vim sécurisée pour partage GitHub
" Basée sur shussain@credil.org + ajouts modernes
" https://github.com/shussain/vimrc/blob/master/_vimrc-simplified

" === CONFIGURATION DE BASE ===
if &term == "screen"
  set t_ts=^[k
  set t_fs=^[\
endif
if &term == "screen" || &term == "xterm"
  set title
endif
set nocp

set number
set encoding=utf-8
set showmode
set showcmd
set ignorecase
set smartcase

" Spelling changes
abbreviate teh the
abbreviate eg e.g.

" Correcteur orthographique (français et anglais)
set spell spelllang=fr,en

set nobackup

" === CONFIGURATION INDENTATION ===
set smarttab autowrite
autocmd FileType ruby,javascript,json,yaml,html,css set tabstop=2 shiftwidth=2 expandtab
autocmd FileType python,php set tabstop=4 shiftwidth=4 expandtab
set nowrap

" === GESTIONNAIRE DE PLUGINS ===
" SÉCURISÉ: Installation manuelle requise
" Pour installer vim-plug, exécuter manuellement:
" curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
"     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

" Vérifier que vim-plug est installé avant de l'utiliser
if filereadable(expand('~/.vim/autoload/plug.vim'))
  call plug#begin('~/.vim/plugged')

  " LSP et autocomplétion
  Plug 'neoclide/coc.nvim', {'branch': 'release'}

  " Navigation rapide
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

  " Support Ruby
  Plug 'vim-ruby/vim-ruby'
  Plug 'tpope/vim-rails'

  " Formatage
  Plug 'prettier/vim-prettier', {
    \ 'do': 'yarn install',
    \ 'for': ['javascript', 'typescript', 'css', 'less', 'scss', 'json', 'graphql', 'markdown', 'vue', 'html'] }

  " Interface utilisateur
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

  call plug#end()
else
  echo "vim-plug non installé. Voir instructions dans le .vimrc"
endif

" === RACCOURCIS ===
if ! has("patch547")
   :let mapleader = ","
endif

" Configuration et navigation
:nmap <Leader>s :source $HOME/.vimrc<CR>
:nmap <Leader>v :e $HOME/.vimrc<CR>
:nmap <Leader>t <Esc>:tabnew<CR>
:nmap <Leader>w <Esc>:tabclose<CR>
:nmap <Leader><Tab> gt<CR>
:nmap <Leader>] <Esc>:!ctags -R .<CR>
:nmap <Leader>- <Esc>a-----<Esc>
:nmap <Leader>e <Esc>:set wrap linebreak<CR>

" Navigation rapide (si fzf installé)
if exists(':Files')
  nnoremap <Leader>p :Files<CR>
endif
if exists(':Ag')
  nnoremap <Leader>f :Ag<CR>
endif

" === CONFIGURATION COC (si installé) ===
if exists('g:did_coc_loaded')
  inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)
endif

" === VALIDATIONS ET FORMATAGE ===
autocmd BufWritePre * :%s/\s\+$//e

set cindent
set cinkeys-=0#
set indentkeys-=0#
set wrap
set linebreak
let &listchars = 'tab:  ,nbsp:Â·'
set laststatus=2
set statusline=%t[%{strlen(&fenc)?&fenc:'none'},%{&ff}]%h%m%r%y%=[%o]\ %c,%l/%L\ %P
set hlsearch

:filetype off
let g:rufo_auto_formatting = 1
let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0
:filetype on

" === AUTO-VALIDATIONS ===
autocmd BufWritePost *.bash  :!bash -n %
au! BufNewFile,BufRead *.bat,*.sys setf dosbatch
au! BufNewFile,BufRead *.rb,*.rake setf ruby
au! BufNewFile,BufRead *.py, setf python
autocmd BufWritePost *.rake, :!ruby -c %
autocmd BufWritePost *.rb, :!ruby -c %
autocmd BufWritePost *.erb  :!erb -x -T '-' % | ruby -c
autocmd BufWritePost *.rake  :!ruby -c %
autocmd BufWritePost *.py  :!python -m py_compile %
autocmd BufWritePost *.pl  :!perl -c %
autocmd BufWritePost *.php,*.module  :!php -l %
autocmd BufWritePost *.txt  :!wc -w %
autocmd BufWritePost *.js :! node -c % > /dev/null && echo Syntax OK
autocmd BufWritePost *.json :!python -m json.tool % > /dev/null && echo Syntax OK
autocmd BufWritePost *.yml  :!yamllint %
autocmd BufWritePost :mks! ~/.vim/sessions/%

packloadall
