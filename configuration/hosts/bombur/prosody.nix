{ lib, pkgs, config, ... }:

{
  networking.firewall.allowedTCPPorts = [
    5269 # s2s
    5280 # http
    5281 # https
    5222 # c2s
    5223 # c2s legacy ssl
    5000 # proxy65
  ];

  users.users.nginx.extraGroups = [ "prosody" ];
  security.acme.certs."prosody-unterbachersee.de" = {
    domain = "stream.unterbachersee.de";
    webroot = config.security.acme.certs."stream.unterbachersee.de".webroot;
    group = config.security.acme.certs."stream.unterbachersee.de".group;
    postRun =
      "rm -rf /var/lib/prosody-unterbachersee.de; cp -r /var/lib/prosody/cert /var/lib/prosody/cert && chown prosody -R /var/lib/prosody/cert && systemctl restart prosody";
  };

  services.prosody = {
    enable = true;
    dataDir = "/var/lib/prosody";
    admins =
      [ "kloenk@stream.unterbachersee.de" "admin@stream.unterbachersee.de" ];
    allowRegistration = false;

    modules = { server_contact_info = true; };

    package = (pkgs.prosody.overrideAttrs (oldAttrs: {
      communityModules = pkgs.fetchhg {
        url = "https://hg.prosody.im/prosody-modules";
        rev = "362997ededb1";
        sha256 = "1xkzszhzbyzw6q4prcvs164blm6k87bhn12zm4cwwbv9cd0fbhkv";
      };
    })).override {
      withCommunityModules = [
        "prometheus"
        "measure_client_features"
        "measure_client_identities"
        "measure_client_presence"
        "measure_cpu"
        "measure_memory"
        "measure_message_e2ee"
        "measure_stanza_counts"
        "csi_battery_saver"
      ];
    };
    ssl.key = "/var/lib/prosody/cert/key.pem";
    ssl.cert = "/var/lib/prosody/cert/fullchain.pem";
    /* virtualHosts = {
         "stream.unterbachersee.de" = {
           domain = "stream.unterbachersee.de";
           enabled = true;
         };
       };
    */

    extraConfig = ''
      contact_info = {
        abuse = { "mailto:holger@wass-er.com", "xmpp:holger@stream.unterbachersee.de" };
        admin = { "mailto:holger@wass-er.com", "xmpp:holger@stream.unterbachersee.de" };
        feedback = { "https://segelschule.unterbachersee.de", "mailto:holger@wass-er.com", "xmpp:holger@stream.unterbachersee.de" };
        sales = { "mailto:holger@wass-er.com" };
        security = { "xmpp:holger@stream.unterbachersee.de" };
        support = { "https://segelschule.unterbachersee.de", "mailto:holger@wass-er.com", "xmpp:holger@stream.unterbachersee.de" };
      };
    '';

    # disable xmpp warnigns
    xmppComplianceSuite = false;
    /* contact_info = {
          abuse = { "mailto:xmpp-abuse@petabyteboy.de", "xmpp:petabyteboy@petabyteboy.de" };
          admin = { "mailto:xmpp-admin@petabyteboy.de", "xmpp:petabyteboy@petabyteboy.de" };
          feedback = { "https://petabyte.dev/", "mailto:xmpp-feedback@petabyteboy.de", "xmpp:petabyteboy@petabyteboy.de" };
          sales = { "xmpp:petabyteboy@petabyteboy.de" };
          security = { "xmpp:petabyteboy@petabyteboy.de" };
          support = { "https://petabyte.dev/", "xmpp:petabyteboy@petabyteboy.de", "mailto:xmpp-support@petabyteboy.de" };
        }
    */
  };

  services.nginx.virtualHosts."knuddel-usee.kloenk.de" = {
    locations."/prosody-exporter/".proxyPass = "http://localhost:5280/";
    locations."/prosody-exporter/".extraConfig =
      config.services.nginx.virtualHosts."knuddel-usee.kloenk.de".locations."/node-exporter/".extraConfig;
  };

}
