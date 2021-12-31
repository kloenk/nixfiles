{ config, lib, pkgs, ... }:

{
  nix.trustedUsers = [ "root" "@wheel" "kloenk" ];
  # nix flakes
  #nix.package = lib.mkDefault pkgs.nixFlakes;
  # darwin?? should have it to
  #nix.systemFeatures = [ "recursive-nix" "kvm" "nixos-test" "big-parallel" ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes ca-references recursive-nix progress-bar
  '';

  nix.gc.automatic = lib.mkDefault true;
  nix.gc.options = lib.mkDefault "--delete-older-than 7d";

  # binary cache
  nix.binaryCachePublicKeys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
  nix.binaryCaches = [
  #  "https://nix-community.cachix.org/"
  ];
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
