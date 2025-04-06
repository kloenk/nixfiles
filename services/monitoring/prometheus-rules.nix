[
  {
    alert = "InstanceDown";
    expr = "up == 0";
    for = "10m";
    labels = { severity = "warning"; };
    annotations = {
      summary = "WARN - {{ $labels.instance }} down";
      description = ''
        {{ $labels.instance }} has been down for more than 10 minutes.
      '';
    };
  }
  {
    alert = "InstanceDown";
    expr = "up == 0";
    for = "15m";
    labels = { severity = "critical"; };
    annotations = {
      summary = "CRIT - {{ $labels.instance }} down";
      description = ''
        {{ $labels.instance }} has been down for more than 15 minutes.
      '';
    };
  }
  {
    alert = "PingFailed";
    expr = "ping_result_code != 0";
    for = "15m";
    labels = { severity = "critical"; };
    annotations = {
      summary = "CRIT - ping to {{ $labels.url }} failed";
      description = ''
        Ping to {{ $labels.url }} fails for more than 15 minutes.
      '';
    };
  }
  {
    alert = "HighCPU";
    expr = "(cpu_usage_system + cpu_usage_user) > 85";
    for = "30m";
    labels = { severity = "warning"; };
    annotations = {
      summary = "WARN - CPU of {{ $labels.host }} has a high load";
      description = ''
        CPU has a high load for 30min
         Value: {{ $value }}
      '';
    };
  }
  {
    alert = "HighCPU";
    expr = "(cpu_usage_system + cpu_usage_user) > 85";
    for = "60m";
    labels = { severity = "critical"; };
    annotations = {
      summary = "CRIT - CPU of {{ $labels.host }} has a high load";
      description = ''
        CPU has a high load for 60min
         Value: {{ $value }}
      '';
    };
  }
  {
    alert = "LowStorage";
    expr = ''disk_used_percent{path!="/nix/store"} > 90'';
    for = "5m";
    labels = { severity = "warning"; };
    annotations = {
      summary = "WARN - Disk of {{ $labels.host }} is almost full";
      description = ''
        Disk is almost full
         Value: {{ $value }}
      '';
    };
  }
  {
    alert = "LowStorage";
    expr = ''disk_used_percent{path!="/nix/store"} > 95'';
    for = "5m";
    labels = { severity = "critical"; };
    annotations = {
      summary = "CRIT - Disk of {{ $labels.host }} is almost full";
      description = ''
        Disk is almost full
         Value: {{ $value }}
      '';
    };
  }
  {
    alert = "LowStoragePredict";
    expr = ''
      predict_linear(disk_free{path!="/nix/store", path!="/boot"}[1h], 5 * 3600) < 0'';
    for = "30m";
    labels = { severity = "warning"; };
    annotations = {
      summary = "WARN - Host disk of {{ $labels.host }} will fill in 5 hours";
      description = ''
        Disk will fill in 5 hours at current write rate
         Value: {{ $value }}
      '';
    };
  }
  {
    alert = "LowStoragePredict";
    expr = ''
      predict_linear(disk_free{path!="/nix/store", path!="/boot"}[1h], 3 * 3600) < 0'';
    for = "60m";
    labels = { severity = "critical"; };
    annotations = {
      summary = "CRIT - Host disk of {{ $labels.host }} will fill in 3 hours";
      description = ''
        Disk will fill in 3 hours at current write rate
         Value: {{ $value }}'';
    };
  }
  {
    alert = "LowMemory";
    expr = "mem_used_percent > 90";
    for = "5m";
    labels = { severity = "warning"; };
    annotations = {
      summary = "WARN - {{ $labels.host }} is low on system memory";
      description = ''
        {{ $labels.host }} is low on system memory
         Value: {{ $value }}
      '';
    };
  }
  {
    alert = "LowMemory";
    expr = "mem_used_percent > 95";
    for = "10m";
    labels = { severity = "critical"; };
    annotations = {
      summary = "CRIT - {{ $labels.host }} is low on system memory";
      description = ''
        {{ $labels.host }} is low on system memory
         Value: {{ $value }}
      '';
    };
  }
  {
    alert = "HostSystemdServiceCrashed";
    expr = ''systemd_units_active_code{active="failed"} > 0'';
    for = "5m";
    labels = { severity = "critical"; };
    annotations = {
      summary = "CRIT - A systemd unit on {{ $labels.host }} has failed";
      description = ''
        A systemd unit on {{ $labels.host }} has failed
         Value: {{ $value }}
      '';
    };
  }
  {
    alert = "HttpStatusCodeWrong";
    expr = "http_response_http_response_code != 200";
    for = "5m";
    labels = { severity = "critical"; };
    annotations = {
      summary = "CRIT - HTTP service {{ $labels.server }} responded incorrect";
      description = ''
        The HTTP service {{ $labels.service }} responded with {{ $value }} instead of 200.
      '';
    };
  }

  {
    alert = "VPNCertExpiryWarning";
    expr = ''(x509_cert_expiry{type="leaf"} / 60 / 60 / 24 / 7) < 5'';
    for = "5m";
    labels = { severity = "warning"; };
    annotations = {
      summary =
        "WARN - VPN Cert {{ $labels.common_name }} is near it's end of life";
      description = ''
        The VPN cert {{ $labels.common_name }} with SANs {{ $labels.san }} is expiring in {{ $value }} weeks.
      '';
    };
  }
  {
    alert = "VPNCertExpiryCritical";
    expr = ''(x509_cert_expiry{type="leaf"} / 60 / 60 ) < 7'';
    for = "5m";
    labels = { severity = "critical"; };
    annotations = {
      summary = "WARN - VPN Cert {{ $labels.common_name }} is end of life now";
      description = ''
        The VPN cert {{ $labels.common_name }} with SANs {{ $labels.san }} is expiring in {{ $value }} hours.
      '';
    };
  }

]
