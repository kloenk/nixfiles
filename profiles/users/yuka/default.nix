{ ... }:

{
  users.users.yuka = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBAED3qfSH1VgSevkOta7Oy7/y/YZKnT84YbOIclxAvTU6q+rmEvw9zRNRyKMuHmChCmYBnT6iCI+Y3YsnXg4ummgawH5ZpjzxPtvuRZBl9W928dFuDYvTQf2WFpyCRdAHjZEGxrltfpaLl3PEwidOSucpQ9WWBHPI3niRojd8wCciMfEsA=="
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGbzUmOJuuAYn/3ODyw3WKjz7SnKjMq4iHE+mEpwVVmw"
    ];
  };
}
