{ config, pkgs, ... }:

{
    users.users.kloenk.packages = with pkgs; [ prismlauncher ];
    programs.firefox = {
        enable = true;
        languagePacks = [ "en-GB" "de" ];
    };
}