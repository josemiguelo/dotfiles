scriptencoding utf-8
source ~/.config/nvim/plugins.vim

" ============================================================================ "
" ===                           EDITING OPTIONS                            === "
" ============================================================================ "

" Show matching brackets
set showmatch

" Prevents inserting two spaces after punctuation
set nojoinspaces

" Configure backspace so it acts as it should act
set backspace=eol,start,indent
set whichwrap+=<,>,h,l

set splitbelow          " Horizontal split below current.
set splitright          " Vertical split to right of current

if !&scrolloff
    set scrolloff=3       " Show next 3 lines while scrolling
endif
if !&sidescrolloff
    set sidescrolloff=5   " Show next 5 columns while side-scrolling.
endif
set nostartofline       " Do not jump to first character with page commands.

" Tell Vim which characters to show for expanded TABs,
" " trailing whitespace, and end-of-lines. VERY useful!
if &listchars ==# 'eol:$'
  set listchars=tab:>\ ,trail:-,extends:>,precedes:<,nbsp:+
endif
set list                " Show problematic characters.
  " Also highlight all tabs and trailing whitespace characters.
highlight ExtraWhitespace ctermbg=darkgreen guibg=darkgreen
match ExtraWhitespace /\s\+$\|\t/

" Remap leader key to ,
let g:mapleader=','

" Don't show last command
set noshowcmd

"Always show signcolumn
set signcolumn=yes

" Yank and paste with the system clipboard
set clipboard=unnamed

" Hides buffers instead of closing them
set hidden

" === TAB/Space settings === "
" Insert spaces when TAB is pressed.
set expandtab

" Change number of spaces that a <Tab> counts for during editing ops
set softtabstop=2

" Indentation amount for < and > commands.
set shiftwidth=2

" do not wrap long lines by default
set nowrap

" Don't highlight current cursor line
set cursorline

" Disable line/column number in status line
" Shows up in preview window when airline is disabled if not
set ruler

" Only one line for command line
set cmdheight=1
"
" Don't give completion messages like 'match 1 of 2'
" or 'The only match'
set shortmess+=c

set encoding=UTF-8

" ============================================================================ "
" ===                           PLUGIN SETUP                               === "
" ============================================================================ "

" === Buffergator setup ==="
map <leader>; :BuffergatorOpen<CR>
map gb :BuffergatorMruCyclePrev<CR>
let g:buffergator_viewport_split_policy = 'B'
let g:buffergator_suppress_keymaps = 1




" === Denite setup ==="
" Wrap in try/catch to avoid errors on initial install before plugin is available
try
    " Use ripgrep for searching current directory for files
    " By default, ripgrep will respect rules in .gitignore
    "   --files: Print each file that would be searched (but don't search)
    "   --glob:  Include or exclues files for searching that match the given glob
    "            (aka ignore .git files)
    "
    call denite#custom#var('file/rec', 'command', ['rg', '--files', '--glob', '!.git'])

    " Use ripgrep in place of "grep"
    call denite#custom#var('grep', 'command', ['rg'])

    " Custom options for ripgrep
    "   --vimgrep:  Show results with every match on it's own line
    "   --hidden:   Search hidden directories and files
    "   --heading:  Show the file name above clusters of matches from each file
    "   --S:        Search case insensitively if the pattern is all lowercase
    call denite#custom#var('grep', 'default_opts', ['--hidden', '--vimgrep', '--heading', '-S'])

    " Recommended defaults for ripgrep via Denite docs
    call denite#custom#var('grep', 'recursive_opts', [])
    call denite#custom#var('grep', 'pattern_opt', ['--regexp'])
    call denite#custom#var('grep', 'separator', ['--'])
    call denite#custom#var('grep', 'final_opts', [])

    " Remove date from buffer list
    call denite#custom#var('buffer', 'date_format', '')

    " Custom options for Denite
    "   auto_resize             - Auto resize the Denite window height automatically.
    "   prompt                  - Customize denite prompt
    "   direction               - Specify Denite window direction as directly below current pane
    "   winminheight            - Specify min height for Denite window
    "   highlight_mode_insert   - Specify h1-CursorLine in insert mode
    "   prompt_highlight        - Specify color of prompt
    "   highlight_matched_char  - Matched characters highlight
    "   highlight_matched_range - matched range highlight
    let s:denite_options = {'default' : {
    \ 'auto_resize': 1,
    \ 'prompt': 'λ:',
    \ 'direction': 'rightbelow',
    \ 'winminheight': '15',
    \ 'highlight_mode_insert': 'Visual',
    \ 'highlight_mode_normal': 'Visual',
    \ 'prompt_highlight': 'Function',
    \ 'highlight_matched_char': 'Function',
    \ 'highlight_matched_range': 'Normal'
    \ }}

    " Loop through denite options and enable them
    function! s:profile(opts) abort
      for l:fname in keys(a:opts)
        for l:dopt in keys(a:opts[l:fname])
          call denite#custom#option(l:fname, l:dopt, a:opts[l:fname][l:dopt])
        endfor
      endfor
    endfunction

    call s:profile(s:denite_options)

    call denite#custom#map('insert', '<C-j>', '<denite:move_to_next_line>', 'noremap')
    call denite#custom#map('insert', '<C-n>', '<denite:move_to_next_line>', 'noremap')
    call denite#custom#map('insert', '<C-k>', '<denite:move_to_previous_line>', 'noremap')
    call denite#custom#map('insert', '<C-p>', '<denite:move_to_previous_line>', 'noremap')

