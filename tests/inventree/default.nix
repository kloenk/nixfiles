{ self, nixosTest }:

nixosTest {
  name = "inventree";
  nodes = {
    server = {
      imports = [
        self.nixosModules.inventree
      ];
      services.inventree = {
        enable = true;
        hostName = "server";
      };
      services.nginx = {
        enable = true;
        virtualHosts."server".default = true;
      };
      system.stateVersion = "24.11";
    };
  };

  testScript = ''
  '';
}
