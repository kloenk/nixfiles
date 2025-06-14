{ ... }:

{
  disko.devices = {
    disk.vda = {
      device = "/dev/sda";
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
                "/persist/data/netbox" = { };
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
