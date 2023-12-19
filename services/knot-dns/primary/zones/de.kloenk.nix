{ dns, lib, common, ... }:

let inherit (common.mail) mxKloenk dmarcKloenk spfKloenk;
in with dns.combinators; {
  inherit (common.hosts.varda) A AAAA;
  inherit (common.records) CAA SOA NS;

  MX = mxKloenk;
  TXT = spfKloenk ++ [
    (ttl 3600 (txt
      "google-site-verification=p5ttbvvVzpqKQNUf_kuhwBEFvTavqiUF5BxTytUbGsY"))
  ];

  subdomains = rec {
    inherit (common.hosts) varda gimli;

    ns1 = varda;
    ns2 = gimli;

    mail = gimli;

    bitwarden = varda;
    auth = varda;

    # monitoring
    influx = varda;
    grafana = varda;

    net.subdomains = common.net // {
      acme = common.helpers.hostTTL 600 null "2a01:4f8:c013:1a4b:ecba:1337::1";
    };

    _github-challenge-cli-inc.TXT = [ (ttl 1200 (txt "a5adaebc78")) ];

    _dmarc.TXT = dmarcKloenk;

    drachensegler.MX = mxKloenk;
    drachensegler.TXT = spfKloenk;
    drachensegler.subdomains._dmarc.TXT = dmarcKloenk;

    ad.MX = mxKloenk;
    ad.TXT = spfKloenk;
    ad.subdomains._dmarc.TXT = dmarcKloenk;

    sc-social.CNAME = [ "starcitizen.social." ];

    bbb-wass.CNAME = [ "bbb.wass-er.com." ];
    knuddel-usee.CNAME = [ "stream.unterbachersee.de." ];
    moodle-usee.CNAME = [ "segelschule.unterbachersee.de." ];
    bbb-usee.CNAME = [ "schulungsraum.unterbachersee.de." ];
    pve-usee = common.helpers.hostTTL 1800 "5.9.118.73" "2a01:4f8:162:6343::2";

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
  };
}
