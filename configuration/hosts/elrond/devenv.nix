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
      "chromium"
      "chromium-unwrapped"
      "chrome-widevine-cdm"
    ];

  users.users.kloenk = {
    packages = with pkgs;
      [
        (vscode-with-extensions.override {
          vscodeExtensions = with vscode-extensions;
            [
              matklad.rust-analyzer
              bbenoist.nix
              ms-python.python
              ms-vscode-remote.remote-ssh
              vscodevim.vim
              bungcip.better-toml
              ms-vscode.cpptools
              ms-vscode.cmake-tools
              twxs.cmake
              github.copilot
              eamodio.gitlens
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
            ];
        })
      ];
  };
}
