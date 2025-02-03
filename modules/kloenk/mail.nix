{ lib, config, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkOption types mkIf;

  cfg = config.k.mail;

  mu4eConfigPackage = epkgs:
    epkgs.trivialBuild {
      pname = "kloenk-mu4e-values";
      src = pkgs.writeText "kloenk-mu4e-values.el" (cfg.mu4e.extraConfig + ''

        (provide 'kloenk-mu4e-values)'');
      version = "0.1.0";
      packagesRequired = [ epkgs.mu4e ] ++ (cfg.mu4e.extraPackages epkgs);
    };

  mu4e-ml-options = { name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        default = name;
      };

      id = mkOption {
        type = types.str;
        default = name;
      };

      archive = mkOption {
        type = types.nullOr (types.either types.str types.bool);
        default = null;
      };
    };
  };

  mu4e-context = { name, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        readOnly = true;
      };

      hm = mkOption {
        type = types.attrs;
        readOnly = true;
      };

      vars = mkOption {
        type = types.attrs;
        default = { };
      };
    };
    config =
      let hm = config.home-manager.users.kloenk.accounts.email.accounts.${name};
      in {
        inherit name hm;
        vars = {
          "user-mail-address" = hm.address;
          "user-full-name" = hm.realName;
          "mu4e-drafts-folder" = "/${name}/${hm.folders.drafts}";
          "mu4e-sent-folder" = "/${name}/${hm.folders.sent}";
          # "mu4e-refile-folder" = "/${name}/${hm.folders.archive}";
          "mu4e-trash-folder" = "/${name}/${hm.folders.trash}";
        };
      };
  };
in {
  options = {
    k.mail = {
      enable = mkEnableOption "MU4e emacs support";

      mu4e = {
        extraPackages = mkOption {
          type = types.functionTo (types.listOf types.package);
          default = _: [ ];
        };

        extraConfig = mkOption {
          type = types.lines;
          default = "";
        };

        mailinglists = {
          generic = mkOption {
            type = types.attrsOf (types.submodule mu4e-ml-options);
            default = { };
          };

          vger = mkOption {
            type = types.attrsOf (types.submodule mu4e-ml-options);
            default = { };
          };
        };

        context = mkOption {
          type = types.attrsOf (types.submodule mu4e-context);
          default = { };
        };

        shortcuts = mkOption {
          type = types.attrsOf types.str;
          default = { };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    k.emacs.extraPackages = epkgs: [ epkgs.mu4e (mu4eConfigPackage epkgs) ];

    k.mail.mu4e.extraConfig = # elisp
      ''
        ;(require 'mu4e)
        (defvar kloenk-mail/nix-mailing-lists '() "List of mailing lists configured via nix")
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList (_name: attrs:
          ''
            (add-to-list 'kloenk-mail/nix-mailing-lists '(:list-id "${attrs.id}" :name "${attrs.name}" ${
              if (attrs.archive != null || attrs.archive != false) then
                " :archive ${attrs.archive}"
              else
                ""
            }))'') cfg.mu4e.mailinglists.generic)}

        (defun kloenk-mail/nix-setup-mu4e-context ()
          ${
            lib.concatStringsSep "\n" (lib.mapAttrsToList (_name: ctx: ''
                  (add-to-list 'mu4e-contexts
              	     (make-mu4e-context
              	      :name "${ctx.name}"
              	      :enter-func (lambda () (mu4e-message "Enter ${ctx.name} context"))
              	      :leave-func (lambda () (mu4e-message "Leave ${ctx.name} context"))
              	      :match-func
              	      (lambda (msg)
                      		(when msg
                      		  (string-prefix-p "/${ctx.name}" (mu4e-message-field msg :maildir))))
                      	      :vars '(
                                ${
                                  lib.concatStringsSep "\n" (lib.mapAttrsToList
                                    (name: value: ''(${name} . "${value}")'')
                                    ctx.vars)
                                })))
            '') cfg.mu4e.context)
          }
                )

        (defun kloenk-mail/nix-setup-mu4e-shortcuts ()
         (setq mu4e-maildir-shortcuts '(
         ${
           lib.concatStringsSep "\n"
           (lib.mapAttrsToList (name: key: ''("${name}" . ?${key})'')
             cfg.mu4e.shortcuts)
         })))
      '';

    k.mail.mu4e.mailinglists.generic = (lib.mapAttrs' (_name: attrs: {
      name = "${attrs.id}.vger.kernel.org";
      value = {
        name = attrs.name;
        id = if (lib.strings.hasSuffix "vger.kernel.org" attrs.id) then
          attrs.id
        else
          "${attrs.id}.vger.kernel.org";
        archive = if attrs.archive != null then
          attrs.archive
        else # elisp
        ''
          					  (lambda (msg)
            						(let *
            							((base-url "https://lore.kernel.org/${attrs.id}/")
            							 (msg-id (mu4e-message-field msg :message-id)))
            							(concat base-url msg-id)))
        '';
      };
    }) cfg.mu4e.mailinglists.vger);
  };
}
