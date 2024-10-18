{ dns, lib, common, ... }:

let inherit (common.mail) mxKloenk dmarcKloenk spfKloenk;
in with dns.combinators; {
  inherit (common.hosts.varda) A AAAA SSHFP;
  inherit (common.records) CAA SOA NS;

  MX = mxKloenk;
  TXT = spfKloenk ++ [
    (ttl 600 (txt
      "google-site-verification=p5ttbvvVzpqKQNUf_kuhwBEFvTavqiUF5BxTytUbGsY"))
  ];

  subdomains = rec {
    inherit (common.hosts) varda vaire gimli fingolfin;

    ns1 = varda;
    ns2 = gimli;

    mail = gimli;
    rspamd = gimli;

    bitwarden = varda;
    auth = varda;

    # monitoring
    prometheus = varda;
    alertmanager = varda;
    grafana = varda;

    netbox = varda;
    kitchenowl = vaire;

    net.subdomains = common.net // {
      acme = common.helpers.host { v6 = "2a01:4f8:c013:1a4b:ecba:1337::1"; };
    };

    _github-challenge-cli-inc.TXT = [ (ttl 1200 (txt "a5adaebc78")) ];

    _dmarc.TXT = dmarcKloenk;

    drachensegler.MX = mxKloenk;
    drachensegler.TXT = spfKloenk;
    "_dmarc.drachensegler".TXT = dmarcKloenk;

    ad.MX = mxKloenk;
    ad.TXT = spfKloenk;
    "_dmarc.ad".TXT = dmarcKloenk;

    sc-social.CNAME = [ "starcitizen.social." ];

    bbb-wass.CNAME = [ "bbb.wass-er.com." ];
    knuddel-usee.CNAME = [ "stream.unterbachersee.de." ];
    moodle-usee.CNAME = [ "segelschule.unterbachersee.de." ];
    "telegraf.moodle-usee".CNAME = [ "moodle-usee.kloenk.de." ];
    bbb-usee.CNAME = [ "schulungsraum.unterbachersee.de." ];
    pve-usee = common.helpers.host {
      ttl = 1800;
      v4 = "5.9.118.73";
      v6 = "2a01:4f8:162:6343::2";
    };

    "burscheid.home" = {
      subdomains.ns1 = common.helpers.host {
        ttl = 1800;
        v4 = "192.168.178.248";
      };
      NS = [ "ns1.burscheid.home.kloenk.de." ];
    };

    _domainkey.subdomains.mail.TXT = [
      (txt ''
        v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJ5QgJzy63zC5f7qwHn3sgVrjDLaoLLX3ZnQNbmNms4+OJxNgBlb9uqTNqCEV9ScUX/2V+6IY2TqdhdWaNBif+agsym2UvNbCpvyZt5UFEJsGFoccNLR4iDkBKr8uplaW7GTBf5sUfbPQ2ens7mKvNEa5BMCXQI5oNa1Q6MKLjxwIDAQAB'')
    ];
    ad.subdomains._domainkey.subdomains.mail.TXT = [
      (txt ''
        v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC9prC9mhToqsOTwauczmv3hQdsO2n5mE2hJdl8O/VnLxHJV7WZrfyUhT8WO++4jY25e0SJ0Hlv1LFX9WbQMD7oqUIeb5iLzoAAHsPros/obfDqFX7tRMzVKcrOF5zmhV/HD8U/3MRNH2Cj7/tid564qw0i4XuXYgxHl/ow5c7OHwIDAQAB'')
    ];
    drachensegler.subdomains._domainkey.subdomains.mail.TXT = [
      (txt ''
        v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDEEgSIeGxjIT5+HqaHlVTt0hL1QPYcidXeJsUgOa1bzfSybD/S0n9tNZidjr+pw2lResdZlyIJ7ozjBMp8MqD0mDDaRwqmy1jTQIFjSDwIORkjRzz4T+m6o3xAcpNrsvfbiOAj02EP5+1OF+0Y6YkdNWeZ2z2/XmL6eoTAYocRuQIDAQAB'')
    ];

    _dmarc.subdomains = let
      allowDMARC = domain: {
        name = "${domain}._report";
        value.TXT = [ "v=DMARC1" ];
      };
      allowDMARCs = domains: lib.listToAttrs (map allowDMARC domains);
    in allowDMARCs [
      "kloenk.de"
      "ad.kloenk.de"
      "drachensegler.kloenk.de"
      "drachensegler.kloenk.dev"
      "kloenk.dev"
      "kloenk.eu"
      "p3tr1ch0rr.de"
      "sysbadge.dev"
    ];
  };
}
