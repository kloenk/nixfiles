{ ... }:

{
  disko.devices = {
    disk.vda = {
      device = "/dev/disk/by-path/virtio-pci-0000:00:06.0";
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
          btrfs = {
            name = "root";
            content = {
              type = "btrfs";
              extraArgs = [ "-f" ];
              subvolumes = {
                "/rootfs" = {
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
                  swap.swapfile.size = "8G";
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
