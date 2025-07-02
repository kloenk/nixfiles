{ config, pkgs, lib, ... }:

{
  systemd.network = { networks."85-eth" = { DHCP = "yes"; }; };
}
