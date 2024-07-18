{ self, nixosTest }:

nixosTest {
  name = "kitchenowl-backend";
  nodes = {
    server = {
      imports = [ self.nixosModules.kitchenowl ];
      services.kitchenowl = {
        enable = true;
        hostName = "server";
      };
      services.nginx = { enable = true; };
      system.stateVersion = "24.11";
    };
  };

  testScript = ''
    server.start()
    server.wait_for_unit("kitchenowl-backend.service")
    server.succeed("curl --fail http://server/api/health/8M4F88S8ooi4sMbLBfkkV7ctWwgibW6V")
  '';
}
