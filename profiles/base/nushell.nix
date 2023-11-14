{ pkgs, ... }:

{
  home-manager.users.kloenk = {
    programs.zoxide = { enable = true; };

    programs.nushell = {
      enable = true;
      extraConfig = ''
        source ${pkgs.nu_kloenk}/share/nu_scripts/kloenk.nu

        $env.config = ($env.config | upsert
          hooks {
            pre_prompt: [{ ||
              if (which direnv | is-empty) {
                return
              }

              direnv export json | from json | default {} | load-env
            }]
          })
      '';
    };
  };
}
