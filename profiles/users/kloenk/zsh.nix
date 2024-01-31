{ lib, pkgs, ... }:

{
  imports = [ ./atuin.nix ];

  home-manager.users.kloenk = {
    programs.zsh = {
      enable = true;
      plugins = [{
        name = "zsh-nix-shell";
        file = "nix-shell.plugin.zsh";
        src = pkgs.fetchFromGitHub {
          owner = "chisui";
          repo = "zsh-nix-shell";
          rev = "v0.8.0";
          sha256 = "1lzrn0n4fxfcgg65v0qhnj7wnybybqzs4adz7xsrkgmcsr0ii8b7";
        };
      }];
      shellAliases = {
        ls = "eza";
        l = "eza -a";
        ll = "eza -lgh";
        la = "eza -lagh";
        lt = "eza -T";
        lg = "eza -lagh --git";
      };
      initExtra = ''
        ${builtins.readFile ./p10k.zsh}

        function use {
          packages=()
          packages_fmt=()
          while [ "$#" -gt 0 ]; do
            i="$1"; shift 1
            packages_fmt+=$(echo $i | ${pkgs.gnused}/bin/sed 's/[a-zA-Z]*#//')
            [[ $i =~ [a-zA-Z]*#[a-zA-Z]* ]] || i="nixpkgs#$i"
            packages+=$i
          done
          env prompt_sub="%F{blue}($packages_fmt) %F{white}$PROMPT" nix shell $packages
        }
        PROMPT=''${prompt_sub:=$PROMPT}
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [ "gitfast" "sudo" "ripgrep" ];
        theme = lib.mkDefault "powerlevel10k/powerlevel10k";
        custom = builtins.toString (pkgs.stdenv.mkDerivation {
          name = "oh-my-zsh-custom-dir";
          buildInputs = with pkgs; [ zsh-powerlevel10k ];
          unpackPhase = "true";
          installPhase = ''
            mkdir -p $out/themes
            ln -s ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k $out/themes/powerlevel10k
          '';
        });
      };
    };
    programs.zoxide.enable = true;
  };
}
