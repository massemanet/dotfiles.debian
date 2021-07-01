;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Masse Manet"
      user-mail-address "manet@cronqvi.st")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(map! "C-%"   #'query-replace
      "C-<"   #'beginning-of-buffer
      "C->"   #'end-of-buffer
      "C-v"   #'scroll-up
      "C-y"   #'yank
      "C-z"   #'undo-fu-only-undo
      "C-{"   #'flycheck-previous-error
      "C-}"   #'flycheck-next-error
      "C-\""  #'next-error
      "C-:"   #'previous-error
      "C-x f" nil
      "C-S-SPC" #'just-one-space
      "C-S-A" #'align-regexp
      "C-S-C" #'execute-extended-command
      "C-S-G" #'goto-line
      "C-S-K" #'kill-region
      "C-S-N" #'forward-list
      "C-S-O" #'other-window
      "C-S-P" #'backward-list
      "C-S-Q" #'fill-paragraph
      "C-S-R" #'revert-buffer
      "C-S-T" #'transpose-lines
      "C-S-V" #'scroll-down
      "C-S-W" #'copy-region-as-kill
      "C-S-Y" #'counsel-yank-pop
      "C-S-Z" #'undo-fu-only-redo)

(map! :map minibuffer-local-map
      "C-n" #'next-history-element
      "C-p" #'previous-history-element)

(map! (:when (featurep! :completion ivy)
       (:after ivy
        :map ivy-minibuffer-map
        "TAB"   #'ivy-partial-or-done)))

(smartparens-global-mode -1)
(nyan-mode)
(setq doom-theme 'doom-acario-dark)

(set-lookup-handlers! '(erlang-mode)
  :definition #'ivy-erlang-complete-find-definition
  :documentation #'ivy-erlang-complete-show-doc-at-point)

(add-hook 'erlang-mode-hook 'my-erlang-mode-hook)
(defun my-erlang-mode-hook ()
  (let* ((root (projectile-project-root))
         (wildlib (concat root "_build/default/lib/*/ebin"))
         (libs (file-expand-wildcards wildlib))
         (erlc-path (executable-find "erlc"))
         (erl-path (if erlc-path (f-dirname erlc-path) nil)))
    (setq erlang-electric-commands nil
          flycheck-erlang-library-path libs
          ivy-erlang-complete-erlang-root erl-path
          ivy-erlang-complete-project-root root)))
