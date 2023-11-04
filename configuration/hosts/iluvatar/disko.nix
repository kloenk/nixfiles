{ lib, ... }:

{
  disko.devices = {
    disk.vda = {
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
            end = "-10G";
            content = {
              type = "filesystem";
              format = "bcachefs";
              mountpoint = "/";
              # extraArgs = [ "-m reflink=1" ];
            };
          };
          swap = {
            name = "swap";
            size = "100%";
            content = {
              type = "swap";
            };
          };
        };
      };
    };
  };
}