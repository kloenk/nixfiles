{ pkgs, ... }:

{
  home-manager.users.kloenk = {
    # Needed for nu_scripts background_task
    services.pueue = {
      enable = true;
      settings = { shared = { use_unix_socket = true; }; };
    };
    home.packages = [ pkgs.pueue ];

    programs.nushell = {
      enable = true;
      configFile.source = ./config.nu;
      envFile.source = ./env.nu;
      extraConfig = ''
        plugin add ${pkgs.nushellPlugins.query}/bin/nu_plugin_query;

        plugin use query;

        # Load kloenk nu config package
        source ${pkgs.nu_kloenk}/share/nu_scripts/kloenk.nu
      '';
    };

    programs.carapace = {
      enable = true;
      enableNushellIntegration = true;
    };
    programs.direnv.enableNushellIntegration = true;
    programs.zoxide.enableNushellIntegration = true;
    programs.atuin.enableNushellIntegration = true;
  };
}
