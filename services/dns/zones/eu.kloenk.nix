{ inputs, config, lib, ... }:

let
  dns = inputs.dns.lib.${config.nixpkgs.system}.dns;

  mxKloenk = with dns.combinators.mx;
    map (dns.combinators.ttl 3600) [ (mx 10 "gimli.kloenk.de.") ];
  dmarc = with dns.combinators;
    [ (txt "v=DMARC1;p=reject;pct=100;rua=mailto:postmaster@kloenk.de") ];
  spfKloenk = with dns.combinators.spf;
    map (dns.combinators.ttl 600) [
      (strict [
        #"a:kloenk.dev"
        #"a:mail.kloenk.dev"
        "a:gimli.kloenk.de"
        "ip4:49.12.72.200/32"
        "ip6:2a01:4f8:c012:b874::/64"
      ])
    ];

  hostTTL = ttl: ipv4: ipv6:
    lib.optionalAttrs (ipv4 != null) {
      A = [{
        address = ipv4;
        inherit ttl;
      }];
    } // lib.optionalAttrs (ipv6 != null) {
      AAAA = [{
        address = ipv6;
        inherit ttl;
      }];
    };

  zone = with dns.combinators; {
    SOA = ((ttl 600) {
      nameServer = "ns1.kloenk.eu.";
      adminEmail = "hostmaster.kloenk.de.";
      serial = 2021010148;
      refresh = 600;
      expire = 604800;
      minimum = 600;
    });

    NS = [ "ns2.he.net." "ns4.he.net." "ns3.he.net." "ns5.he.net." ];

    A = map (ttl 600) [ (a "168.119.57.172") ];
    AAAA = map (ttl 600) [ (aaaa "2a01:4f8:c013:1a4b::") ];

    TXT = spfKloenk ++ [
      "google-site-verification=Zi_9C2hSucoEJhLD78ijxMaybtjscN0D3t5TNpoeg6Y"
    ];
    MX = mxKloenk;
    CAA = letsEncrypt config.security.acme.email;

    subdomains = rec {
      iluvatar.CNAME = [ "kloenk.eu." ];

      gimli = hostTTL 1200 "49.12.72.200" "2a01:4f8:c012:b874::";
      ns1 = gimli;

      uptime = iluvatar;

      _dmarc.TXT = dmarc;

      drachensegler.MX = mxKloenk;
      drachensegler.TXT = spfKloenk;
      drachensegler.subdomains._dmarc.TXT = dmarc;

      social = iluvatar;

      atuin = iluvatar;

      grafana = iluvatar;
      influx = iluvatar;
      sysbadge = iluvatar;

      matrix = gimli // { subdomains.api = gimli; };
      mail = gimli;

      knuddel-usee.CNAME = [ "stream.unterbachersee.de." ];
      moodle-usee.CNAME = [ "segelschule.unterbachersee.de." ];
      bbb-usee.CNAME = [ "schulungsraum.unterbachersee.de." ];
      event.CNAME = [ "event.unterbachersee.de." ];
      pve-usee = host "5.9.118.73" "2a01:4f8:162:6343::2";

      _github-pages-challenge-Kloenk.TXT = [ "93721bf4d3b9ab1d6af40409424d90" ];

      _domainkey.subdomains.mail.TXT = [
        (txt ''
          v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC5KMotmbfWWCLUgFeUc87fO2Heie+Ye1VPELqGhX60br1VyMnhzCc0uR1Hdjt9ts6ykemyIBBHwRa/GfJnyQq+u6nk0v9kDuNs2E3EftcHpYA1E0LCPs5Wl6d2q50IwKt609XiZWok+C/0hnG7gjYTzI6T2a6vhL7hoQfTpLZJCQIDAQAB'')
      ];
      drachensegler.subdomains._domainkey.subdomains.mail.TXT = [
        (txt ''
          v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCl1K0nT6nViifArMweC+/SHsekNCGuTOaXvkGVabr+aAC/56d2brxocLoVeVBDVMdY6PkQ9BCNMYVWPuw1n78LXH+dRoyezulp5124scitz2daGQT6MaeWAGYKJHw8aZQj6c5ahxJJHEOkGx6/o1E2UO3LvKpXxxldyAoGnHe7MwIDAQAB'')
      ];

    };
  };

in dns.writeZone "kloenk.eu" zone
