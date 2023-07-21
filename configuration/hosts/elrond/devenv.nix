{ config, pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "clion"
      "ruby-mine"
      "webstorm"
      "idea-ultimate"
      "datagrip"

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

  services.udev.extraRules = ''
    # Make an RP2040 in BOOTSEL mode writable by all users, so you can `picotool`
    # without `sudo`. 
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0003", MODE="0666"

    # Symlink an RP2040 running MicroPython from /dev/pico.
    #
    # Then you can `mpr connect $(realpath /dev/pico)`.
    SUBSYSTEM=="tty", ATTRS{idVendor}=="2e8a", ATTRS{idProduct}=="0005", SYMLINK+="pico"


    #picoprobe
    SUBSYSTEM=="usb", ATTRS{idVendor}=="2e8a", MODE="0666"

    #after adding this execute
    # sudo udevadm control --reload-rules &&  sudo udevadm trigger 
    # connect and disconnetc the USB device
  '';

  users.users.kloenk = {
    packages = with pkgs; [
      alacritty
      chatterino2
      schildichat-desktop-wayland
      gh
      sops
      blackbox-terminal

      rustup
      #gcc
      #clang

      cargo-generate
      bpf-linker

      jetbrains.clion
      jetbrains.ruby-mine
      jetbrains.webstorm
      jetbrains.idea-ultimate
      jetbrains.datagrip

      direnv
      elixir
      elixir_ls
      #nil
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
            ms-vscode.hexeditor

            phoenixframework.phoenix
            bradlc.vscode-tailwindcss

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
