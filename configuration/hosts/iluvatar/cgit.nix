{ config, lib, pkgs, ... }:

let gitDir = "${config.services.gitolite.dataDir}/repositories";
in {
  #networking.firewall.allowedTCPPorts = [ 22 ];
  services.openssh.ports = [ 22 ];

  services.gitolite = {
    enable = true;
    user = "git";
    adminPubkey =
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBps9Mp/xZax8/y9fW1Gt73SkskcBux1jDAB8rv0EYUt cardno:000612029874";
    dataDir = "/persist/data/gitolite";
  };

  services.fcgiwrap.enable = true;

  services.nginx.gitweb.group = config.services.gitolite.group;
  services.nginx.virtualHosts."git.kloenk.dev" = {
    enableACME = true;
    forceSSL = true;
    root = "${pkgs.cgit}/cgit";

    #locations."/cgit.css".root    = ./cgit-assets;  
    locations."/".tryFiles = "$uri @cgit";
    locations."@cgit".extraConfig = ''
      include             ${pkgs.nginx}/conf/fastcgi_params;
      fastcgi_param       SCRIPT_FILENAME $document_root/cgit.cgi;
      fastcgi_param       PATH_INFO       $uri;
      fastcgi_param       QUERY_STRING    $args;
      fastcgi_param       HTTP_HOST       $server_name;
      fastcgi_pass        unix:/run/fcgiwrap.sock;
    '';
  };

  environment.etc.cgitrc.text = ''
        css=/cgit.css
        logo=/cgit.png
        virtual-root=/

        root-title=Kloenk's gcit
        root-desc=

        readme=:README.md
        about-filter=${pkgs.cgit}/lib/cgit/filters/about-formatting.sh

        snapshots=tar.gz tar.xz zip

        max-stats=quarter

        clone-url=https://git.kloenk.dev/$CGIT_REPO_URL git://git.kloenk.dev/$CGIT_REPO_URL ssh://git@git.kloenk.dev/$CGIT_REPO_URL

    		enable-index-links=1
        enable-commit-graph=1

        enable-log-filecount=1
        enable-log-linecount=1

        enable-http-clone=1
        enable-git-config=1
        
        mimetype.gif=image/gif
        mimetype.html=text/html
        mimetype.jpg=image/jpeg
        mimetype.jpeg=image/jpeg
        mimetype.pdf=application/pdf
        mimetype.png=image/png
        mimetype.svg=image/svg+xml

        #repos
        repo.url=kloenk/nix
        repo.path=${gitDir}/kloenk/nix.git
        repo.desc=NixOS configs
	      repo.owner=kloenk
        repo.readme=master:README.md

        repo.url=kloenk/mcc
        repo.path=${gitDir}/kloenk/mcc.git
        repo.desc=MC server in C (playground)
	      repo.owner=kloenk
        repo.readme=master:README.md

        repo.url=kloenk/Masui
        repo.path=${gitDir}/kloenk/Masui.git
        repo.desc=Masui Swift ui matrix client
	      repo.owner=kloenk
        repo.readme=main:README.md

        repo.url=kloenk/brook
        repo.path=${gitDir}/kloenk/brook.git
        repo.desc=A minimal self-hostable streaming setup.
	      repo.owner=kloenk
        repo.readme=master:README.md

        repo.url=kloenk/touchcraft
        repo.path=${gitDir}/kloenk/touchcraft.git
        repo.desc=Touchbar mod for minecraft.
	repo.owner=kloenk
        repo.readme=master:README.md

        repo.url=kloenk/naapple
        repo.path=${gitDir}/kloenk/naapple.git
        repo.desc=napster to apple music converter.
	repo.owner=kloenk
        repo.readme=master:README.md

        repo.url=facharbeit
        repo.path=${gitDir}/facharbeit.nix
        repo.desc=Files for my Facharbeit 
	repo.owner=kloenk
        repo.readme=master:README.md

        repo.url=linux/rust/kloenk
        repo.path=${gitDir}/linux/rust/kloenk.git
        repo.desc=Linux Kernel with rust support
        repo.readme=rust:README

        repo.url=linux/wireless/kloenk
        repo.path=${gitDir}/linux/wireless/kloenk.git
        repo.desc=Linux Kernel with wireless patches
        repo.readme=master:README

        repo.url=llg/companion
        repo.path=${gitDir}/llg/companion.git
        repo.desc=Legacy LLG companion website

        repo.url=llg/rust/backend
        repo.path=${gitDir}/llg/rust/backend.git
        repo.desc=Rust Backend/library for llg companion
        repo.readme=main:README.md

        repo.url=usee/osp-nix
        repo.path=${gitDir}/usee/osp-nix.git
        repo.desc=Nixconfig files for the osp server
	repo.owner=USee
        repo.readme=main:README.md

        repo.url=usee/rtmp-auth
        repo.path=${gitDir}/usee/rtmp-auth.git
        repo.desc=rtmp auth server for nginx
	repo.owner=USee
        repo.readme=main:README.md

        repo.url=trudeltiere/DasMupfel/remote
        repo.path=${gitDir}/trudeltiere/DasMupfel/remote.git
        repo.owner=Trudeltiere
        repo.desc=remote controll for Das Mupfel
        repo.readme=main:README.md

        repo.url=trudeltiere/DasMupfel/monitor
        repo.path=${gitDir}/trudeltiere/DasMupfel/monitor.git
        repo.owner=Trudeltiere
        repo.desc=monitor for Das Mupfel
        repo.readme=main:README.md
      '';
}
