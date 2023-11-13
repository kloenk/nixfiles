{ pkgs, ... }:

{
  home-manager.users.kloenk = {
    programs.nushell = {
      enable = true;
      extraConfig = "	source ${pkgs.nu_kloenk}/share/nu_scripts/kloenk.nu\n";
    };
  };
}
