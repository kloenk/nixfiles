let
  spf =
    "v=spf1 a:gimli.kloenk.de ip4:49.12.72.200/32 ip6:2a01:4f8:c012:b874::/128 -all";
  dmarc = "v=DMARC1;p=reject;pct=100;rua=mailto:postmaster@kloenk.de";
  caa = {
    data = [
      {
        flags = 0;
        tag = "issue";
        value = ''"letsencrypt.org"'';
      }
      {
        flags = 0;
        tag = "issuewild";
        value = ''";"'';
      }
      {
        flags = 0;
        tag = "iodef";
        value = ''"mailto:hostmaster@kloenk.de"'';
      }
    ];
  };
in {
  defaultTTL = 1800;
  zones = {
    "kloenk.eu" = {
      "" = {
        inherit caa;
        ns.data = [
          "hydrogen.ns.hetzner.com"
          "oxygen.ns.hetzner.com"
          "helium.ns.hetzner.de"
        ];
      };
    };
    "kloenk.de" = {
      "" = {
        mx.data.exchange = "gimli.kloenk.de";
        mx.data.preference = 10;
        inherit caa;
        txt.data = [
          spf
          "google-site-verification=p5ttbvvVzpqKQNUf_kuhwBEFvTavqiUF5BxTytUbGsY"
        ];
        ns.data = [
          "hydrogen.ns.hetzner.com"
          "oxygen.ns.hetzner.com"
          "helium.ns.hetzner.de"
        ];
      };
      "_dmarc".txt.data = dmarc;
      "mail._domainkey".txt.data = ''
        v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDJ5QgJzy63zC5f7qwHn3sgVrjDLaoLLX3ZnQNbmNms4+OJxNgBlb9uqTNqCEV9ScUX/2V+6IY2TqdhdWaNBif+agsym2UvNbCpvyZt5UFEJsGFoccNLR4iDkBKr8uplaW7GTBf5sUfbPQ2ens7mKvNEa5BMCXQI5oNa1Q6MKLjxwIDAQAB'';
      "ad" = {
        mx.data.exchange = "gimli.kloenk.de";
        mx.data.preference = 10;
        txt.data = [ spf ];
      };
      "_dmarc.ad".txt.data = dmarc;
      "mail._domainkey.ad".txt.data = ''
        v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC9prC9mhToqsOTwauczmv3hQdsO2n5mE2hJdl8O/VnLxHJV7WZrfyUhT8WO++4jY25e0SJ0Hlv1LFX9WbQMD7oqUIeb5iLzoAAHsPros/obfDqFX7tRMzVKcrOF5zmhV/HD8U/3MRNH2Cj7/tid564qw0i4XuXYgxHl/ow5c7OHwIDAQAB'';
      "drachensegler" = {
        mx.data.exchange = "gimli.kloenk.de";
        mx.data.preference = 10;
        txt.data = [ spf ];
      };
      "_dmarc.drachensegler".txt.data = dmarc;
      "mail._domainkey.drachensegler".txt.data = ''
        v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDEEgSIeGxjIT5+HqaHlVTt0hL1QPYcidXeJsUgOa1bzfSybD/S0n9tNZidjr+pw2lResdZlyIJ7ozjBMp8MqD0mDDaRwqmy1jTQIFjSDwIORkjRzz4T+m6o3xAcpNrsvfbiOAj02EP5+1OF+0Y6YkdNWeZ2z2/XmL6eoTAYocRuQIDAQAB'';
      "frodo.net" = {
        a.data = "192.168.242.201";
        aaaa.data = "2a01:4f8:c013:1a4b:ecba::201";
      };
      "pve-usee" = {
        a.data = "5.9.118.73";
        aaaa.data = "2a01:4f8:162:6343::2";
      };
    };
    "sysbadge.dev" = {
      "" = {
        a.data = [
          "185.199.108.153"
          "185.199.109.153"
          "185.199.110.153"
          "185.199.111.153"
        ];
        aaaa.data = [
          "2606:50c0:8000::153"
          "2606:50c0:8001::153"
          "2606:50c0:8002::153"
          "2606:50c0:8003::153"
        ];
        ns.data = [
          "hydrogen.ns.hetzner.com"
          "oxygen.ns.hetzner.com"
          "helium.ns.hetzner.de"
        ];
      };
      "_github-pages-challenge-sysbadge-org".txt.data = "d6f90acfda";
    };
    "p3tr1ch0rr.de" = {
      "" = {
        mx.data.exchange = "gimli.kloenk.de";
        mx.data.preference = 10;
        txt.data = [ spf ];
        inherit caa;
        ns.data = [
          "hydrogen.ns.hetzner.com"
          "oxygen.ns.hetzner.com"
          "helium.ns.hetzner.de"
        ];
      };
      "_dmarc".txt.data = dmarc;
      "mail._domainkey".txt.data = ''
        v=DKIM1; k=rsa; " "p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDeP0+6Zzo+No/So3XAH2+ow7+6B4JyCK4TvLlfxu3OPvFaqom/OvCkQLRJY9bii4Rxw8XECFczvBs9Y+AhfK8miR87Ibg94/9n/jpYzZm7BoyKwZlayA3G62abULw6znEGu+OfKpnoKHIAiJbjlRuZUj/8Z7HsUAFXoPkTJzCEWQIDAQAB'';
    };
  };
}
