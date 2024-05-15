{ ... }:

{
  disko.devices = {
    disk.emmc = {
      device = "/dev/disk/by-path/platform-fe2e0000.mmc";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          esp = {
            name = "esp";
            size = "512M";
            start = "11M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            #  end = "-16G";
            content = {
              type = "btrfs";
              subvolumes = {
                "/rootfs".mountpoint = "/";
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

              mountpoint = "/partition-root";
            };
          };
        };
      };
    };
  };
}
