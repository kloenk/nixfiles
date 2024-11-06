{ lib, pkgs, config, ... }:

{
  boot.supportedFilesystems = [ "cifs" ];
  fonts.fontconfig.localConf = lib.fileContents ./fontconfig.xml;
  fonts.fontconfig.defaultFonts = {
    emoji = [ "Noto Color Emoji" ];
    serif = [ "DejaVu Serif" ];
    sansSerif = [ "DejaVu Sans" ];
    monospace = [ "JetBrains Mono 8" ];
  };
  fonts.packages = with pkgs; [
    noto-fonts-emoji
    dejavu_fonts
    fira-mono
    unifont
    roboto
    jetbrains-mono
    font-awesome
    meslo-lgs-nf
    inter
    monaspace
    #questrial-regular
  ];

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    libusb-compat-0_1
    lm_sensors
    wl-clipboard
    xdg-utils

    #bluetooth
    overskride
  ];

  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=2 exclusive_caps=1
  '';

  services.fwupd.enable = true;

  environment.variables.MOZ_USE_XINPUT2 = "1"; # for firefox

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;
  services.udisks2.enable = true;
  programs.gnome-disks.enable = true;
  programs.kdeconnect.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  users.users.kloenk.packages = with pkgs; [
    fractal
    _1password-cli
    _1password-gui
  ];
  home-manager.users.kloenk = {
    xdg.enable = true;
    gtk = {
      enable = true;
      iconTheme.name = "Adwaita";
      iconTheme.package = pkgs.adwaita-icon-theme;
      theme = {
        name = "Adwaita";
        package = pkgs.gnome-themes-extra;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-font-name = "DejaVu Sans 11";
      };
      gtk4.extraConfig = { gtk-application-prefer-dark-theme = 1; };
    };
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-gnome3;
      enableExtraSocket = true;
      sshKeys = [ ];
    };

    programs.zsh = {
      initExtra = ''
        eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
        eval "$(direnv hook zsh)"
      '';
      shellAliases = { };
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.global.load_dotenv = false;
    };

    xdg.configFile."mimeapps.list".force = true;
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
        "x-scheme-handler/about" = [ "firefox.desktop" ];
        "x-scheme-handler/unknown" = [ "firefox.desktop" ];
        "image/avif" = [ "org.gnome.eog.desktop" ];
        "image/jpeg" = [ "org.gnome.eog.desktop" ];
        "image/png" = [ "org.gnome.eog.desktop" ];
        "image/svg+xml" = [ "org.gnome.eog.desktop" ];
        "application/pdf" = [ "org.gnome.Evince.desktop" ];
      };
    };
  };

  services.printing = {
    enable = true;
    drivers = [ pkgs.gutenprint ];
  };
  # programs.steam.enable = true;
}
