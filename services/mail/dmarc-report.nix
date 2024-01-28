{ config, ... }:

{
  services.prometheus.exporters.dmarc = {
    enable = true;
    listenAddress = "127.0.0.1";
    imap = {
      username = "dmarc@kloenk.dev";
      host = config.mailserver.fqdn;
      passwordFile = "$CREDENTIALS_DIRECTORY/imap";
    };
  };
  systemd.services.prometheus-dmarc-exporter.serviceConfig.LoadCredential =
    [ "imap:${config.sops.secrets."mail/services/dmarc/password".path}" ];

  services.telegraf.extraConfig.inputs.prometheus = [{
    urls = [
      "http://localhost:${
        toString config.services.prometheus.exporters.dmarc.port
      }/metrics"
    ];
  }];

  sops.secrets."mail/services/dmarc/password".owner = "root";
}
