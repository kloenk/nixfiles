{ self, lib, ... }:

{
  programs.ssh.knownHosts = let
    hostNames = (attrs:
      builtins.filter (name: (name != "defaults")) (builtins.attrNames attrs))
      self.nixosConfigurations;
    filteredHostNames = builtins.filter
      (name: (builtins.pathExists (self + "/hosts/${name}/ssh.pub"))) hostNames;
    hostKeyForHost = host: {
      name = host;
      value = {
        hostNames = let hostNames = [ "${host}" "${host}.net.kloenk.de" ];
        in [ "[${lib.concatStringsSep "," hostNames}]:62954" ];
        publicKeyFile = self + "/hosts/${host}/ssh.pub";
      };
    };
    hostKeys = builtins.listToAttrs (map hostKeyForHost filteredHostNames);
  in hostKeys // {
    varda-dns = {
      hostNames = [ "[kloenk.de,varda.kloenk.de]:62954" ];
      publicKeyFile = self + "/hosts/varda/ssh.pub";
    };
    gimli-dns = {
      hostNames = [ "[gimli.kloenk.de]:62954" ];
      publicKeyFile = self + "/hosts/gimli/ssh.pub";
    };
  };
}
