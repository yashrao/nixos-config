{ config, pkgs, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "yash";
  home.homeDirectory = "/home/yash";
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read

  programs.git = {
    enable = true;
    userName  = "Yash Rao";
    userEmail = "12raoy1@gmail.com";
    extraConfig = {
      init.defaultBranch = "master";
    };
  };

  programs.firefox = {
    enable = true;
    profiles.yash = {
      #id = 0;
      isDefault = true;
      search = {
        force = true;
        engines = {
          "Nix Packages" = {
            urls = [{
              template = "https://search.nixos.org/packages";
              params = [
                { name = "type"; value = "packages"; }
                { name = "query"; value = "{searchTerms}"; }
              ];
            }];
            icon = "''${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = [ "@np" ];
          };
        };
      };

      userChrome = ''
       #TabsToolbar { visibility: collapse !important; }
       #sidebar-header { visibility: collapse !important; }
       #titlebar { appearance: none !important }
      '';

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
      };

      extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
        ublock-origin
        bitwarden
        darkreader
        metamask
        decentraleyes
        sidebery
        df-youtube
        adaptive-tab-bar-colour
      ];
    };
  };
 
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    telegram-desktop
    discord
    libreoffice
    thunderbird
    # Transmission is broken rn wait a few days to try again (07-13)
    transmission_4-qt
    # Broken - supposedly related to plasma6
    vivaldi 

    jetbrains-mono
    nerdfonts
    
    fastfetch
    htop
    btop
    vscode
    typescript

    # Dev
    clang
    clang-tools
    python3
    zig
    zls
  ];

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    extraConfig = ''
      set -g escape-time 1
      set -g mouse on
      set -g mode-keys vi
      set-option -g history-limit 5000
      bind -r "<" swap-window -d -t -1
      bind -r ">" swap-window -d -t +1
      bind c new-window -c "#{pane_current_path}"
    '';
  };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      eval "$(direnv hook bash)"
    '';
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true; # see note on other shells below
    nix-direnv.enable = true;
  };

  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    extensions = [
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # ublock origin
      { id = "hnfanknocfeofbddgcijnmhnfnkdnaad"; } # base wallet
    ];
    commandLineArgs = [
      "--disable-features=WebRtcAllowInputVolumeAdjustment"
    ];
  };

  programs.kitty = {
    enable = true;
    extraConfig = ''
      font_family JetBrains Mono
      font_size 14
      background_opacity 0.90
      bold_font        auto
      italic_font      auto
      bold_italic_font auto

      # Color theme: Modus Vivendi
      # Auto-generated by Gogh (https://Gogh-Co.github.io/Gogh/)

      color0  #000000
      color1  #ff5f59
      color2  #44bc44
      color3  #d0bc00
      color4  #2fafff
      color5  #feacd0
      color6  #00d3d0
      color7  #ffffff
      color8  #1e1e1e
      color9  #ff5f5f
      color10 #44df44
      color11 #efef00
      color12 #338fff
      color13 #ff66ff
      color14 #00eff0
      color15 #989898
      background #000000
      foreground #ffffff
      cursor #ffffff
    '';
  };

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      # Themes
      nimbus-theme
      zenburn-theme
      modus-themes
      catppuccin-theme
      doom-themes
      evil
      lsp-ui
      use-package
      doom-modeline
      hl-todo
      org-modern
      direnv
      # Completion
      company
      treesit-grammars.with-all-grammars
      lsp-mode
      # Langs
      nix-mode
      rust-mode
      zig-mode
      go-mode
      ccls
      # Solidity
      solidity-mode
      company-solidity
    ];
    extraConfig = ''
      ;; Setup packages
      ;; Evil - the only way to do things
      (use-package evil)
      ;; LSP Mode - for programming cheats
      (use-package lsp-mode :commands lsp
        :config
        (lsp-register-custom-settings
         '(("pyls.plugins.pyls_mypy.enabled" t t)
           ("pyls.plugins.pyls_mypy.live_mode" nil t)
           ("pyls.plugins.pyls_black.enabled" t t)
           ("pyls.plugins.pyls_isort.enabled" t t)))
        :hook
        ((python-mode . lsp)
         (solidity-mode . lsp)
         (tsx-ts-mode . lsp))
      )
      (use-package lsp-ui :commands lsp-ui-mode)
      ;; Cheats for C/C++
      (use-package ccls      ;; Make sure ccls is installed on the system
        :hook ((c-mode c++-mode objc-mode cuda-mode) .
               (lambda () (require 'ccls) (lsp))))
      ;; Company Mode - for completion popups
      (use-package company)
      ;; Appearance
      (use-package doom-modeline)
      (use-package doom-themes)
      ;; Rust Mode
      (use-package rust-mode)
      ;; Go Mode
      (use-package go-mode)
      (use-package zig-mode)
      (use-package hl-todo
        :hook (prog-mode . hl-todo-mode)
        :config
        (setq hl-todo-highlight-punctuation ":"
          hl-todo-keyword-faces
          `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))
      (use-package direnv
        :config
        (direnv-mode))
      
      ;;--------------ENABLING PACKAGES---------------------
      ;; Enable Evil
      (require 'evil)
      (evil-mode 1)
      (require 'doom-modeline)
      (doom-modeline-mode 1)
     
      ;;----------------SET SETTINGS-----------------------
      (setq inhibit-startup-message t
            cursor-type 'bar)
      (evil-set-initial-state 'Custom-mode 'normal)
      (add-hook 'after-init-hook 'global-company-mode)
      (tool-bar-mode -1)
      (scroll-bar-mode -1)
      (menu-bar-mode -1)
      (global-display-line-numbers-mode)
      (global-hl-line-mode t)
      (set-face-attribute 'default nil :font "JetBrains Mono-12")
      (set-frame-font "JetBrains Mono-12" nil t)
      ;; (load-theme 'catppuccin t)
      (load-theme 'modus-vivendi t)
      ;; Spaces > tabs
      (setq-default indent-tabs-mode nil)
      (setq-default tab-width 4)
      (setq indent-line-function 'insert-tab)
      ;; Pairing for quotes and parens
      (electric-pair-mode)

      ;; Enable tsx-ts-mode for ts files
      (add-to-list 'auto-mode-alist '("\.ts\'" . typescript-mode))
      
      ;; Ask to quit, but not when you're in a terminal
      (when (display-graphic-p)
        (setq confirm-kill-emacs 'y-or-n-p)
      )

      ;; For C
      (custom-set-variables
       ;; custom-set-variables was added by Custom.
       ;; If you edit it by hand, you could mess it up, so be careful.
       ;; Your init file should contain only one such instance.
       ;; If there is more than one, they won't work right.
       '(c-basic-offset 4)
       '(package-selected-packages '(hl-todo go-mode ccls evil)))
      
      ;;; backup/autosave - Changing the location of the autosaving
      (defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
      (defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
      (setq backup-directory-alist (list (cons ".*" backup-dir)))
      (setq auto-save-list-file-prefix autosave-dir)
      (setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))
    '';
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/yash/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
