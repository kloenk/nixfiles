{ config, lib, pkgs, ... }:

{
  imports = [
    #./postgres.nix
    ./zsh.nix
    ./aerospace.nix

    #../../common/nushell.nix
    ../../profiles/desktop/wezterm.nix
    ../../profiles/desktop/emacs.nix
    ../../profiles/desktop/mail.nix

    ../../profiles/base/darwin
  ];

  environment.systemPackages = with pkgs; [
    #pkgs.vim
    wezterm
    eza
  ];

  networking.hostName = "frodo";

  # wezterm font size
  k.programs.wezterm.font_size = 13.0;
  k.emacs.gui = true;
  k.emacs.package = pkgs.emacs;

  services.nix-daemon.enable = true;
  nix = {
    package = pkgs.nix;
    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
      system-features = benchmark big-parallel recursive-nix
    '';
    /* linux-builder = {
         #enable = true;
         maxJobs = 4;
       };
    */
  };

  home-manager.users.kloenk.programs.ssh.matchBlocks = {
    "*.studs.math.uni-wuppertal.de" = {
      port = 22;
      user = "fbehrens";
    };
    "*.studs" = {
      hostname = "%h.math.uni-wuppertal.de";
      port = 22;
      user = "fbehrens";
    };
    "l???" = {
      hostname = "%h.math.uni-wuppertal.de";
      port = 22;
      user = "fbehrens";
    };
  };
  home-manager.users.kloenk.services.syncthing.enable = true;
  home-manager.users.kloenk.home.file.".local/share/wallpapers".source =
    "${pkgs.wallpapers}/share/wallpapers";
  home-manager.users.kloenk.home.file.".local/share/wallpapers".recursive =
    true;

  users.users.kloenk.packages = with pkgs; [
    elixir
    erlang
    pkg-config
    gh
    glab
    evcxr
    #neomutt
    go
    nil
    #chatterino2
    direnv
    nushell
    uutils-coreutils
    yt-dlp

    #wireguard-tools
    #wireguard-go

    # emacs language servers
    elixir_ls
    irony-server
    sbcl
    sops

    git # xcode-select fails because of DEVELOPER_DOR

    dfu-util
    ffmpeg

    mpc-cli
    ario

    sqlite-web

    nixfmt
    darwin.iproute2mac
    pwgen
    # kloenk-emacs-mac
  ];

  services.epmd.enable = true;
  services.telegraf = { enable = false; };

  ids.gids.nixbld = 30000;

  security.pam.enableSudoTouchIdAuth = true;

  system.stateVersion = 6;
}
