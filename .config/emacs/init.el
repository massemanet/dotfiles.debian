(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))


(straight-use-package 'doom-modeline)
(straight-use-package '(flycheck :fork "massemanet/flycheck"))
(straight-use-package 'flycheck-popup-tip)
(straight-use-package 'dumb-jump)

(straight-use-package 'erlang)
(straight-use-package 'company-erlang)

(straight-use-package 'json-mode)
(straight-use-package 'json-reformat)
(straight-use-package 'json-snatcher)
(straight-use-package 'macrostep)
(straight-use-package 'magit)
(straight-use-package 'magit-gitflow)
(straight-use-package 'magit-popup)
(straight-use-package 'magit-todos)
(straight-use-package 'markdown-mode)
(straight-use-package 'markdown-toc)
(straight-use-package 'nyan-mode)
(straight-use-package 'rainbow-delimiters)

(add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
(setq xref-show-definitions-function #'xref-show-definitions-completing-read)

;; legacy
(add-to-list 'load-path "~/.config/emacs/masserlang")
(add-to-list 'load-path "~/.config/emacs/fdlcap")
;;(require 'masserlang)
;;(require 'fdlcap)

;; turn on good shit
(show-paren-mode t)
(transient-mark-mode t)
(global-font-lock-mode t)
(delete-selection-mode t)
(ido-mode t)
(fset 'yes-or-no-p 'y-or-n-p)
(server-start)
(nyan-mode 1)
(global-flycheck-mode)
(flycheck-popup-tip-mode)
(doom-modeline-mode)

;; turn off bad shit
(if (featurep 'tool-bar)   (tool-bar-mode   -1))
(if (featurep 'tooltip)    (tooltip-mode    -1))
(if (featurep 'scroll-bar) (scroll-bar-mode -1))
(if (featurep 'menu-bar)   (menu-bar-mode   -1))
(defun ido-kill-emacs-hook () (ignore-errors (ido-save-history)))

(setq-default indent-tabs-mode nil)
(setq
 display-time-24hr-format    t
 ediff-window-setup-function 'ediff-setup-windows-plain
 inhibit-startup-screen      t
 ring-bell-function          #'blink-mode-line
 visible-bell                nil
 default-input-method        "swedish-postfix"
 max-lisp-eval-depth         40000
 scroll-down-aggressively    0.1
 scroll-up-aggressively      0.1)

(defun switch-to-previous-buffer ()
  "Switch to previously open buffer.
Repeated invocations toggle between the two most recently open buffers."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))

(defun prev-window ()
  (interactive)
  (select-window (previous-window (selected-window) nil nil)))

;; keybindings
(global-set-key (kbd "C-%")     `query-replace)
(global-set-key (kbd "C-:")     'flycheck-previous-error)
(global-set-key (kbd "C-<")     'beginning-of-buffer)
(global-set-key (kbd "C->")     'end-of-buffer)
(global-set-key (kbd "C-S-a")   'align-regexp)
(global-set-key (kbd "C-S-c")   `execute-extended-command)
(global-set-key (kbd "C-S-f")   `my-find)
(global-set-key (kbd "C-S-g")   `goto-line)
(global-set-key (kbd "C-S-n")   `forward-list)
(global-set-key (kbd "C-S-o")   `switch-to-previous-buffer)
(global-set-key (kbd "C-S-p")   `backward-list)
(global-set-key (kbd "C-S-q")   `fill-paragraph)
(global-set-key (kbd "C-S-t")   `transpose-lines)
(global-set-key (kbd "C-S-v")   `scroll-down)
(global-set-key (kbd "C-S-w")   `kill-ring-save)
(global-set-key (kbd "C-S-y")   `yank-pop)
(global-set-key (kbd "C-\"")    'flycheck-next-error)
(global-set-key (kbd "C-c b")   'bury-buffer)
(global-set-key (kbd "C-c p")   'point-to-register)
(global-set-key (kbd "C-c r")   'register-to-point)
(global-set-key (kbd "C-v")     `scroll-up)
(global-set-key (kbd "C-x C-r") 'revert-buffer)
(global-set-key (kbd "C-x O")   'prev-window)
(global-set-key (kbd "C-x c")   'execute-extended-command)
(global-set-key (kbd "C-z")     'undo) ; be like a mac
(global-set-key (kbd "C-{")     `previous-error)
(global-set-key (kbd "C-}")     `next-error)
(global-set-key (kbd "M-u")     `fdlcap-change-case-current-word)
(global-set-key (kbd "M-z")     'undo) ; if screen eats C-z

(let ((map minibuffer-local-map))
  (define-key map (kbd "C-n")   'next-history-element)
  (define-key map (kbd "C-p")   'previous-history-element))
