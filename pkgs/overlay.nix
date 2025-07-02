inputs: final: prev:
let inherit (final) callPackage;
in {
  alterpcb-tlineslim = callPackage ./alterpcb-tlinesim { };

  wallpapers = callPackage ./wallpapers { };

  nu_kloenk = callPackage ./nu_scripts { };

  vemacs = callPackage ./vemacs { };
  vemacsMac = callPackage ./vemacs/mac.nix { };

  kloenk-emacs = callPackage ./emacs { emacs = final.emacs29-pgtk; };
  emacs-config = callPackage ./emacs-config { emacs = final.emacs29-pgtk; };

  emacsPackages = prev.emacsPackages
    // (prev.emacsPackages.callPackage ./emacsPackages { });

  partlint = callPackage ./partlint { };
  homebox = callPackage ./homebox { };

  inherit (callPackage ./kitchenowl { python3 = final.python312; })
    kitchenowl-backend kitchenowl-desktop kitchenowl-web;

  obs-tuna = final.qt6Packages.callPackage ./obs-tuna { };

  kernel_rootfs = import (final.path + "/nixos/lib/make-disk-image.nix") {
    config = (import (final.path + "/nixos/lib/eval-config.nix") {
      inherit (final) system;
      modules = [{ imports = [ ./kernel_rootfs.nix ]; }];
    }).config;
    pkgs = final;
    inherit (final) lib;
    diskSize = 4096;
    partitionTableType = "none";
    format = "qcow2";
  };

  b4 = prev.b4.overrideAttrs (oldAttrs: {
    version = "cover-strategy-notes";
    src = final.fetchFromGitLab {
      owner = "kloenk";
      repo = "b4";
      rev = "cover-strategy-notes";
      domain = "cyberchaos.dev";
      hash = "sha256-pTtW+3RYMj7Bt6pSXxVK8qxwaPpmY9QBr1TZ1Vi95zo=";
    };
  });

  # helix = prev.helix.overrideAttrs
  #   (oldAttrs: rec { patches = oldAttrs.patches ++ [ ./helix-etc.patch ]; });

  matrix-to = callPackage ./matrix-to { };

  update-ssh-host-keys = callPackage ./update-ssh-host-keys { };

  evremap = callPackage ./evremap { };

  strongswanTPM = prev.strongswan.overrideAttrs (oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [ final.tpm2-tss ];
    configureFlags = oldAttrs.configureFlags
      ++ [ "--enable-tpm" "--enable-tss-tss2" ];
  });

  #moodle = callPackage ./moodle { };
  part-db = callPackage ./part-db { };

  ubootElros = callPackage ./ubootElros { };

  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (py-final: py-prev: {
      django-dbbackup = py-final.callPackage ./python/django-dbbackup { };
      django-error-report-2 =
        py-final.callPackage ./python/django-error-report-2 { };
      django-flags = py-final.callPackage ./python/django-flags { };
      django-ical = py-final.callPackage ./python/django-ical { };
      django-markdownify = py-final.callPackage ./python/django-markdownify { };
      django-money = py-final.callPackage ./python/django-money { };
      django-q-sentry = py-final.callPackage ./python/django-q-sentry { };
      django-recurrence = py-final.callPackage ./python/django-recurrence { };
      django-slowtests = py-final.callPackage ./python/django-slowtests { };
      django-structlog = py-final.callPackage ./python/django-structlog { };
      django-stdimage = py-final.callPackage ./python/django-stdimage { };
      django-user-sessions =
        py-final.callPackage ./python/django-user-sessions { };
      django-weasyprint = py-final.callPackage ./python/django-weasyprint { };
      django-xforwardedfor-middleware =
        py-final.callPackage ./python/django-xforwardedfor-middleware { };
      pip-licenses = py-final.callPackage ./python/pip-licenses { };
      py-moneyed = py-final.callPackage ./python/py-moneyed { };
      pytest-pycodestyle = py-final.callPackage ./python/pytest-codestyle { };
      sentry-sdk = py-final.callPackage ./python/sentry-sdk { };
    })
  ];

  inventree = final.callPackage ./inventree { python3 = final.python312; };

  openocd-stm32h7rx = prev.openocd.overrideAttrs (oldAttrs: {
    patches = (oldAttrs.patches or [ ]) ++ [ ./openocd-stm32h7rx.diff ];
  });
}