catch
  echo 'Denite not installed. It should work after running :PlugInstall'

endtry



" === Coc.nvim === "
" use <tab> for trigger completion and navigate to next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()

"Close preview window when completion is done.
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction




" === NeoSnippet === "
" Map <C-k> as shortcut to activate snippet if available
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)


" Load custom snippets from snippets folder
let g:neosnippet#snippets_directory='~/.config/nvim/snippets'

" Hide conceal markers
let g:neosnippet#enable_conceal_markers = 0




" === NERDTree === "
" Show hidden files/directories
let g:NERDTreeShowHidden = 1

" Remove bookmarks and help text from NERDTree
let g:NERDTreeMinimalUI = 1

" Custom icons for expandable/expanded directories
let g:NERDTreeDirArrowExpandable = '⬏'
let g:NERDTreeDirArrowCollapsible = '⬎'

" Hide certain files and directories from NERDTree
let g:NERDTreeIgnore = ['^\.DS_Store$', '^tags$', '\.git$[[dir]]', '\.idea$[[dir]]', '\.sass-cache$']

" Hide the Nerdtree status line to avoid clutter
let g:NERDTreeStatusline = ''


" === Vim airline ==== "

" Wrap in try/catch to avoid errors on initial install before plugin is available
try

    " Enable extensions
    let g:airline_extensions = ['branch', 'hunks', 'coc']

    " Update section z to just have line number
    let g:airline_section_z = airline#section#create(['linenr'])

    " Do not draw separators for empty sections (only for the active window) >
    let g:airline_skip_empty_sections = 1

    " Smartly uniquify buffers names with similar filename, suppressing common parts of paths.
    let g:airline#extensions#tabline#formatter = 'unique_tail'

    " Custom setup that removes filetype/whitespace from default vim airline bar
    let g:airline#extensions#default#layout = [['a', 'b', 'c'], ['x', 'z', 'warning', 'error']]

    let airline#extensions#coc#stl_format_err = '%E{[%e(#%fe)]}'

    let airline#extensions#coc#stl_format_warn = '%W{[%w(#%fw)]}'

    " Configure error/warning section to use coc.nvim
    let g:airline_section_error = '%{airline#util#wrap(airline#extensions#coc#get_error(),0)}'
    let g:airline_section_warning = '%{airline#util#wrap(airline#extensions#coc#get_warning(),0)}'

    " Disable vim-airline in preview mode
    let g:airline_exclude_preview = 1

    " Enable powerline fonts
    let g:airline_powerline_fonts = 1

    " Enable caching of syntax highlighting groups
    let g:airline_highlighting_cache = 1
    let g:airline_left_sep = '»'
    let g:airline_left_sep = '▶'
    let g:airline_right_sep = '«'
    let g:airline_right_sep = '◀'
    let g:airline_symbols.linenr = '␊'
    let g:airline_symbols.linenr = '␤'
    let g:airline_symbols.linenr = '¶'
    let g:airline_symbols.branch = '⎇'
    let g:airline_symbols.paste = 'ρ'
    let g:airline_symbols.paste = 'Þ'
    let g:airline_symbols.paste = '∥'
    let g:airline_symbols.whitespace = 'Ξ'

    "" airline symbols
    let g:airline_left_sep = ''
    let g:airline_left_alt_sep = ''
    let g:airline_right_sep = ''
    let g:airline_right_alt_sep = ''
    let g:airline_symbols.branch = ''
    let g:airline_symbols.readonly = ''
    let g:airline_symbols.linenr = ''



    " Don't show git changes to current file in airline
    let g:airline#extensions#hunks#enabled=0

