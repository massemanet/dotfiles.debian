;;; masserlang --- Summary
;;; Commentary:
;;; masse's erlang setup
;;; Code:

(defun my-shell-mode ()
  "My erlang shell mode bindings."
  (defvar comint-history-isearch)
  (defvar comint-input-ignoredups)
  (setq comint-history-isearch 'dwim
        comint-input-ignoredups t)
  (local-set-key (kbd "C-n") 'comint-next-input)
  (local-set-key (kbd "C-p") 'comint-previous-input))
(add-hook 'erlang-shell-mode-hook 'my-shell-mode)

;; (setq company-require-match nil)
;; (setq company-lighter nil)
;; 
;; (setq safe-local-variable-values
;;       (quote ((erlang-indent-level . 4)
;;               (erlang-indent-level . 2))))

(set-variable 'erlang-electric-commands nil)

(defun my-erlang-mode-hook ()
  "We want company mode and flycheck."
  (defvar flycheck-erlang-include-path)
  (defvar flycheck-erlang-library-path)
  (declare-function flycheck-rebar3-project-root "ext:flycheck")
  (setq
   flycheck-erlang-include-path (append
                                 (file-expand-wildcards
                                  (concat
                                   (flycheck-rebar3-project-root)
                                   "_build/*/lib/*/include"))
                                 (file-expand-wildcards
                                  (concat
                                   (flycheck-rebar3-project-root)
                                   "_checkouts/*/include")))
   flycheck-erlang-library-path (append
                                 (file-expand-wildcards
                                  (concat
                                   (flycheck-rebar3-project-root)
                                   "_build/*/lib/*/ebin"))
                                 (file-expand-wildcards
                                  (concat
                                   (flycheck-rebar3-project-root)
                                   "_checkouts/*/ebin")))))

(add-hook 'erlang-mode-hook 'my-erlang-mode-hook)

(pcase '(add 1 2)
  (`(add ,x ,y)  (message "Contains %S and %S" x y)))

(defun erl-find()
  "An erl finder."
  (interactive)
  (declare-function erlang-get-identifier-at-point "ext:erlang")
  (pcase (erlang-get-identifier-at-point)
    (`(nil ,_ ,function ,arity)
     (message "%s/%d" function arity))
    (`(qualified-function ,module ,function ,arity)
     (message "%s:%s/%d" module function arity))
    (`(record ,_ ,name ,_)
     (message "#%s{}" name))
    (`(macro ,_ ,name ,'nil)
     (message "?%s/0" name))
    (`(macro ,_ ,name ,arity)
     (message "?%s/%s" name arity))
    (`(module ,_ ,name ,_)
     (message "-%s" name))
    ('nil
     (message "nothing."))))

(defun xref-erl--find-candidates (file regexp)
  "Grep for REGEXP in FILE."
    (let ((cmd (format "find /home/masse/git -name %s -exec grep %s {} +" file regexp))
          (res (shell-command-to-string cmd)))

      (goto-char (point-max)) ;; NOTE maybe redundant
      (while (re-search-backward "^\\(.+\\)$" nil t)
        (push (match-string-no-properties 1) matches))))

(defun my-erlang-new-file-hook ()
  "Insert my very own erlang file header."
  (interactive)
  (declare-function erlang-get-module-from-file-name "ext:erlang")
  (insert "%% -*- mode: erlang; erlang-indent-level: 4 -*-\n")
  (insert (concat "-module(" (erlang-get-module-from-file-name) ").\n\n"))
  (insert (concat "-export([]).\n\n")))

(add-hook 'erlang-new-file-hook 'my-erlang-new-file-hook)

;; make hack for compile command
;; uses Makefile if it exists, else looks for ../inc & ../ebin
(unless (null buffer-file-name)
  (make-local-variable 'compile-command)
  (setq compile-command
        (cond ((file-exists-p "Makefile")  "make -k")
              ((file-exists-p "../Makefile")  "make -kC..")
              (t (concat
                  "erlc "
                  (if (file-exists-p "../ebin") "-o ../ebin " "")
                  (if (file-exists-p "../include") "-I ../include " "")
                  "+debug_info -W " buffer-file-name)))))

(provide 'masserlang)

;;; masserlang.el ends here
