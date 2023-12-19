{ dns, lib, common, ... }:

with dns.combinators; {
  inherit (common.hosts.varda) A AAAA;
  inherit (common.records) CAA SOA NS;

  MX = common.mail.mxKloenk;

  TXT = common.mail.spfKloenk;

  subdomains = rec {
    www = common.hosts.varda;

    _dmarc.TXT = common.mail.dmarcKloenk;

    _domainkey.subdomains.mail.TXT = [
      (txt ''
        v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDeP0+6Zzo+No/So3XAH2+ow7+6B4JyCK4TvLlfxu3OPvFaqom/OvCkQLRJY9bii4Rxw8XECFczvBs9Y+AhfK8miR87Ibg94/9n/jpYzZm7BoyKwZlayA3G62abULw6znEGu+OfKpnoKHIAiJbjlRuZUj/8Z7HsUAFXoPkTJzCEWQIDAQAB'')
    ];
  };
}
