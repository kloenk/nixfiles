{ lib, ... }:

{
  disko.devices = {
    disk.internal-ssd = {
      device = lib.mkDefault "/dev/disk/by-path/pci-0000:00:1f.2-ata-1.0";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            name = "esp";
            size = "512M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            end = "-16G";
            content = {
              type = "btrfs";
              subvolumes = {
                "/rootfs" = { mountpoint = "/"; };
                "/nix" = {
                  mountOptions = [ "compress=zstd" "noatime" ];
                  mountpoint = "/nix";
                };
                "/home" = {
                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/home";
                };
                "/home/kloenk" = { };
                "/persist" = {
                  mountOptions = [ "compress=zstd" ];
                  mountpoint = "/persist";
                };
              };

              mountpoint = "/.partition-root";
            };
          };
          swap = {
            name = "swap";
            size = "100%";
            content.type = "swap";
          };
        };
      };
    };
  };
}
