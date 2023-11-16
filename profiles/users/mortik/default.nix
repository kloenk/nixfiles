{ pkgs, ... }:

{
  users.users.mortik = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAXD00rxKUl7pTkOj30JQ4umRpnaole62xdQLgUi2YeX"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDyVyNl9gvnnBqbIc7QuCmVC/tTwnbs7VxzvsRCEWX3R"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBVvWjPcrOhVS/otpHyCeJ7dY7qGOkO79BnP+0XZLhej"
    ];

    packages = with pkgs; [ htop ];
  };
}
