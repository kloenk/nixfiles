{ config, lib, pkgs, ... }:

{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  ''; # recursive-nix progress-bar

  nix.settings.trusted-users = [ "root" "@wheel" "kloenk" ];
  # binary cache
  nix.settings.trusted-public-keys = [
    "kloenk.cachix.org-1:k52XSkCLOxnmEnjzuedYOzf0MtQp8P3epqOmAlCHYpc="
    #"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
  nix.settings.substituters = [
    "https://kloenk.cachix.org"
    #"https://nix-community.cachix.org/"
  ];

  nix.gc.automatic = lib.mkDefault true;
  nix.gc.options = lib.mkDefault "--delete-older-than 7d";
  nix.registry.kloenk = {
    from.type = "indirect";
    from.id = "kloenk";
    to.type = "gitlab";
    to.repo = "nix";
    to.owner = "kloenk";
    to.host = "cyberchaos.dev";
    exact = false;
  };

  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    eza
    fd
    ripgrep

    htop

  ];
}
