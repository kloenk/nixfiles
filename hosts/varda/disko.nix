{ lib, ... }:

{
  disko.devices = {
    disk.vda = {
      device = lib.mkDefault "/dev/disk/by-path/pci-0000:06:00.0-scsi-0:0:0:1";
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
            size = "100%";
            content = {
              type = "btrfs";
              subvolumes = {
                "rootfs" = {
                  mountpoint = "/";
                  mountOptions = [ "compress=zstd" ];
                };
                "/home" = {
                  mountpoint = "/home";
                  mountOptions = [ "compress=zstd" ];
                };
                "/home/kloenk" = { };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
                "/swap" = {
                  mountpoint = "/.swapvol";
                  swap.swapfile.size = "2G";
                };
              };

              mountpoint = "/.partition-root";
            };
          };
        };
      };
    };
  };
}
