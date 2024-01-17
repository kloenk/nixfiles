{ dns, lib, common, ... }:

let inherit (common.mail) mxKloenk dmarcKloenk spfKloenk;
in with dns.combinators; {
  inherit (common.hosts.varda) A AAAA SSHFP;
  inherit (common.records) CAA SOA NS;

  MX = mxKloenk;
  TXT = spfKloenk;

  subdomains = rec {
    inherit (common.hosts) varda gimli;

    ns1 = varda;
    ns2 = gimli;

    mail = gimli;

    bitwarden = varda;
    auth = varda;

    net.subdomains = common.net;

    _dmarc.TXT = dmarcKloenk;

    _domainkey.subdomains.mail.TXT = [
      (txt ''
        v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC5KMotmbfWWCLUgFeUc87fO2Heie+Ye1VPELqGhX60br1VyMnhzCc0uR1Hdjt9ts6ykemyIBBHwRa/GfJnyQq+u6nk0v9kDuNs2E3EftcHpYA1E0LCPs5Wl6d2q50IwKt609XiZWok+C/0hnG7gjYTzI6T2a6vhL7hoQfTpLZJCQIDAQAB'')
    ];
  };
}
