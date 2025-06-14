{ pkgs, ... }:

{
  virtualisation = {
    podman = {
      enable = true;

      dockerCompat = true;
      dockerSocket.enable = true;

      defaultNetwork.settings.dns_enabled = true;

      extraPackages = with pkgs; [ btrfs-progs ];
    };
  };

  users.users.kloenk.extraGroups = [ "podman" ];

  virtualisation.oci-containers.backend = "podman";
}
