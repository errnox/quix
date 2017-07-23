;;; quix.el --- Find files, quickly.                 -*- lexical-binding: t; -*-

;; Copyright (C) xxxx

;; Author: - <xxx@xxx.xxx>
;; Keywords: tools

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; `quix' lets you open specified files and directories quickly.
;;
;; The `quix' command interactively presents a list of all file and/or
;; directory pathes defined in `quix-file' and opens the one selected by
;; the user.
;;
;; The path to `quix-file' itself is included in this list so as to
;; allow quick manual edits of this file. The file may include comment
;; lines starting with `#' and/or empty lines.
;;
;; `quix-file' defaults to `$HOME/.quix', but can be set at will.
;; 
;; The command `quix-add' can be used to quickly append the path to the
;; current file or directory to `quix-file' without having to edit it
;; manually.
;; 
;; The interactive commands `quix-append-file' and
;; `quix-append-directory' are included for convenience, but should not
;; be needed due to `quix-add'.
;;
;; By default, all pathes starting with the user's home directory are
;; "sanitized"; that is, their "/home/username" prefix is replaced by
;; a tilde ("~"). If this is not desired, set `quix-sanitizep' to `nil'.
;;
;;
;; Installation:
;;
;; (add-to-list 'load-path "/path/to/quix.el")
;; (require 'quix)
;; (global-set-key (kbd "C-x j") 'quix)
;; (global-set-key (kbd "C-c C-x a") 'quix-add)
;; (global-set-key (kbd "C-c C-x e") 'quix-edit)  ; Optional, really...
;;
;;  Now either create your `quix-file' manually or just run `qix-add'
;;  for the first time.
;;
;;
;; ;; If `$HOME/.quix' does not suit you, change it:
;; (setq quix-file "/path/to/my/quixfile")
;;
;;; Code:


(defvar quix-file (format "%s/%s" (getenv "HOME") ".quix")
  "Path to the file containing a list of file and/or directory pathes.")

(defvar quix-sanitizep t
  "If non-nil, replace the first occurence of the path to the user's
home directory with with a tilde when appending to `quix-file' by
calling `quix-add'. If the matching sub-path is not leading, that is
there comes any character before it, no replacement is performed
regardless of the value of this variable. See the documentation for
`quix--sanitize' for a more detailed description.

This has no effect on pathes that are manually added to `quix-file'")

(defvar quix-include-quix-filep t
  "If non-nil, the fullpath to `quix-file' is included in the listing
presented when calling `quix'")

(defun quix ()
"Interactively present a list of all file or directory pathes in
`quix-file' for selection and open the one selected by the user in the
current buffer.

Empty lines and lines starting with \"#\" are not presented in the
selction list. Thus lines starting with \"#\" can be used for comments
and empty lines can be used to group entries in `quix-file'.

The `quix-append' command can be called to add the current file or
directory to `quix-file' without having to edit it manually.

By default, the selection list presented by this command includes the
full path to `quix-file' itself which allows for quickly opening it for
manual editing. If this behavior is not desired,
`quix-include-quix-filep' can be set to `nil'.

Alternatively `quix-edit' can be used to quickly opening `quix-file' for
manual editing."
  (interactive)
  (find-file
   (ido-completing-read
    "Find file: "
    (remove-if
     (lambda (x) (or (= (length x) 0) (string-match "^#"x) ))
     (append
      (if (eq quix-include-quix-filep nil) "" (list quix-file))
      (split-string
       (with-temp-buffer
         (progn (insert-file quix-file) (buffer-string))) "\n"))))))

(defun quix-edit ()
  (interactive)
  (find-file quix-file))

(defun quix-append-file ()
  "Append the path to the file the currently active buffer is visiting
to `quix-file' without querying the user interactively."
  (interactive)
  (append-to-file
    (concat (quix--sanitize (buffer-file-name)) "\n") nil quix-file))

(defun quix-append-directory ()
  "Append the path to the current working directory (\"pwd\") the
currently active buffer is visiting to `quix-file' without querying the
user interactively."
  (interactive)
  (append-to-file
   (concat (quix--sanitize default-directory) "\n") nil quix-file))

(defun quix-add (path)
  (interactive "FQuix add: ")
  (append-to-file
    (concat (quix--sanitize path) "\n") nil quix-file))

(defun quix--sanitize (string)
  "If STRING starts with a path to the user's home directory, as defined
in the \"HOME\" environment variable, it is replaced with a tilde and
returned as a string.

If there are any further occurences matching the user's home directory
in STRING, they are not replaced.

If there is one or more occurences matching the user's home directory
in STRING, but they are not leading the string, they are not replaced.

Sanitization is only performed if `quix-sanitizep' is non-nil.

Examples:

  ;; The first occurence is replaced.
  (quix--sanitize \"/home/john/path/to/file.txt\")
  //  => \"~/path/to/file.txt\"

  ;; Any further occurences are not replaced.
  (quix--sanitize \"/home/john/path/to/home/john/file.txt\")
  ;;  => \"~/path/to/home/john/file.txt\"

  ;; Only a leading occurence is replaced.
  (quix--sanitize \"/foo/bar/home/john/path/to/file.txt\")
  ;;  => \"/foo/bar/home/john/path/to/file.txt\"
  ;; ...even if there is just a single whitespace char leading STRING.
  (quix--sanitize \" /home/john/path/to/file.txt\")
  ;;  => \" /home/john/path/to/file.txt\""
  (if (not (eq quix-sanitizep nil))
      (replace-regexp-in-string
       (concat
        "\\(^" (getenv "HOME") "\\).*\\'") "~" string nil nil 1)
    string))


(provide 'quix)
;;; quix.el ends here
