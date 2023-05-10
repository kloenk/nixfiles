{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "vscode"
      "vscode-with-extensions"
      "vscode-extension-ms-vscode-remote-remote-ssh"
      "vscode-extension-ms-vscode-cpptools"
      "vscode-extension-github-copilot"

      "discord"

      "steam"
      "steam-original"
      "steam-run"
      "steam-run-native"
      "steam-runtime"
      "steam-original"

      "chromium"
      "chromium-unwrapped"
      "chrome-widevine-cdm"

      "obsidian"
    ];

  users.users.kloenk = {
    packages = with pkgs; [
      alacritty
      chatterino2
      schildichat-desktop-wayland
      gh
      sops

      rustup
      gcc
      clang

      cargo-generate
      bpf-linker

      direnv
      elixir
      elixir_ls
      nil
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions;
          [
            matklad.rust-analyzer
            bbenoist.nix
            jnoortheen.nix-ide
            ms-python.python
            ms-vscode-remote.remote-ssh
            vscodevim.vim
            bungcip.better-toml
            ms-vscode.cpptools
            ms-vscode.cmake-tools
            twxs.cmake
            github.copilot
            eamodio.gitlens
            gruntfuggly.todo-tree
            elixir-lsp.vscode-elixir-ls
            vscode-extensions.mkhl.direnv
            dracula-theme.theme-dracula
            zhuangtongfa.material-theme
            tobiasalthoff.atom-material-theme
            mskelton.one-dark-theme
            vscode-extensions.ms-vscode.hexeditor
          ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
            {
              name = "mesonbuild";
              publisher = "mesonbuild";
              version = "1.7.1";
              sha256 = "sha256-odLTcgF+qkMwu53lr35tezvFnptox0MGl9n4pZ10JZo=";
            }
            {
              name = "xcode-keybindings";
              publisher = "stevemoser";
              version = "1.9.0";
              sha256 = "sha256-3wlXIvikzs2XiO9MzB0MbUYxkAKCDbTlv4lP9phAYYQ=";
            }
            {
              name = "aicursor";
              publisher = "ktiays";
              version = "0.3.2";
              sha256 = "sha256-Sx6r8sNarkdV2yJ4SmHQn5nu3yJFcWFR1qJzF0rHffY=";
            }
          ];
      })
    ];
  };
}