catch
  echo 'Airline not installed. It should work after running :PlugInstall'
endtry




" === echodoc === "
" Enable echodoc on startup
let g:echodoc#enable_at_startup = 1

" === vim-javascript === "
" Enable syntax highlighting for JSDoc
let g:javascript_plugin_jsdoc = 1

" === vim-jsx === "
" Highlight jsx syntax even in non .jsx files
let g:jsx_ext_required = 0

" === javascript-libraries-syntax === "
let g:used_javascript_libs = 'underscore,requirejs,chai,jquery'

" === Signify === "
let g:signify_sign_delete = '-'




" ============================================================================ "
" ===                                UI                                    === "
" ============================================================================ "

" Enable true color support
" set termguicolors

" Editor theme
set background=dark
try
  colorscheme OceanicNext
catch
  colorscheme slate
endtry

" Vim airline theme
let g:airline_theme='papercolor'

" Add custom highlights in method that is executed every time a
" colorscheme is sourced
" See https://gist.github.com/romainl/379904f91fa40533175dfaec4c833f2f for
" details
function! MyHighlights() abort
  " Hightlight trailing whitespace
  highlight Trail ctermbg=red guibg=red
  call matchadd('Trail', '\s\+$', 100)
endfunction

augroup MyColors
  autocmd!
  autocmd ColorScheme * call MyHighlights()
augroup END

" Change vertical split character to be a space (essentially hide it)
set fillchars+=vert:.

" Set preview window to appear at bottom
set splitbelow

" Don't dispay mode in command line (airilne already shows it)
set noshowmode

" coc.nvim color changes
hi! link CocErrorSign WarningMsg
hi! link CocWarningSign Number
hi! link CocInfoSign Type

" Make background transparent for many things
"hi! Normal ctermbg=NONE guibg=NONE
"hi! NonText ctermbg=NONE guibg=NONE
"hi! LineNr ctermfg=NONE guibg=NONE
"hi! SignColumn ctermfg=NONE guibg=NONE
"hi! StatusLine guifg=#16252b guibg=#6699CC
"hi! StatusLineNC guifg=#16252b guibg=#16252b

" Try to hide vertical spit and end of buffer symbol
hi! VertSplit gui=NONE guifg=#17252c guibg=#17252c
hi! EndOfBuffer ctermbg=NONE ctermfg=NONE guibg=#17252c guifg=#17252c

" Customize NERDTree directory
hi! NERDTreeCWD guifg=#99c794

" Make background color transparent for git changes
hi! SignifySignAdd guibg=NONE
hi! SignifySignDelete guibg=NONE
hi! SignifySignChange guibg=NONE

" Highlight git change signs
hi! SignifySignAdd guifg=#99c794
hi! SignifySignDelete guifg=#ec5f67
hi! SignifySignChange guifg=#c594c5

" Call method on window enter
augroup WindowManagement
  autocmd!
  autocmd WinEnter * call Handle_Win_Enter()
augroup END

" Change highlight group of preview window when open
function! Handle_Win_Enter()
  if &previewwindow
    setlocal winhighlight=Normal:MarkdownError
  endif
endfunction

" ============================================================================ "
" ===                             KEY MAPPINGS                             === "
" ============================================================================ "

" WinTabs
map tn :WintabsNext<cr>
map tp :WintabsPrevious<cr>
map tc :WintabsClose<cr>
map tu :WintabsUndo<cr>
map tm :WintabsMove



