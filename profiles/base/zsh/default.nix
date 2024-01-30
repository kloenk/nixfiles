{ lib, pkgs, config, ... }:

{
  environment.pathsToLink = [ "/share/zsh" ];

  environment.systemPackages = with pkgs; [ fzf eza ripgrep ];

  programs.zsh = {
    enable = true;
    interactiveShellInit = ''
      function use {
        packages=()
        packages_fmt=()
        while [ "$#" -gt 0 ]; do
          i="$1"; shift 1
          packages_fmt+=$(echo $i | ${pkgs.gnused}/bin/sed 's/[a-zA-Z]*#//')
          [[ $i =~ [a-zA-Z]*#[a-zA-Z]* ]] || i="kloenk#$i"
          packages+=$i
        done
        env prompt_sub="%F{blue}($packages_fmt) %F{white}$PROMPT" nix shell $packages
      }
      PROMPT=''${prompt_sub:=$PROMPT}
    '';
    enableCompletion = true;
    #autosuggestions.enable = true;
    #setOptions = [ "AUTO_CD" ];
  };
}
