{ lib, pkgs, config, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    "steam"
    "steam-original"
    "steam-runtime"
    "steamcmd"
  ];

  environment.systemPackages = with pkgs; [
    steam-run
    steamcmd
  ];
}
