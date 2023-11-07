{ lib, ... }@args:

{
  nix = {
    extraOptions = ''
      experimental-features = nix-command flakes
      builders-use-substitutes = true
    '';
    settings = {
      trusted-users = [ "root" "@wheel" "kloenk" ];
      trusted-public-keys = [
        "kloenk.cachix.org-1:k52XSkCLOxnmEnjzuedYOzf0MtQp8P3epqOmAlCHYpc="
      ];
      substituters = [
        "https://kloenk.cachix.org"
      ];
    };
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
    registry = {
      kloenk = {
        from.type = "indirect";
        from.id = "kloenk";
        to.type = "gitlab";
        to.host = "cyberchaos.dev";
        to.owner = "kloenk";
        to.repo = "nix";
        exact = false;
      };
      nixpkgs.flake = args.inputs.nixpkgs;
    };
  };
}