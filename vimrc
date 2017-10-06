" Author shussain@credil.org
" https://github.com/shussain/vimrc/blob/master/_vimrc-simplified


" Simplified vimrc for use when vim is installed but not gvim

" Show line number
set number
set encoding=utf-8

set showmode
set showcmd

" Ignore cases for searching
set ignorecase
set smartcase

" Spelling changes. fix common typos and mistakes I make
abbreviate teh the
abbreviate eg e.g.

" set spell spelllang=en_ca

" No backup thanks to source control but might change this later
set nobackup

" Configs for making Python development easy
"set syntax=on
set smarttab autowrite
set tabstop=4 shiftwidth=4 expandtab
set nowrap

"set the global map leader variable so that:
if ! has("patch547")
   :let mapleader = ","
endif

" Make it easy to update/reload _vimrc
:nmap <Leader>s :source $HOME/_vimrc<CR>
:nmap <Leader>v :e $HOME/_vimrc<CR>

" Have the tabbed editing work with internet browser type functionality
" You just use comma instead of CTRL
:nmap <Leader>t <Esc>:tabnew<CR>
:nmap <Leader>w <Esc>:tabclose<CR>
:nmap <Leader><Tab> gt<CR>

" Run ctags
:nmap <Leader>] <Esc>:!ctags -R .<CR>

" Get lines inserted
:nmap <Leader>- <Esc>a-----<Esc>

" Do word wrapping
:nmap <Leader>e <Esc>:set wrap linebreak<CR>

" Remove trailing white spaces
autocmd BufWritePre * :%s/\s\+$//e

" Set c indenting
" No smart indent, see http://vim.wikia.com/wiki/Restoring_indent_after_typing_hash
set cindent
set cinkeys-=0#
set indentkeys-=0#

set wrap
set linebreak
set nolist  " list disables linebreak


set statusline=%F%t[%{strlen(&fenc)?&fenc:'none'},%{&ff}]%h%m%r%y%=%c,%l/%L\ %P


set hlsearch

:syntax on


:filetype on
au! BufNewFile,BufRead *.bat,*.sys setf dosbatch
au! BufNewFile,BufRead *.rb,*.rake setf ruby
au! BufNewFile,BufRead *.py, setf python
autocmd BufWritePost *.rb  :!ruby -c %
autocmd BufWritePost *.rake  :!ruby -c %
autocmd BufWritePost *.py  :!python -m py_compile %
autocmd BufWritePost *.bash  :!bash -n %
autocmd BufWritePost *.php  :!php -l %
autocmd BufWritePost *.txt  :!wc -w %
autocmd BufWritePost *.js :! uglifyjs % > /dev/null && echo Syntax OK


