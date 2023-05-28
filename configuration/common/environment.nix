{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    config = {
      color.ui = true;
      init.defaultBranch = "main";
      user = {
        email = "me@kloenk.dev";
        name = "Finn Behrens";
      };
      alias = { ls = "status"; };
    };
  };

  programs.ssh = {
    pubkeyAcceptedKeyTypes = [ "ecdsa-sha2-nistp256" ];
    extraConfig = ''
      Host *.kloenk.de
        Port 62954

      Host *.kloenk.dev
        Port 62954

      Host *.nyantec.com
        ForwardAgent yes
        User fin

      Host *.studs.math.uni-wuppertal.de
        Port 22
        User fbehrens
        ControlPersist 24h

      Host *.studs
        Hostname %h.math.uni-wuppertal.de
        Port 22
        User fbehrens
        ControlPersist 24h

      Host l???
        Hostname %h.studs.math.uni-wuppertal.de
        Port 22
        User fbehrens
        ControlPersist 24h

      Host cyberchaos.dev
        Port 62954
        Host cyberchaos.dev
        ForwardAgent no
        RequestTTY no

      Host *
        ForwardAgent no
        HashKnownHosts no
        UserKnownHostsFile ~/.ssh/known_hosts
    '';
  };

  programs.ssh.knownHosts = {
    # kloenk hosts
    iluvatar = {
      hostNames = [ "iluvatar.kloenk.dev" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGG/JUDF8AlBFDGcBeE877HPM7UlblTz23BDa69imU8t
      '';
    };
    thrain = {
      hostNames = [ "192.168.178.248" ];
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/2kA6GZfQ/laY7hrzXJeM9WGuzHFtcpgbQLXGyiHqC";
    };

    cyberchaos = {
      hostNames = [ "cyberchaos.dev" ];
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB994/Dz2G4vKDYeC1PQ445OKaaJLWdM6I+PBvHRDLa5";
    };

    fleetyards_staging = {
      hostNames = [ "fleetyards.dev" ];
      publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPxwVNbqCyHNwN/jCSAZlpDkiGof8BdtaSBbHpyB55tE";
    };
    fleetyards_prod = {
      hostNames = [ "fleetyards.net" ];
      publicKey =
        " ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDnP3Tvyvk3hoZLOuFVokhu37tCXODGxHhVlCRtllAZW";
    };

    # Nyantec hosts
    airlink-release = {
      hostNames = [ "airlink-release.nyantec.com" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPFzjsPo8wPgfGQcPjcQEyexU/cIfuHD6Vud8PkwrCuH root@release
      '';
    };
    assets = {
      hostNames = [ "assets.nyantec.com" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG5+4Vh5qrwH+pAUK0l2S0jJYeXgm45yXRrc2elfQ83t mak@build-worker-01
      '';
    };
    build-worker-03 = {
      hostNames = [ "build-worker-03.nyantec.com" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEGqTY74c5g15DSNPNM2Wdr5jAwS7BFgX1XRnhtGOnJc root@build-worker-03
      '';
    };
    build-worker-04 = {
      hostNames = [ "build-worker-04.nyantec.com" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICOq+5I+nlAN2lJoOtoXrYEDuZ/TMPMa43pIlablYigK root@build-worker-04
      '';
    };
    dns = {
      hostNames = [ "dns.nyantec.com" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzcUGbuTRD7ouyQ5ANLZ7McVhGR4L8klIk0nB8EDXRJ mak@build-worker-01
      '';
    };
    lab = {
      hostNames = [ "lab.nyantec.com" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIUePtVPtBK+CYosufbaGiMT4EVanti4V5t2Wg0g/Fy4 root@lab
      '';
    };
    matrix = {
      hostNames = [ "matrix.nyantec.com" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIATLzEyuovqIhDx9MTz6C0fy8YjpD5j9HGg0YdGSF1VA root@nixos
      '';
    };
    meet = {
      hostNames = [ "meet.nyantec.com" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFr/cW8N2yolN7nwxLWuFEOWn+VYNQlS20qXe3G+JwHD root@meet
      '';
    };
    monitor = {
      hostNames = [ "monitor.nyantec.com" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDT7sFQhXx/MMblGAJTXD1k4xDb7j8olA7UeLHe9iL3n root@mon
      '';
    };
    pad = {
      hostNames = [ "pad.nyantec.com" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINB02teGdpJseAnenYoZY0X7/dOCHFrJPAFaXo6DFpgm root@pad
      '';
    };
    resolve = {
      hostNames = [ "resolve.nyantec.com" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBAKHude3wL828MNvsLIb0RM2hJK/ns5D9pq7ZxIOz+y mak@build-worker-04
      '';
    };
    share = {
      hostNames = [ "share.nyantec.com" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDTctajLC5IXQSIxDp3xTD9YovUXAytBCVVXsy9jeOz/ mak@build-worker-04
      '';
    };
    web = {
      hostNames = [ "web.nyantec.com" ];
      publicKey = ''
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHojFXD/BnsCSlWh+Ynnt5KVaRBpECq/3prx2c14kH+T root@web
      '';
    };
  };

  programs.vim = {
    defaultEditor = true;
    package = (pkgs.vim_configurable.override { }).customize {
      name = "vim";
      # Install plugins for example for syntax highlighting of nix files
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [ vim-nix vim-lastplace rust-vim tabular vim-elixir ];
        opt = [ ];
      };
      vimrcConfig.customRC = ''
        set viminfo='20,<1000
        set shiftwidth=2
        "set cc=80
        set nu

        " Uncomment the following to have Vim jump to the last position when
        " reopening a file
        if has("autocmd")
          au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
        endif

        " Move temporary files to a secure location to protect against CVE-2017-1000382
        if exists('$XDG_CACHE_HOME')
          let &g:directory=$XDG_CACHE_HOME
        else
          let &g:directory=$HOME . '/.cache'
        endif

        let &g:undodir=&g:directory . '/vim/undo//'
        let &g:backupdir=&g:directory . '/vim/backup//'
        let &g:directory.='/vim/swap//'
        " Create directories if they doesn't exist
        if ! isdirectory(expand(&g:directory))
          silent! call mkdir(expand(&g:directory), 'p', 0700)
        endif
        if ! isdirectory(expand(&g:backupdir))
          silent! call mkdir(expand(&g:backupdir), 'p', 0700)
        endif
        if ! isdirectory(expand(&g:undodir))
          silent! call mkdir(expand(&g:undodir), 'p', 0700)
        endif
        " Turn on syntax highlighting by default
        syntax on
        " ...
      '';
    };
  };

  programs.gnupg = {
    agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

}