" === Denite shorcuts === "
"   ;         - Browser currently open buffers
"   <leader>t - Browse list of files in current directory
"   <leader>g - Search current directory for occurences of given term and
"   close window if no results
"   <leader>j - Search current directory for occurences of word under cursor
" nmap <leader>; :Denite buffer -split=floating -winrow=1<CR>
nmap <leader>t :Denite file/rec -split=floating -winrow=1<CR>
nnoremap <leader>g :<C-u>Denite grep:. -no-empty -mode=normal<CR>
nnoremap <leader>j :<C-u>DeniteCursorWord grep:. -mode=normal<CR>


" === Nerdtree shorcuts === "
"  <leader>n - Toggle NERDTree on/off
"  <leader>f - Opens current file location in NERDTree
nmap <leader>n :NERDTreeToggle<CR>
nmap <leader>f :NERDTreeFind<CR>


" === coc.nvim === "
nmap <silent> <leader>dd <Plug>(coc-definition)
nmap <silent> <leader>dr <Plug>(coc-references)
nmap <silent> <leader>dj <Plug>(coc-implementation)
nmap <silent> <leader>gy <Plug>(coc-type-definition)
nmap <leader>rn <Plug>(coc-rename)


" Close the current buffer
map <leader>bd :Bclose<cr>:tabclose<cr>gT

" Close all the buffers
map <leader>ba :bufdo bd<cr>

map <leader>l :bnext<cr>
map <leader>h :bprevious<cr>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
" map <leader>tm :tabmove-
map <leader>t<leader> :tabNext


let g:lasttab = 1
nmap <Leader>tl :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab = tabpagenr()

" Use `:Format` to format current buffer
command! -nargs=0 Format :call CocAction('format')


" === vim-better-whitespace === "
"   <leader>y - Automatically remove trailing whitespace
nmap <leader>y :StripWhitespace<CR>

" === Search shorcuts === "
"   <leader>h - Find and replace
"   <leader>/ - Claer highlighted search terms while preserving history
map <leader>h :%s///<left><left>
nmap <silent> <leader><cr> :nohlsearch<CR>
"
" === Easy-motion shortcuts ==="
"   <leader>w - Easy-motion highlights first word letters bi-directionally
map <leader>w <Plug>(easymotion-bd-w)



" === vim-jsdoc shortcuts ==="
" Generate jsdoc for function under cursor
nmap <leader>z :JsDoc<CR>

" Delete current visual selection and dump in black hole buffer before pasting
" Used when you want to paste over something without it getting copied to
" Vim's default buffer
" vnoremap <leader>p "_dP

" Map <Space> to / (search) and Ctrl-<Space> to ? (backwards search)
map <space> /

" Fast saving
nmap <leader>s :w!<cr>

" Yankstack
nmap <leader>p <Plug>yankstack_substitute_older_paste
nmap <leader>P <Plug>yankstack_substitute_newer_paste


let MRU_Max_Entries = 400
map <leader>m :MRU<CR>

" Vim
let g:indentLine_color_term = 239

" GVim
let g:indentLine_color_gui = '#4b4d54'

" none X terminal
let g:indentLine_color_tty_light = 7 " (default: 4)
let g:indentLine_color_dark = 1 " (default: 2)

" Background (Vim, GVim)
"let g:indentLine_bgcolor_term = 239
"let g:indentLine_bgcolor_gui = '#333438'

nmap <silent> <leader>i :IndentLinesToggle<CR>

" ============================================================================ "
" ===                                 MISC.                                === "
" ============================================================================ "

" Relative numbering
function! NumberToggle()
  if(&relativenumber == 1)
      set nornu
      set number
    else
      set rnu
  endif
endfunc

" Toggle between normal and relative numbering.
nnoremap <leader>r :call NumberToggle()<cr>

" Automaticaly close nvim if NERDTree is only thing left open
" autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


" === Search === "
" ignore case when searching
set ignorecase

" if the search string has an upper case letter in it, the search will be case sensitive
set smartcase

" Automatically re-read file if a change was detected outside of vim
set autoread

" Enable line numbers
set number

" Set backups
"if has('persistent_undo')
  "set undofile
  "set undolevels=3000
  "set undoreload=10000
"endif
"set backupdir=~/.local/share/nvim/backup " Don't put backups in current dir
"set backup
set noswapfile

" Reload icons after init source
if exists('g:loaded_webdevicons')
  call webdevicons#refresh()
endif


if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
endif
