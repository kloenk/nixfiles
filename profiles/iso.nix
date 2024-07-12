{ modulesPath, lib, config, pkgs, self, ... }:

{
  imports = [
    (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix")

    #./hetzner_vm.nix

    ./base/nixos
  ];

  system.extraDependencies = [
    self.nixosConfigurations.strider.config.system.build.toplevel
    self.nixosConfigurations.strider.config.system.build.diskoScript
  ];

  boot.initrd.supportedFilesystems = lib.mkForce [ "vfat" ];
  boot.initrd.kernelModules = [ "sr_mod" ];
  boot.supportedFilesystems = lib.mkForce [ "cifs" "vfat" "xfs" ];
  # boot.loader.grub.enable = true;
  # boot.loader.systemd-boot.enable = true;

  #boot.initrd.systemd.enable = true;
  #boot.initrd.systemd.emergencyAccess = true;

  networking.wireless.iwd.enable = true;
  networking.wireless.enable = lib.mkForce false;
  networking.useDHCP = true;
  services.getty.autologinUser = lib.mkForce "kloenk";

  /* boot.initrd.systemd.services.mkdir-rw-store = {
       description = "Store Overlay Mutable Directories";
       wantedBy = [ "sysroot-nix-store.mount" ];
       before = [ "sysroot-nix-store.mount" ];
       unitConfig.RequiresMountsFor = "/sysroot/nix/.rw-store";
       serviceConfig = {
         Type = "oneshot";
         RemainAfterExit = true;
       };
       script = ''
         mkdir -p /sysroot/nix/.rw-store/{work,store}
       '';
     };

     lib.isoFileSystems = {
       "/iso" = lib.mkOverride 5 {
       #device = null;
       label = config.isoImage.volumeID;
       fsType = "auto";
       neededForBoot = true;
       noCheck = true;
       };
       "/nix/.ro-store" = lib.mkOverride 5 {
         fsType = "squashfs";
         device = "/sysroot/iso/nix-store.squashfs";
         options = [ "loop" ];
         neededForBoot = true;
       };
     };
  */
}

