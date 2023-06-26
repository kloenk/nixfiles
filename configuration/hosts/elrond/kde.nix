{ conifg, pkgs, lib, ... }:

{
  environment.plasma5.excludePackages = [];

  environment.systemPackages = with pkgs; [
  ] ++ (with pkgs.plasma5Packages; [
    tokodon sddm-kcm qtvirtualkeyboard
    plasma-applet-virtual-desktop-bar
    oxygen oxygen-icons5 oxygen-sounds
    lightly

    ksudoku ksquares kspaceduel kreversi konquest kollision
    knights klines kmahjongg kmines knavalbattle killbots
    bomber kapman kbreakout kpat

    krohnkite bismuth ktorrent kmail kalendar
    kontact konversation korganizer kcalc
    kleopatra neochat discover

    akonadi akonadi-calendar akonadi-calendar-tools
    akonadi-contacts akonadi-import-wizard akonadi-mime
    akonadi-notes akonadi-search akonadiconsole

    kdeconnect-kde
  ]);
  services.flatpak.enable = true;
  #services.packagekit.enable = true;

  # allow KDE Connect
  networking.firewall = {
    allowedTCPPortRanges = [ { from = 1714; to = 1764; } ];
    allowedUDPPortRanges = [ { from = 1714; to = 1764; } ];
  };

  environment.variables = {
    NIXOS_OZONE_WL = "1";
  };

  i18n.inputMethod.enabled = "ibus";
  i18n.inputMethod.ibus = {
    panel = "${pkgs.plasma5Packages.plasma-desktop}/lib/libexec/kimpanel-ibus-panel";
    engines = with pkgs.ibus-engines; [ mozc hangul libpinyin ];
  };
  programs.gnupg.agent.pinentryFlavor = lib.mkForce "qt";
  qt.platformTheme = "kde";

  services.xserver.enable = true;
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  programs.ssh.askPassword = lib.mkForce "${pkgs.ksshaskpass}/bin/ksshaskpass";
}