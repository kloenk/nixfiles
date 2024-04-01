{ pkgs, ... }:

{
  systemd.network = {
    netdevs."40-guest" = {
      netdevConfig = {
        Kind = "vlan";
        Name = "guest";
      };
      vlanConfig.Id = 45;
    };
    networks."40-guest" = {
      name = "guest";
      DHCP = "no";
      addresses = [{ addressConfig.Address = "192.168.45.1/24"; }];
      hierarchyTokenBucketConfig = {
        Parent = "root";
        Handle = 2;
        DefaultClass = "00ff";
        # RateToQuantum = 20;
      };
      hierarchyTokenBucketClassConfig = [
        {
          hierarchyTokenBucketClassConfig = {
            Parent = "root";
            ClassId = "2:1";
            Rate = "20M";
            Priority = 1;
            MTUBytes = 1500;
            OverheadBytes = 100;
          };
        }

        # interactive
        {
          hierarchyTokenBucketClassConfig = {
            Parent = "2:1";
            ClassId = "2:10";
            Rate = "2M";
            CeilRate = "20M";
          };
        }

        # privileged port
        {
          hierarchyTokenBucketClassConfig = {
            Parent = "2:1";
            ClassId = "2:11";
            Rate = "1M";
            CeilRate = "20M";
          };
        }

        # default
        {
          hierarchyTokenBucketClassConfig = {
            Parent = "2:1";
            ClassId = "2:00ff";
            Rate = "1M";
            CeilRate = "20M";
          };
        }
      ];
      pfifoConfig = [
        {
          pfifoConfig = {
            Parent = "2:10";
            Handle = "10";
            PacketLimit = 10000;
          };
        }
        {
          pfifoConfig = {
            Parent = "2:11";
            Handle = "11";
            PacketLimit = 10000;
          };
        }
        {
          pfifoConfig = {
            Parent = "2:00ff";
            Handle = "00ff";
            PacketLimit = 10000;
          };
        }
      ];
    };

    networks."20-br0".vlan = [ "guest" ];
  };

  services.kea.dhcp4.settings = {
    interfaces-config.interfaces = [ "guest" ];
    subnet4 = [{
      pools = [{ pool = "192.168.45.50 - 192.168.45.150"; }];
      subnet = "192.168.45.0/24";
      option-data = [
        {
          name = "routers";
          data = "192.168.45.1";
        }
        {
          name = "domain-name-servers";
          data = "192.168.45.1";
        }
      ];
    }];
  };

  systemd.services.tc-filter-guest = {
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.copyPathToStore ./tc-filter-guest.sh;
      # ExecStop = "${pkgs.iproute2}/bin/tc filter del dev guest";
    };
    path = with pkgs; [ bash iproute2 ];
  };
}
