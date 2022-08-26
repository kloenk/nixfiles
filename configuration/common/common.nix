{ config, lib, pkgs, ... }:

{
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  ''; # recursive-nix progress-bar

  nix.gc.automatic = lib.mkDefault true;
  nix.gc.options = lib.mkDefault "--delete-older-than 7d";
  nix.registry.kloenk = {
    from.type = "indirect";
    from.id = "kloenk";
    #to.url = "git+https://git.kloenk.dev/kloenk/nix";
    to.type = "gitlab";
    to.repo = "nix";
    to.owner = "kloenk";
    to.host = "cyberchaos.dev";
    exact = false;
  };

  time.timeZone = "Europe/Berlin";

  environment.systemPackages = with pkgs; [
    exa
    fd
    ripgrep

    htop

  ];
}
