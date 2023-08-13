{ pkgs, options, lib, config, ... }:

{
  imports = [ ./atuin.nix ];

  environment.systemPackages = with pkgs; [ fzf exa ripgrep direnv atuin ];

  programs.nushell = {
    enable = true;

    nativeCheckInputs = [ pkgs.atuin ];

    config = options.programs.nushell.config.default // {
      show_banner = false;
    };

    dirs.libs = [
      "${pkgs.nu_kloenk}/share/nu_scripts/commands"
      "${pkgs.nu_kloenk}/share/nu_scripts/completions"
    ];

    extraConfig = ''
      source ${pkgs.nu_kloenk}/share/nu_scripts/kloenk.nu
      source ${pkgs.nu_kloenk}/share/nu_scripts/config/atuin.nu
    '';
  };
}
