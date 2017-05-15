" Colors -------------------------------------
syntax on                       " syntax highlighting

" Whitespace ---------------------------------
set tabstop=4                   " 4 spaces per tab
set shiftwidth=4                " 4 spaces per indent level
set softtabstop=4               " 4 spaces per backspace
set expandtab                   " tabs, please
set smartindent                 " indent things for me
set shiftround                  " indenting when at column 3 will go to column 4, not 7
set autoindent                  " indent at the same level of the previous line
set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
set list
set listchars=""
set listchars=tab:>.,trail:.,extends:#,nbsp:.
set listchars+=trail:.
set listchars+=extends:>
set listchars+=precedes:<
autocmd FileType c,cpp,java,php,js,python,twig,xml,yml autocmd BufWritePre <buffer> :call setline(1,map(getline(1,"$"),'substitute(v:val,"\\s\\+$","","")'))

" UI Layout ----------------------------------
set number                      " Line numbers on
set encoding=utf-8              " UTF-8, please
set background=dark             " Assume a dark background
set backspace=indent,eol,start  " backspace for dummys
filetype indent on              " Automatically detect file types.
set colorcolumn=120             " Marker at column 120
set cursorline                  " highlight current line
set lazyredraw                  " redraw only when we need to.
set showmatch                   " highlight matching [{()}]

" Searching ----------------------------------
" turn off search highlight
nnoremap <leader><space> :nohlsearch<CR>
set showmatch                   " show matching brackets/parenthesis
set incsearch                   " find as you type search
set hlsearch                    " highlight search terms
set ignorecase                  " case insensitive search
set smartcase                   " case sensitive when uc present

" Tabline ------------------------------------
set showtabline=2
highlight TabLine     term=NONE cterm=NONE ctermfg=black  ctermbg=gray
highlight TabLineSel  term=NONE cterm=NONE ctermfg=yellow ctermbg=black
highlight TabLineFill term=NONE cterm=NONE ctermfg=black  ctermbg=gray

" Backups ------------------------------------
set noswapfile
set nobackup
set nowb
silent !mkdir ~/.vim/backups > /dev/null 2>&1
set undodir=~/.vim/backups
set undofile

" Completion ---------------------------------
" scan the current buffer, other windows, and included files
set complete=.,w,i

" highlight auto complete popup selected item with a better bg color
highlight PmenuSel ctermbg=3 ctermfg=0
set completeopt=longest,menuone

" let Enter accept completion like Ctrl+y, but only when the popup is visible
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Custom Functions ---------------------------
cnoremap sudow w !sudo tee % >/dev/null
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

