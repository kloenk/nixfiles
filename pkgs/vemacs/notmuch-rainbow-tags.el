;;; notmuch-rainbow-tags.el --- Distinct Background Colours for Notmuch Rags

;; Copyright (C) 2020 Condition-ALPHA

;; Author: Alexander Adolf <open-source@condition-alpha.com>
;; Maintainer: Alexander Adolf <open-source@condition-alpha.com>
;; Version: 1.0
;; Keywords: mail, notmuch
;; Homepage: https://condition-alpha.com
;; Package-Requires: ((notmuch "20210205.1412") (emacs "24.3"))

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;    This library sets a distinct background colour for each notmuch
;;    tag, which helps to more quickly discern the tags on screen.  A
;;    hash is computed over each tag string, and the value is used to
;;    set the tag's background colour.  Hence, the colour for any
;;    given tag string will alwyas be the same.

;;    This library is a simpler (IMHO) alternative to notmuch-labeler
;;    (https://github.com/DamienCassou/notmuch-labeler), and it is
;;    (shamelessly) inspired by astroid mail
;;    (https://astroidmail.github.io).

;;; Usage:
;;    (require 'notmuch-rainbow-tags)
;;    (notmuch-rainbow-tags-global-mode)

;;; Code:

(require 'notmuch)

(defgroup notmuch-rainbow-tags nil
  "Give each `notmuch' tag a distinct background colour.

The colour mapping uses a hash value of the tag string to select
the colour. This implies that any given tag string will always
get the same colour, regardless of what other tags are defined.

The font face styles for indicating added and removed tags are
also modified to remain visually calling against the coloured
backgrounds."
  :group 'notmuch)

(defcustom notmuch-rainbow-tags-saturation 0.8
  "The satuartion to use for all tag background colours.

A floating point value in the inclusive range 0.0 to 1.0 setting
the saturation in the HSL colour space to use.  Zero means
completely de-saturated colour, and one means maximally saturated
colour."
  :type '(float
	  :validate (lambda (widget)
		      (let ((value (widget-value widget)))
			(when (or (not (floatp value))
				  (< value 0.0)
				  (> value 1.0))
			  (widget-put widget :error
				      (concat "Must be a floating point value "
					      "in the inclusive range "
					      "0.0 to 1.0"))
			  widget)))))

(defcustom notmuch-rainbow-tags-lightness 0.85
  "The lightness to use for all tag background colours.

A floating point value in the inclusive range 0.0 to 1.0 setting
the lightness in the HSL colour space to use.  Zero means no
lightness at all (i.e. black), and one means maximum
lightness (i.e. white)."
  :type '(float
	  :validate (lambda (widget)
		      (let ((value (widget-value widget)))
			(when (or (not (floatp value))
				  (< value 0.0)
				  (> value 1.0))
			  (widget-put widget :error
				      (concat "Must be a floating point value "
					      "in the inclusive range "
					      "0.0 to 1.0"))
			  widget)))))

(defcustom notmuch-rainbow-tags-hide-tags-list '("unread" "attachment" "flagged")
  "List of tags to hide in search and tree views.

Tags can be hidden from display in `notmuch' search and tree
views by setting their font face to the undefined value.  Since
`notmuch-rainbow-tags' sets the font faces of all tags, the
option to set some of them to the undefined value (i.e. to
effectively hide them from display) is included.  The tags are
still present, and remain set on the messages, they are just not
displayed on the screen.

If you want to show all tags, set `notmuch-rainbow-hide-tags' to
nil.

To hide tags from the \"all tags\" section of the `notmuch-hello'
screen, see `notmuch-hello-hide-tags'."
  :type '(repeat (string :tag "hide tag")))

(defcustom notmuch-rainbow-tags-added-colour "blue"
  "Text colour for added tags.

To reduce visual clutter, setting this also removes the underline
which the face `notmuch-tag-added' has in its default form.  To
set this variable programmatically, you should hence always use
`customize-set-variable'."
  :type '(color)
  :set	(lambda (sym val)
	  (setq notmuch-rainbow-tags-added-colour val)
	  (face-spec-set 'notmuch-tag-added
		         `((t (:foreground ,notmuch-rainbow-tags-added-colour
                               :underline nil)))
		 'face-override-spec)))

(defcustom notmuch-rainbow-tags-deleted-colour "red"
  "Text colour for removed tags.

To reduce visual clutter, setting this also removes the
strike-through which the face `notmuch-tag-deleted' has in its
default form.  To set this variable programmatically, you should
hence always use `customize-set-variable'."
  :type '(color)
  :set 	(lambda (sym val)
	  (setq notmuch-rainbow-tags-deleted-colour val)
	  (face-spec-set 'notmuch-tag-deleted
			 `((t (:foreground ,notmuch-rainbow-tags-deleted-colour
			       :strike-through ,notmuch-rainbow-tags-deleted-colour)))
			 'face-override-spec)))

;;{{{      Internal cooking

(defvar notmuch-rainbow-tags-mode-p nil)

(defun notmuch-rainbow-tags-hue-for-tag (tag)
  "Compute a hue value based on a hash over the string TAG.

Since the hash is calculated from the string TAG, any given TAG
will always produce the same hash value, and hence also always
produce the same hue value.  Hue values are in the inclusive range
0.0 to 1.0."
  (let* ((hash (secure-hash 'sha224 tag))
	 (hue (/ (string-to-number
		  (concat (substring hash  5  6)
			  (substring hash 12 13)
			  (substring hash 19 20)
			  (substring hash 26 27)
			  (substring hash 31 32)
			  (substring hash 38 39)
			  (substring hash 45 46)
			  (substring hash 52 53))
		  16)
		 4294967295.0)))
    hue))

(defun notmuch-rainbow-tags-fg-bg-for-tag (tag)
  "Compute background, and foreground colours for the string TAG.

A hue value is calculated for the string TAG using the function
`notmuch-rainbow-tags-hue-for-tag', and used as the background
colour.  The foreground colour is chosen based on
`notmuch-rainbow-tags-lightness', so that a minimum contrast
between the foreground and the background exists.  Returns a list
of the format (foreground-colour background-colour)."
  (let* ((hue (notmuch-rainbow-tags-hue-for-tag tag))
	 (bg-col-rgb (color-hsl-to-rgb hue
				       notmuch-rainbow-tags-saturation
				       notmuch-rainbow-tags-lightness))
	 fg-col
	 bg-col)
    (if (< notmuch-rainbow-tags-lightness 0.5)
	(setq fg-col (face-attribute 'default :background))
      (setq fg-col (face-attribute 'default :foreground)))
    (setq bg-col (concat "#"
			 (format "%02x" (round (* (nth 0 bg-col-rgb) 255.0)))
			 (format "%02x" (round (* (nth 1 bg-col-rgb) 255.0)))
			 (format "%02x" (round (* (nth 2 bg-col-rgb) 255.0)))))
    (list fg-col bg-col)))

(defun notmuch-rainbow-tags-colorize-tag (tag)
  "Add an entry for TAG to `notmuch-tag-formats', using the colours determined by `notmuch-rainbow-tags-fg-bg-for-tag'."
  (let* ((fg-bg (notmuch-rainbow-tags-fg-bg-for-tag tag))
	 (fg (nth 0 fg-bg))
	 (bg (nth 1 fg-bg)))
    (setq notmuch-tag-formats
	  (cons (copy-tree
		 `(,tag
		   (propertize tag
			       'face
			       '(:foreground ,fg :background ,bg))))
		notmuch-tag-formats))))

(defun notmuch-rainbow-tags-colorize-tags (taglist)
  "Rebuild `notmuch-tag-formats' with foreground, and background colours for all tags in TAGLIST."
  (setq notmuch-tag-formats nil)
  (dolist (x taglist)
    (notmuch-rainbow-tags-colorize-tag x)))

(defun notmuch-rainbow-tags-hide-tag (tag)
  "Add an entry for TAG to `notmuch-tag-formats' with an empty face specification, which causes it to not be displayed."
  (setq notmuch-tag-formats (cons `(,tag ()) notmuch-tag-formats))
  (setq notmuch-tag-deleted-formats
	(cons `(,tag ()) notmuch-tag-deleted-formats)))

(defun notmuch-rainbow-tags-hide-tags (taglist)
  "Hide all tags listed in TAGLIST from display."
  (setq notmuch-tag-deleted-formats
	'((".*" (notmuch-apply-face tag `notmuch-tag-deleted))))
  (dolist (x taglist)
    (notmuch-rainbow-tags-hide-tag x)))

;;}}}

;;{{{      High-level interfaces

;;;###autoload
(defun notmuch-rainbow-tags ()
  "Set background colours of currently defined tags based on the tag string.

This function is intended for being added to a `notmuch' hook,
such as for example `notmuch-search-hook', or
`notmuch-after-tag-hook'. It is added to both hooks by the
function `notmuch-rainbow-tags-global-mode'.  The tags listed in
`notmuch-rainbow-tags-hide-tags-list' will be hidden from
display."
  (let ((all-tags (notmuch-hello-generate-tag-alist))
	shown-tags)
    (dolist (x all-tags)
      (setq shown-tags (cons (car x) shown-tags)))
    (dolist (x notmuch-rainbow-tags-hide-tags-list)
      (delete x shown-tags))
    (notmuch-rainbow-tags-colorize-tags shown-tags)
    (notmuch-rainbow-tags-hide-tags     notmuch-rainbow-tags-hide-tags-list)))

;;;###autoload
(defun notmuch-rainbow-tags-global-mode ()
  "Activate background colouring for tags based on the tag string.

This function installs the function `notmuch-rainbow-tags' to be
called from `notmuch-search-hook', and `notmuch-after-tag-hook'.
Thus, whenever search results are about to be presented, or when
the tags on one or more messages have been changed,
`notmuch-rainbow-tags' loops through all tags, and sets a
distinct background colour for each currently defined tag string.
The tags listed in `notmuch-rainbow-tags-hide-tags-list' will be
hidden from display.

To get distinct tag background colours for all `notmuch' search
results screens, add

    (require 'notmuch-rainbow-tags)
    (notmuch-rainbow-tags-global-mode)

to your init file."
  (face-spec-set 'notmuch-tag-face
                 '((t (:inherit default :weight semi-bold))) 'face-override-spec)
  (face-spec-set 'notmuch-tree-match-tag-face
                 '((t (:inherit default :weight semi-bold))) 'face-override-spec)
  (add-hook 'notmuch-search-hook 'notmuch-rainbow-tags)
  (add-hook 'notmuch-after-tag-hook 'notmuch-rainbow-tags))

;;}}}

(provide 'notmuch-rainbow-tags)
;;; notmuch-rainbow-tags.el ends here
