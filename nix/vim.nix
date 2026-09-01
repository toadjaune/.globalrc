{ pkgs, ... }:

{
  programs.vim = {
    enable = true;

    # This defaults to installing vim-full, which we need for the wayland_clipboard option
    # packageConfigurable =

    # TODO: We may want to switch to this, instead of setting $EDITOR ourselves
    # defaultEditor = false

    # Get the list of existing plugins with `nix-env -f '<nixpkgs>' -qaP -A vimPlugins`
    plugins = [
      # Default value of home-manager, and also shipped by default on debian, etc
      pkgs.vimPlugins.vim-sensible

      # User interface
      pkgs.vimPlugins.tabular             # provides :Tab to align text
      pkgs.vimPlugins.vim-tmux-navigator  # Consistent set of keys to navigate between vim splits and tmux panels
      pkgs.vimPlugins.vim-airline         # OP statusbar
      pkgs.vimPlugins.vim-airline-themes  # Associated themes

      # Filesystem access (Tree ...)
      pkgs.vimPlugins.nerdtree
      pkgs.vimPlugins.ctrlp-vim

      # Git
      pkgs.vimPlugins.vim-fugitive  # Access to git commands from Vim
      pkgs.vimPlugins.vim-gitgutter # Displays signs for git modifications
      # pkgs.vimPlugins.vim-git       # Git syntax highlighting -> disabled for now because unfree license

      # Development tools
      pkgs.vimPlugins.indentLine      # Vertical bars to display indentation with conceal feature
        # TODO: Try to find a way to keep trailing characters displayed instead of concealing them too (?)
        # TODO: I'm not actually sure what this even does anymore
      pkgs.vimPlugins.vim-commentary  # Add a comment operator (gc)

      # Better json highlighting ?
      # The only difference I see with native json syntax highlighting is that I can use vim_json_syntax_conceal below
      pkgs.vimPlugins.vim-json

      # Nice icons (must be loaded after the plugins it affects)
      pkgs.vimPlugins.vim-devicons
      pkgs.vimPlugins.vim-nerdtree-syntax-highlight

    ];

    # this configuration is rendered directly to a file in the nix store, that does not get symlinked anywhere in the home directory
    # Instead, it is loaded via a wrapper script around the actual vim executable. To get the path of the resulting vimrc, run `cat ~/.nix-profile/bin/vim` and look at the -u argument on the exec line
    # TODO: We can probably get the corresponding path with a nix command too
    extraConfig = ''
      " Nice resources to get started :
      " http://nvie.com/posts/how-i-boosted-my-vim/
      " http://learnvimscriptthehardway.stevelosh.com/
      " http://vim.wikia.com/wiki/Use_Vim_like_an_IDE
      " https://github.com/VundleVim/Vundle.vim/wiki/Examples

      set nocompatible          " don't try to be compatible with legacy vi, we can use """modern""" vim-only features
      filetype off              " TODO: was required by vim-plug, not sure what it does
      filetype plugin indent on " TODO: was required by vim-plug, not sure what it does


      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Plugin-specific configuration
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " change the mapleader from \ to Space
      " this command must be before anything using <leader>
      let mapleader=" "

      """ vim-tmux-navigator """
      let g:tmux_navigator_no_mappings = 1
          " Do not use the default mappings

      """ nerdtree """
      " start nerdtree automatically if vim is started without argument
      autocmd StdinReadPre * let s:std_in=1
      autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
      " start nerdtree automatically if vim starts opening a directory
      autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
      " close vim if nerdtree is the only remaining window
      autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
      " Skip confirmation messages
      let NERDTreeAutoDeleteBuffer = 1

      """ airline """
      let g:airline_theme='murmur'      " Choose airline theme
      " Enable Powerline enhanced fonts (nice git symbols + arrows in statusbar)
      " This should be enabled only if a powerline font is detected in curent
      " terminal
      let g:airline_powerline_fonts = $GLOBALRC_PATCHED_FONT
      " Add a line with opened tabs
      let g:airline#extensions#tabline#enabled = 1

      """ nerdtree-git-plugin """
      let g:NERDTreeShowGitStatus = $GLOBALRC_PATCHED_FONT
      let g:NERDTreeGitUnchangedIndicator = ' '

      """ vim-devicons """
      let g:webdevicons_enable = $GLOBALRC_PATCHED_FONT
      let g:WebDevIconsUnicodeDecorateFolderNodes = 1
      let g:DevIconsEnableFoldersOpenClose = 1

      """ vim-nerdtree-syntax-highlight """
      let g:NERDTreeFileExtensionHighlightFullName = 1
      let g:NERDTreeExactMatchHighlightFullName = 1
      let g:NERDTreePatternMatchHighlightFullName = 1

      """ vim-json """
      let g:vim_json_syntax_conceal = 0

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => General
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Hides buffers instead of closing them
      " This allows you to have several files open with unsaved chages
      set hidden

      " Set to auto read when a file is changed from the outside
      set autoread

      " Refesh display (gitgutter hunks…) every half second
      set updatetime=500

      " Improve % motion (see :h matchit-install and :h matchit)
      runtime macros/matchit.vim

      " Use :WS to save with sudo if you opened the file without enough rights
      command! WS :execute ':silent w !sudo tee % > /dev/null' | :edit!

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => VIM user interface
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      set backspace=eol,start,indent  " Allow backspacing over everything in insert mode

      " Configure which keys can change line when at beginning/end of line (see :help 'whichwrap')
      " set whichwrap+=[,]

      " Configure folding (see :help folding)
      set foldmethod=syntax
      set foldlevel=1

      " Don't redraw while executing macros (good performance config)
      set lazyredraw

      " For regular expressions turn magic on
      set magic

      set showmatch     " Show matching brackets when text indicator is over them
      set mat=2         " How many tenths of a second to blink when matching brackets
      set mouse=a       " Enable mouse interaction

      " Show line numbers, relative only in active file in normal mode
      " See https://github.com/jeffkreeftmeijer/vim-numbertoggle
      set number relativenumber
      augroup numbertoggle
        autocmd!
        autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu   | endif
        autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
      augroup END

      " Enable/Disable Paste Mode with leader-p
      " noremap <silent> <leader>p :set nu!<CR>:setlocal paste!<CR>

      set history=1000         " remember more commands and search history
      set undolevels=1000      " remember more actions in undo buffer
      set title                " change the terminal's title
      set visualbell           " don't beep
      set noerrorbells         " don't beep

      " Display whitespaces
      set list
      set listchars=tab:>.,trail:.,extends:#,nbsp:_
      " Do not display the non-breaking spaces introduced in NERDtree by vim-devicons
      " https://github.com/ryanoasis/vim-devicons/issues/133
      autocmd FileType nerdtree setlocal nolist

      " Disable swapfiles
      set noswapfile

      set cursorline  " highlight cursor line
          " TODO: Find a way to only change the background color, not the trailing
          " characters or the highlightings of TODO ...
          " Apparently not possible yet :
          " https://stackoverflow.com/questions/15980451/cursorline-and-nontext-specialkey-highlight-clash
          " https://github.com/vim/vim/blob/master/runtime/doc/todo.txt
          " https://vi.stackexchange.com/questions/3288/override-cursorline-background-color-by-syntax-highlighting
          " Eventual possible hack :
          " https://github.com/ntpeters/vim-better-whitespace

      " Remove trailing whitespaces with leader-t
      " This currently adds a line to search history, and disables highlighting if
      " currently enabled
      nnoremap <silent> <leader>t :let _s=@/ <Bar> :%s/\s\+$//e <Bar> :let @/=_s <Bar> :nohl <Bar> :unlet _s <CR>

      " Switch focus to NERDTree, or open it if not opened
      nnoremap <silent> <leader>n :NERDTreeFocus<CR>
      " Open the current file in NERDTree
      nnoremap <silent> <leader>f :NERDTreeFind<CR>

      " Space alone doesn't do anything
      nnoremap <Space> <nop>

      " Movement keys with Alt (Issues with <A-> and <M-> notations ...)
      " See :help mapmode-l for lnoremap
      noremap  h <left>
      noremap  j <down>
      noremap  k <up>
      noremap  l <right>
      noremap! h <left>
      noremap! j <down>
      noremap! k <up>
      noremap! l <right>

      " Navigating across vim splits and tmux panes
      noremap <silent> <C-h> :TmuxNavigateLeft<cr>
      noremap <silent> <C-j> :TmuxNavigateDown<cr>
      noremap <silent> <C-k> :TmuxNavigateUp<cr>
      noremap <silent> <C-l> :TmuxNavigateRight<cr>
      " noremap <silent> <C-m> :TmuxNavigatePrevious<cr>

      " Search for text in visual selection
      " see http://vim.wikia.com/wiki/Search_for_visually_selected_text
      vnoremap // y/\V<C-R>"<CR>

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Clipboard setup
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      " NB: Make sure your vim binary was compiled with clipboard_wayland support

      " Make vim use the system clipboard ("+) by default
      " See http://vim.wikia.com/wiki/Accessing_the_system_clipboard
      " set clipboard=unnamedplus

      " We actually prefer to have specific distinct mappings for interacting with system clipboard
      noremap <leader>y  "+y
      noremap <leader>Y  "+Y
      noremap <leader>p  "+p
      noremap <leader>P  "+P

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Search settings
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      set ignorecase    " Ignore case when searching
      set smartcase     " ignore case if search pattern is all lowercase, case-sensitive otherwise
      set hlsearch      " Highlight search results
      set incsearch     " show search matches as you type
      nnoremap <silent> <leader>/ :nohlsearch<CR>
                        " clear search buffer by typing leader-/

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Navigation in file
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      " Center the cursor vertically when searching
      nnoremap n nzz
      nnoremap N Nzz
      nnoremap * *zz
      nnoremap # #zz
      nnoremap g* g*zz
      nnoremap g# g#zz

      " Start scrolling the file before the cursor reaches the top/bottom
      set scrolloff=5

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Colors and Fonts
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " Enable syntax highlighting
      syntax enable

      " Disable syntax highlighting on too long lines to avoid slowing down vim
      set synmaxcol=200

      " Set utf8 as standard encoding and en_US as the standard language
      set encoding=utf-8
      set fileencoding=utf-8

      " Use Unix as the standard file type
      set ffs=unix,dos,mac

      " Base colorscheme choice
      set background=dark
      silent! colorscheme eldar

      " Manual color override
      " Trailing whitespaces & co in Orange
      hi  SpecialKey ctermfg=214

      " Recognize Jenkinsfile as groovy
      " https://gist.github.com/richardsonlima/fd42bf8f34ca4444cc828a34c8093f4c
      au BufNewFile,BufRead Jenkinsfile setf groovy

      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Text, tab and indent related
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

      set autoindent    " always set autoindenting on
      set copyindent    " copy the previous indentation on autoindenting
      set expandtab     " use spaces instead of tabs
      set smarttab      " insert tabs on the start of a line according to shiftwidth, not tabstop
      set shiftwidth=2  " 1 tab == 2 spaces
      set tabstop=2
      set shiftround    " use multiple of shiftwidth when indenting with '<' and '>'

      set smartindent
      if has("autocmd")
        filetype plugin indent on " Detect indentation rules based on file extension
      endif

      set ai "Auto indent
      set si "Smart indent
      set wrap "Wrap lines
      nnoremap <silent> <leader>w :set wrap!<CR>
            " Enable/disable line wrapping with leader-w


      """"""""""""""""""""""""""""""
      " => Status line
      """"""""""""""""""""""""""""""
      " Always show the status line
      set laststatus=2

      " " Format the status line
      " set statusline=\ %f%m%r%y\ %w\ \ CWD:\ %{GetCurrentDirectory()}%=b:%-2n\ \ r:%l/%L\ c:%-3v\ %P


      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      " => Helper functions
      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
      function! GetCurrentDirectory()
        return fnamemodify(getcwd(), ":~")
      endfunction
    '';
  };

}
