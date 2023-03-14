{ config, pkgs, lib, ... }:

{
    users.users.kloenk.packages = with pkgs; [ prismlauncher discord ];


    
    programs.firefox = {
        enable = true;
        languagePacks = [ "en-GB" "de" ];
    };
}