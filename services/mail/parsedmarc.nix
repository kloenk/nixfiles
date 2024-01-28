{ config, ... }:

{
  services.parsedmarc = {
    enable = true;
    provision = {
      geoIp = false;
      elasticsearch = false;
    };

    settings = {
      general = {
        nameservers = "localhost";
        output = "/run/parsedmarc/output";
        aggregate_json_filename = "aggregate.json";
      };
      imap = {
        user = "dmarc@kloenk.dev";
        password._secret =
          config.sops.secrets."mail/services/parsedmarc/password".path;
      };
      smtp = { to = [ ]; };
    };
  };

  sops.secrets."mail/services/parsedmarc/password".owner = "root";
}
