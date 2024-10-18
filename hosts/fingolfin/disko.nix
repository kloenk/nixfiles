{ ... }:

{
  disko.devices = {
    disk.vda = {
      device = "/dev//dev/disk/by-path/pci-0000:06:00.0-scsi-0:0:0:1";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            name = "esp";
            size = "256M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "defaults" ];
            };
          };
          root = {
            name = "root";
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
    disk.moodle = {
      device = "/dev/disk/by-path/pci-0000:06:00.0-scsi-0:0:0:2";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          moodle = {
            name = "moodle";
            content = {
              type = "btrfs";
              subvolumes = {
                "/moodle" = {
                  mountpoint = "/persist/moodle";
                  mountOptions = [ "compress=zstd" "noatime" ];
                };
              };

              mountpoint = "/.partition-moodle";
            };
          };
        };
      };
    };
  };
}
