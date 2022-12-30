{ extraGroups ? [ ] }:

{ pkgs, ... }:

{
  users.users.schluempfli = {
    isNormalUser = true;
    #extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQD1U2lbVQZLxjKrbXfwcPdFDlnqkxm2A+Q/yXv5J/HwzmQfrted75T/iRTfRU84clLdRwEp2PB2Ro+ElZFpMKTT+hP8L/CTpOodeEWS8FOqfz9w7qHDKTV3IpVDkDlBc5JAdD59OWj+zyYYYM/YRvm0OUPn/JdKe0uwdHrVPFOxGWxrdz78zK39MOeDZnBwU94g9dp0aX6tTWTcqXkuLul/1n1booSBvKfLCakwCfTM3iqTD8JBkYjQW23niy0EyJK7QqtEIkuvlkFF6yY+G44NBQQB3w3Z2Y5tiwz3/LLZG9AGlWVAWA2irucNzm6+DysPBuAc66VEzeBmp3RCWtzqSCBlcUxjL3CnX0KiHZxegCCOxjcifG7OxyH9QyNSdAjUQJUUcZsl7rf9JViDgqT6N95vzRAHPVZhVju0yry+k5WwMUVfSg77qH/xLNKIBp870w2UCOR7QxvIsj1+uX4+mQOOMDk5sTauJo9333MfwNK3MF/p09p0hVfMR2bFdxje+KDzVANQgjA27GjIUfdSyxFU2jDYvWhP4s2eKvd4Dyu2/NGnJS4KdU6vo7rf/K80AtH8Jp0tpNeR3bvblYJYcoLLd9qFEJ2eGiLFuTBNb64SqdOoBd8P4gBQ8uS751UNZ8YNkJTA/0LmXVLcirg0tishnlac5mpEP8/utJkcvw== cardno:000606914775"
    ];
    packages = with pkgs; [ vim ripgrep htop nano ];
    inherit extraGroups;
  };
}
