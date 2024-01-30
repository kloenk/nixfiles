{ ... }:

{
  home-manager.users.kloenk = {
    programs.zsh.initExtra = (builtins.readFile ./p10k.zsh) + ''
      eval "$(direnv hook zsh)"
    '';
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config.global.load_dotenv = false;
    };
  };
  home-manager.users.kloenk.home.sessionVariables.SSH_AUTH_SOCK =
    "/Users/kloenk/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh";
}
