{ config, pkgs, lib, ... }:

{
  users.users.kloenk.packages = with pkgs; [
    gnumake
    cmake
    rustup
    gdb
    gcc
    clang_12
    gawk
    openssl
    elfutils
  ];
}
