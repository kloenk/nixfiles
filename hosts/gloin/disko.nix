{ lib, ... }:

{
  disko.devices = {
    disk.nvme0n1 = {
      device = lib.mkDefault "/dev/disk/by-path/pci-0000:04:00.0-nvme-1";
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
              type = "filesystem";
              format = "bcachefs";
              mountpoint = "/";
            };
          };
          swap = {
            name = "swap";
            size = "100%";
            content = { type = "swap"; };
          };
        };
      };
    };
  };
}
