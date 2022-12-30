{ inputs, config, lib, ... }:

let
  dns = inputs.dns.lib.${config.nixpkgs.system}.dns;

  mxKloenk = with dns.combinators.mx;
    map (dns.combinators.ttl 3600) [ (mx 10 "gimli.kloenk.dev.") ];
  dmarc = with dns.combinators;
    [ (txt "v=DMARC1;p=reject;pct=100;rua=mailto:postmaster@kloenk.dev") ];
  spfKloenk = with dns.combinators.spf;
    map (dns.combinators.ttl 600) [
      (strict [
        #"a:kloenk.dev"
        #"a:mail.kloenk.dev"
        "a:gimli.kloenk.dev"
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
      nameServer = "ns1.kloenk.dev.";
      adminEmail = "hostmaster.kloenk.dev."; # TODO: change mail
      serial = 2021010141;
      refresh = 600;
      expire = 604800;
      minimum = 600;
    });

    NS = [ "ns2.he.net." "ns4.he.net." "ns3.he.net." "ns5.he.net." ];

    /* A = map (ttl 600) [ (a "195.39.247.6") ];

       AAAA = map (ttl 600) [ (aaaa "2a0f:4ac0::6") ];
    */
    A = map (ttl 600) [ (a "49.12.72.200") ];
    AAAA = map (ttl 600) [ (aaaa "2a01:4f8:c012:b874::") ];
    #CNAME = [ "iluvatar.kloenk.dev." ];

    TXT = spfKloenk ++ [
      "google-site-verification=Zi_9C2hSucoEJhLD78ijxMaybtjscN0D3t5TNpoeg6Y"
    ];
    MX = mxKloenk;
    CAA = letsEncrypt config.security.acme.email;

    subdomains = rec {
      iluvatar.CNAME = [ "kloenk.dev." ];
      #manwe = hostTTL 1200 "195.39.221.187" null;
      #gimli.CNAME = [ "gimli.wolfsburg.petabyte.dev." ];
      gimli = iluvatar; #hostTTL 1200 "195.39.247.182" "2a0f:4ac0:0:1::cb2";

      usee-nschl = hostTTL 1200 "5.9.118.93" "2a01:4f8:162:6343::3";

      ns1 = iluvatar;

      #cgit = iluvatar;
      #cache = iluvatar;

      # SourceHut
      /* todo = iluvatar;
         paste = iluvatar;
         meta = iluvatar;
         man = iluvatar;
         lists = iluvatar;
         hub = iluvatar;
         hg = iluvatar;
         dispatch = iluvatar;
         builds = iluvatar;
      */

      _dmarc.TXT = dmarc;

      drachensegler.MX = mxKloenk;
      drachensegler.TXT = spfKloenk;
      drachensegler.subdomains._dmarc.TXT = dmarc;

      bitwarden = iluvatar;

      social = iluvatar;

      grafana = manwe;
      influx = manwe;

      matrix = gimli // { subdomains.api = gimli; };
      mail = gimli;

      knuddel-usee.CNAME = [ "stream.unterbachersee.de." ];
      moodle-usee.CNAME = [ "segelschule.unterbachersee.de." ];
      bbb-usee.CNAME = [ "schulungsraum.unterbachersee.de." ];
      event.CNAME = [ "event.unterbachersee.de." ];
      pve-usee = host "5.9.118.73" "2a01:4f8:162:6343::2";

      bbb = hostTTL 600 "195.39.221.27" "2001:678:bbc::27";

      matrix-push.subdomains.dev = iluvatar;
      matrix-push.CNAME = iluvatar.CNAME;

      mx-redir.CNAME = iluvatar.CNAME;

      _domainkey.subdomains.mail.TXT = [
        (txt ''
          v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC5KMotmbfWWCLUgFeUc87fO2Heie+Ye1VPELqGhX60br1VyMnhzCc0uR1Hdjt9ts6ykemyIBBHwRa/GfJnyQq+u6nk0v9kDuNs2E3EftcHpYA1E0LCPs5Wl6d2q50IwKt609XiZWok+C/0hnG7gjYTzI6T2a6vhL7hoQfTpLZJCQIDAQAB'')
      ];
      drachensegler.subdomains._domainkey.subdomains.mail.TXT = [
        (txt ''
          v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCl1K0nT6nViifArMweC+/SHsekNCGuTOaXvkGVabr+aAC/56d2brxocLoVeVBDVMdY6PkQ9BCNMYVWPuw1n78LXH+dRoyezulp5124scitz2daGQT6MaeWAGYKJHw8aZQj6c5ahxJJHEOkGx6/o1E2UO3LvKpXxxldyAoGnHe7MwIDAQAB'')
      ];

      rssr.subdomains = { engel = manwe; };
    };
  };

in dns.writeZone "kloenk.dev" zone
