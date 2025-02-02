;;; poly-markdown.el --- Polymode for markdown-mode -*- lexical-binding: t -*-
;;
;; Author: Fiona Behrens
;; Maintainer: Fiona Behrens
;; Copyright (C) 2025
;; Version: 0.0.1
;; Package-Requires: ((emacs "30") (polymode "0.2.2") (nix-mode))
;; URL: https://cyberchaos.dev/kloenk/nix
;; Keywords: emacs, nix
;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This file is *NOT* part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.
;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:
;;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Code:

(require 'polymode)
(require 'poly-lock)
(require 'nix-mode)

(defvar poly-nix-enable-lang-opts t
  "Enable parsing of extra language options")
					;(defvar poly-nix-lang-opts '(("sh" . (poly-nix-lang--sh))))
(defvar poly-nix-lang-opts '())

(define-hostmode poly-nix-hostmode
		 :mode 'nix-mode)

(define-innermode poly-nix-root-innermode
		  :mode nil
		  :fallback-mode 'host
		  :head-mode 'host
		  :tail-mode 'host)


(defun poly-nix--doublequote-mode-matcher ()
  (when (re-search-forward "#\s*\\(?:lang\s*=\s*\\)?\\([^ \t\n;=,}]+\\)" (pos-eol) t)
    (let*
	((str (match-string-no-properties 1))
	 (mode (pm-get-mode-symbol-from-name str))
	 (args (poly-nix--doublequote-mode-matcher--args))
	 )
      (when poly-nix-enable-lang-opts
	(let
	    ((opts-fns (cdr (assoc str poly-nix-lang-opts))))
	  (dolist (fn opts-fns)
	    (if (functionp fn)
	      (funcall fn args)))))
      mode)))

(defun poly-nix--doublequote-mode-matcher--args ()
  (let (args)
  (while (re-search-forward "\s*\\([^ \t;,=]+\\)\\(?:=\\([^ \t;,]+\\)\\)?" (pos-eol) t)
    (let
	((name (match-string-no-properties 1))
	 (arg (match-string-no-properties 2)))
      (if arg
	    (setq args (cons (cons name arg) args))
	    (setq args (cons name args)))))
  args))

(define-auto-innermode poly-nix-doublequote-innermode poly-nix-root-innermode
		       :head-matcher (cons "=\s*\\(#\s*[[:alpha:]]+.*\n\s*''\s*\n\\)" 1)
		       :tail-matcher (cons "^\s*\\('';\\)\t*$" 1)
		       :mode-matcher #'poly-nix--doublequote-mode-matcher
		       :body-indent-offset 2
		       :protect-indent t
		       :protect-font-lock t
		       :protect-syntax t)

(defun poly-nix--inline-nix-head-matcher (count)
  (when (re-search-forward "[^']\\(\${\\)" nil t count)
    (cons (match-beginning 0) (match-end 0))))

(defun poly-nix--inline-nix-tail-matcher (_count)
  (when (re-search-forward "\\(?:{[^}]*}\\)*\\(}\\)" nil t)
    (cons (match-beginning 0) (match-end 0))))

(define-innermode poly-nix-inline-nix-innermode poly-nix-root-innermode
  :mode 'nix-mode
  :head-matcher #'poly-nix--inline-nix-head-matcher
  :tail-matcher #'poly-nix--inline-nix-tail-matcher
  :can-nest t)

;;;###autoload (autoload 'poly-nix-mode "poly-nix")
(define-polymode poly-nix-mode
		 :hostmode 'poly-nix-hostmode
		 :innermodes '(poly-nix-doublequote-innermode
			       ;poly-nix-inline-nix-innermode ;; broken currently
			       ))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.nix\\'" . poly-nix-mode))

(provide 'poly-nix)


