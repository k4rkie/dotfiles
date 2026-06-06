(deftheme base16-black-metal-base
  "Base16 Black Metal Base theme – dark, low-contrast.
Matches the Neovim base16-black-metal-base scheme.")

(let ((bg       "#000000")
      (bg-alt   "#121212")
      (bg-hl    "#222222")
      (comment  "#333333")
      (line-nr  "#999999")
      (fg       "#c1c1c1")
      (accent   "#A0C2FF")
      (constant "#aaaaaa")
      (type     "#4e5687")
      (string   "#6488a0")
      (func     "#888888")
      (keyword  "#999999")
      (delim    "#444444")
      (warn     "#999999")
      (err      "#A0C2FF"))
  (custom-theme-set-faces
   'base16-black-metal-base

   `(default ((t (:background ,bg :foreground ,fg))))
   `(cursor ((t (:background ,fg))))
   `(region ((t (:background ,bg-hl))))
   `(fringe ((t (:background ,bg))))
   `(hl-line ((t (:background ,bg-alt))))
   `(highlight ((t (:background ,bg-hl))))

   `(line-number ((t (:foreground ,line-nr :background ,bg))))
   `(line-number-current-line ((t (:foreground ,line-nr :background ,bg-alt))))

   `(mode-line ((t (:foreground ,func :background ,bg-hl))))
   `(mode-line-inactive ((t (:foreground ,line-nr :background ,bg))))
   `(mode-line-buffer-id ((t (:foreground ,func :weight bold))))
   `(header-line ((t (:foreground ,fg :background ,bg-alt))))
   `(vertical-border ((t (:foreground ,bg-hl))))

   `(minibuffer-prompt ((t (:foreground ,func))))

   `(font-lock-comment-face ((t (:foreground ,comment))))
   `(font-lock-comment-delimiter-face ((t (:foreground ,comment))))
   `(font-lock-doc-face ((t (:foreground ,string))))
   `(font-lock-doc-markup-face ((t (:foreground ,string))))
   `(font-lock-keyword-face ((t (:foreground ,keyword))))
   `(font-lock-string-face ((t (:foreground ,string))))
   `(font-lock-function-name-face ((t (:foreground ,func))))
   `(font-lock-variable-name-face ((t (:foreground ,accent))))
   `(font-lock-type-face ((t (:foreground ,type))))
   `(font-lock-constant-face ((t (:foreground ,constant))))
   `(font-lock-builtin-face ((t (:foreground ,accent))))
   `(font-lock-preprocessor-face ((t (:foreground ,type))))
   `(font-lock-negation-char-face ((t (:foreground ,accent))))
   `(font-lock-warning-face ((t (:foreground ,warn))))

   `(error ((t (:foreground ,err))))
   `(warning ((t (:foreground ,warn))))
   `(success ((t (:foreground ,string))))

   `(show-paren-match ((t (:background ,comment))))
   `(show-paren-mismatch ((t (:foreground ,bg :background ,err))))
   `(isearch ((t (:foreground ,accent :background ,bg-hl))))
   `(isearch-fail ((t (:foreground ,err :background ,bg-hl))))
   `(lazy-highlight ((t (:background ,bg-hl))))
   `(match ((t (:foreground ,accent :background ,bg-hl))))
   `(query-replace ((t (:inherit isearch))))

   `(link ((t (:foreground ,accent :underline t))))
   `(link-visited ((t (:foreground ,type :underline t))))
   `(button ((t (:foreground ,accent :underline t))))

   `(completions-first-difference ((t (:weight bold))))
   `(completions-common-part ((t (:inherit default))))
   `(completions-group-title ((t (:inherit font-lock-comment-face))))

   `(secondary-selection ((t (:background ,comment))))
   `(shadow ((t (:foreground ,comment))))

   `(tab-bar ((t (:background ,bg))))
   `(tab-bar-tab ((t (:foreground ,func :background ,bg-hl))))
   `(tab-bar-tab-inactive ((t (:foreground ,line-nr :background ,bg))))

   `(dired-directory ((t (:foreground ,accent))))
   `(dired-symlink ((t (:foreground ,func))))
   `(dired-flagged ((t (:foreground ,err))))
   `(dired-mark ((t (:foreground ,accent))))
   `(dired-marked ((t (:foreground ,accent :background ,bg-alt))))

   `(widget-button ((t (:underline t))))
   `(widget-field ((t (:background ,bg-alt))))

   `(border ((t (:foreground ,bg-hl))))
   `(internal-border ((t (:foreground ,bg-hl))))
   `(child-frame-border ((t (:foreground ,bg-hl))))

   `(escape-glyph ((t (:foreground ,keyword))))
   `(homoglyph ((t (:foreground ,keyword))))
   `(nobreak-space ((t (:foreground ,keyword :underline t))))
   `(nobreak-hyphen ((t (:foreground ,keyword :underline t))))

   `(menu ((t (:foreground ,fg :background ,bg))))
   `(tty-menu-enabled-face ((t (:foreground ,fg :background ,bg))))
   `(tty-menu-disabled-face ((t (:foreground ,comment))))
   `(tty-menu-selected-face ((t (:foreground ,accent :background ,bg-hl))))

   `(tooltip ((t (:foreground ,fg :background ,bg-hl))))

   `(trailing-whitespace ((t (:background ,err))))

   `(whitespace-space ((t (:foreground ,bg-hl))))
   `(whitespace-hspace ((t (:foreground ,bg-hl))))
   `(whitespace-tab ((t (:foreground ,bg-hl))))
   `(whitespace-indentation ((t (:foreground ,bg-hl))))
   `(whitespace-empty ((t (:foreground ,bg-hl :background ,bg-alt))))

   `(sp-wrap-face ((t (:foreground ,delim))))
   `(sp-show-pair-match-face ((t (:background ,comment))))
   `(sp-show-pair-mismatch-face ((t (:foreground ,bg :background ,err))))))

(provide-theme 'base16-black-metal-base)
