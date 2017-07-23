# Quix

## Description

`quix` lets you open specified files and directories quickly.

The `quix` command interactively presents a list of all file and/or
directory pathes defined in `quix-file` and opens the one selected by
the user.

The path to `quix-file` itself is included in this list so as to
allow quick manual edits of this file. The file may include comment
lines starting with `#` and/or empty lines.

`quix-file` defaults to `$HOME/.quix`, but can be set at will.

The command `quix-add` can be used to quickly append the path to the
current file or directory to `quix-file` without having to edit it
manually.

The interactive commands `quix-append-file` and
`quix-append-directory` are included for convenience, but should not
be needed due to `quix-add`.

By default, all pathes starting with the user's home directory are
"sanitized"; that is, their `/home/username` prefix is replaced by
a tilde (`~`). If this is not desired, set `quix-sanitizep` to `nil`.

## Installation


    (add-to-list 'load-path "/path/to/quix.el")
    (require 'quix)
    (global-set-key (kbd "C-x j") 'quix)
    (global-set-key (kbd "C-c C-x a") 'quix-add)
    (global-set-key (kbd "C-c C-x e") 'quix-edit)  ; Optional, really...
    
    ;; Now either create your `quix-file` manually or just run `qix-add`
    ;; for the first time.
    
    
    ;; If `$HOME/.quix' does not suit you, change it:
    (setq quix-file "/path/to/my/quixfile")
