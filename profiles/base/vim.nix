{ pkgs, ... }:

{
  environment.variables.EDITOR = "vim";
  programs.vim = {
    defaultEditor = true;
    package = (pkgs.vim_configurable.override { }).customize {
      name = "vim";
      # Install plugins for example for syntax highlighting of nix files
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [ vim-nix vim-lastplace rust-vim tabular vim-elixir ];
        opt = [ ];
      };
      vimrcConfig.customRC = ''
        set viminfo='20,<1000
        set shiftwidth=2
        "set cc=80
        set nu

        " Uncomment the following to have Vim jump to the last position when
        " reopening a file
        if has("autocmd")
          au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
        endif

        " Move temporary files to a secure location to protect against CVE-2017-1000382
        if exists('$XDG_CACHE_HOME')
          let &g:directory=$XDG_CACHE_HOME
        else
          let &g:directory=$HOME . '/.cache'
        endif

        let &g:undodir=&g:directory . '/vim/undo//'
        let &g:backupdir=&g:directory . '/vim/backup//'
        let &g:directory.='/vim/swap//'
        " Create directories if they doesn't exist
        if ! isdirectory(expand(&g:directory))
          silent! call mkdir(expand(&g:directory), 'p', 0700)
        endif
        if ! isdirectory(expand(&g:backupdir))
          silent! call mkdir(expand(&g:backupdir), 'p', 0700)
        endif
        if ! isdirectory(expand(&g:undodir))
          silent! call mkdir(expand(&g:undodir), 'p', 0700)
        endif
        " Turn on syntax highlighting by default
        syntax on
        " ...
      '';
    };
  };
}