{ lib, ... }:

{
  disko.devices = {
    disk.nvme0n1 = {
      device = lib.mkDefault "/dev/sda";
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
            end = "100%";
            content = {
              type = "filesystem";
              format = "bcachefs";
              mountpoint = "/";
            };
          };
        };
      };
    };
  };
}
