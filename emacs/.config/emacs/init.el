;;; init.el -*- lexical-binding: t; -*-

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(when (not (package-installed-p 'use-package))
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(setq use-package-always-ensure t)

(use-package evil
  :init
  (setq evil-want-integration t
        evil-want-keybinding nil)
  :config
  (evil-mode 1))

(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode 1)

(setq make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      frame-title-format '("%b – Emacs")
      ring-bell-function 'ignore
      custom-safe-themes t
      scroll-step 1
      scroll-conservatively 101
      scroll-margin 5
      scroll-preserve-screen-position t)

(global-hl-line-mode 1)

(setq treesit-font-lock-level 4)
(setq major-mode-remap-alist
      '((python-mode . python-ts-mode)
        (ruby-mode . ruby-ts-mode)
        (js-mode . js-ts-mode)
        (typescript-mode . typescript-ts-mode)
        (c-mode . c-ts-mode)
        (c-or-c++-mode . c-or-c++-ts-mode)
        (c++-mode . c++-ts-mode)
        (java-mode . java-ts-mode)
        (rust-mode . rust-ts-mode)
        (bash-mode . bash-ts-mode)
        (sh-mode . bash-ts-mode)
        (json-mode . json-ts-mode)
        (yaml-mode . yaml-ts-mode)
        (toml-mode . toml-ts-mode)
        (css-mode . css-ts-mode)
        (nix-mode . nix-ts-mode)
        (cmake-mode . cmake-ts-mode)
        (lua-mode . lua-ts-mode)
        (elisp-mode . elisp-ts-mode)))
(dolist (r '(("\\.go\\'" . go-ts-mode)
             ("\\.cs\\'" . csharp-ts-mode)
             ("Dockerfile\\'" . dockerfile-ts-mode)
             ("\\.rs\\'" . rust-ts-mode)))
  (add-to-list 'auto-mode-alist r))

(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))
(load-theme 'base16-black-metal-base t)

(set-face-attribute 'default nil
                    :family "IosevkaTerm Nerd Font"
                    :height 140
                    :weight 'normal)
(add-to-list 'default-frame-alist '(font . "IosevkaTerm Nerd Font-14"))

(with-eval-after-load 'recentf
  (setq recentf-max-menu-items 15))
