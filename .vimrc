" Undo some of the PLC default vimrc
set laststatus=0
set nocompatible

"""" Editor behavior and appearance
set nu                          " Line numbers on
set scrolljump=5                " lines to scroll when cursor leaves screen
set scrolloff=3                 " minimum lines to keep above and below cursor
set sidescroll=1        " scroll horizontally by 1 column at a time
set sidescrolloff=6     " scroll horizontally with 6 characters of context
set showmode                    " display the current mode
set background=dark             " Assume a dark background
set backspace=indent,eol,start  " backspace for dummys
set linespace=0                 " No extra spaces between rows
if !has('win32') && !has('win64')
    set term=$TERM              " Make arrow and other keys work
endif
filetype plugin indent on       " Automatically detect file types.
syntax on                       " syntax highlighting

"""" Searching
" These two are convenient for searching, but cause pain with search/replace
"set ignorecase      " Case insensitive search...
"set smartcase       " ... unless search includes capital letters
" spacebar kills current search highlighting and clears commandline residue
nnoremap <silent> <Space> :nohlsearch<Bar>:echo<CR>

" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>
set showmatch                   " show matching brackets/parenthesis
set incsearch                   " find as you type search
set hlsearch                    " highlight search terms
set ignorecase                  " case insensitive search
set smartcase                   " case sensitive when uc present

"""" Whitespace
set tabstop=4       " 4 spaces per tab
set shiftwidth=4    " 4 spaces per indent level
set noexpandtab     " tabs, please
set smartindent     " indent things for me
set shiftround      " indenting when at column 3 will go to column 4, not 7
set autoindent                  " indent at the same level of the previous line
set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
set list
set listchars=""
set listchars=tab:>.,trail:.,extends:#,nbsp:.
set listchars+=trail:.
set listchars+=extends:>
set listchars+=precedes:<
autocmd FileType c,cpp,java,php,js,python,twig,xml,yml autocmd BufWritePre <buffer> :call setline(1,map(getline(1,"$"),'substitute(v:val,"\\s\\+$","","")'))
"Remove trailing whitespace on <leader>S
nnoremap <leader>S :%s/\s\+$//<cr>:let @/=' '<CR>

"""" Tabs
set tabpagemax=20
set showtabline=2
highlight TabLine     term=NONE cterm=NONE ctermfg=black  ctermbg=gray
highlight TabLineSel  term=NONE cterm=NONE ctermfg=yellow ctermbg=black
highlight TabLineFill term=NONE cterm=NONE ctermfg=black  ctermbg=gray

"""" Backups and Swap files
set noswapfile
set nobackup
set nowb
""" keep undo history across sessions by storing in file
silent !mkdir ~/.vim/backups > /dev/null 2>&1
set undodir=~/.vim/backups
set undofile

"""" Key mappings
" Shift + h/j/k/l scroll without moving cursor
nnoremap H 2zh
nnoremap L 2zl
nnoremap J <C-e>
nnoremap K <C-y>

" finding next/prev matches should scroll their line to the center of the
nnoremap n nzz
nnoremap N Nzz

" I find myself hitting ma to move to bookmark "a", let's fix that
nnoremap M m
nnoremap m `

" work around a problem with smartindent
inoremap # X#

"""" Completion

" scan the current buffer, other windows, and included files
set complete=.,w,i

" highlight auto complete popup selected item with a better bg color
highlight PmenuSel ctermbg=3 ctermfg=0

" don't select first match when initiating completion, show menu even if
" there's only one match
set completeopt=longest,menuone

" let Enter accept completion like Ctrl+y, but only when the popup is visible
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

""" Command overrides
cnoremap sudow w !sudo tee % >/dev/null

"""" File encodings
set encoding=utf-8          " UTF-8, please
set nobomb                  " without byte-order mark

filetype plugin indent on   " required!
" ,v brings up my .vimrc
" ,V reloads it -- making all changes active (have to save first)
map <leader>v :sp ~/.vimrc<CR><C-W>_
map <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe ":echo 'vimrc reloaded'"<CR>

function! InitializeDirectories()
  let separator = "."
  let parent = $HOME 
  let prefix = '.vim'
  let dir_list = { 
              \ 'backup': 'backupdir', 
              \ 'views': 'viewdir', 
              \ 'swap': 'directory' }

  for [dirname, settingname] in items(dir_list)
      let directory = parent . '/' . prefix . dirname . "/"
      if exists("*mkdir")
          if !isdirectory(directory)
              call mkdir(directory)
          endif
      endif
      if !isdirectory(directory)
          echo "Warning: Unable to create backup directory: " . directory
          echo "Try: mkdir -p " . directory
      else  
          let directory = substitute(directory, " ", "\\\\ ", "")
          exec "set " . settingname . "=" . directory
      endif
  endfor
endfunction
call InitializeDirectories()

