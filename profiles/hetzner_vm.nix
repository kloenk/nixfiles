{ ... }:

{
  # vm connection
  # services.qemuGuest.enable = true;

  # kernel module for graphics
  boot.initrd.kernelModules = [ "virtio_gpu" ];
  boot.kernelParams = [ "console=tty" ];
}
