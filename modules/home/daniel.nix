{
  pkgs,
  ...
}:
{
  home.enableNixpkgsReleaseCheck = false;
  home.stateVersion = "23.05";

  # NOTE: Use this to add packages available everywhere on your system
  home.packages = with pkgs; [
    neofetch
    btop
    wget
    zip
    magic-wormhole-rs
    gh
    zed-editor
  ];

  # THEME
  catppuccin = {
    enable = true;
    flavor = "mocha";
  };

  xdg.enable = true; # Needed for fish interactiveShellInit hack
  programs = {
    alacritty.enable = true;
    atuin = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        exit_mode = "return-query";
        keymap_mode = "auto";
        prefers_reduced_motion = true;
        enter_accept = true;
        show_help = false;
      };
    };

    lazygit = {
      enable = true;
      settings = {
        git.paging.pager = "${pkgs.diff-so-fancy}/bin/diff-so-fancy";
        git.truncateCopiedCommitHashesTo = 40;
        gui = {
          language = "en";
          mouseEvents = false;
          sidePanelWidth = 0.3;
          mainPanelSplitMode = "flexible";
          showFileTree = true;
          nerdFontsVersion = 3;
          commitHashLength = 6;
          showDivergenceFromBaseBranch = "arrowAndNumber";
          skipDiscardChangeWarning = true;
        };
        quitOnTopLevelReturn = true;
        disableStartupPopups = true;
        promptToReturnFromSubprocess = false;
        keybinding.files.commitChangesWithEditor = "<disabled>";
        customCommands = [
          {
            key = "C";
            command = ''git commit -m "{{ .Form.Type }}{{if .Form.Scopes}}({{ .Form.Scopes }}){{end}}{{ .Form.Breaking }}: {{ .Form.Description }}" -m "{{ .Form.LongDescription }}"'';
            description = "commit with commitizen and long description";
            context = "global";
            prompts = [
              {
                type = "menu";
                title = "Select the type of change you are committing.";
                key = "Type";
                options = [
                  {
                    name = "Feature";
                    description = "a new feature";
                    value = "feat";
                  }
                  {
                    name = "Fix";
                    description = "a bug fix";
                    value = "fix";
                  }
                  {
                    name = "Documentation";
                    description = "Documentation only changes";
                    value = "docs";
                  }
                  {
                    name = "Styles";
                    description = "Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)";
                    value = "style";
                  }
                  {
                    name = "Code Refactoring";
                    description = "A code change that neither fixes a bug nor adds a feature";
                    value = "refactor";
                  }
                  {
                    name = "Performance Improvements";
                    description = "A code change that improves performance";
                    value = "perf";
                  }
                  {
                    name = "Tests";
                    description = "Adding missing tests or correcting existing tests";
                    value = "test";
                  }
                  {
                    name = "Builds";
                    description = "Changes that affect the build system or external dependencies (example scopes: gulp, broccoli, npm)";
                    value = "build";
                  }
                  {
                    name = "Continuous Integration";
                    description = "Changes to our CI configuration files and scripts (example scopes: Travis, Circle, BrowserStack, SauceLabs)";
                    value = "ci";
                  }
                  {
                    name = "Chores";
                    description = "Other changes that don't modify src or test files";
                    value = "chore";
                  }
                  {
                    name = "Reverts";
                    description = "Reverts a previous commit";
                    value = "revert";
                  }
                ];
              }
              {
                type = "input";
                title = "Enter the scope(s) of this change.";
                key = "Scopes";
              }
              {
                type = "menu";
                title = "Breaking change?";
                key = "Breaking";
                options = [
                  {
                    name = "Default";
                    description = "Not a breaking change";
                    value = "";
                  }
                  {
                    name = "BREAKING CHANGE";
                    description = "Introduced a breaking change";
                    value = "!";
                  }
                ];
              }
              {
                type = "input";
                title = "Enter the short description of the change.";
                key = "Description";
              }
              {
                type = "input";
                title = "Enter a longer description of the change (optional).";
                key = "LongDescription";
              }
            ];
          }
          {
            key = "O";
            description = "open repo in GitHub";
            command = "gh repo view --web";
            context = "global";
            loadingText = "Opening GitHub repo in browser...";
          }
        ];
      };
    };

    zoxide.enable = true;
    zoxide.enableFishIntegration = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true; # Adds FishIntegration automatically
    };
    fish = {
      enable = true;
      interactiveShellInit = # bash
        ''
          # bind to ctrl-p in normal and insert mode, add any other bindings you want here too
          bind \cp _atuin_search
          bind -M insert \cp _atuin_search
          bind \cr _atuin_search
          bind -M insert \cr _atuin_search

          set -gx DIRENV_LOG_FORMAT ""

          function fish_user_key_bindings
            fish_vi_key_bindings
          end

          set fish_vi_force_cursor
          set fish_cursor_default     block      blink
          set fish_cursor_insert      line       blink
          set fish_cursor_replace_one underscore blink
          set fish_cursor_visual      block
        '';

      shellInit = # bash
        ''
          set fish_greeting # Disable greeting

          # done configurations
          set -g __done_notification_command 'notify send -t "$title" -m "$message"'
          set -g __done_enabled 1
          set -g __done_allow_nongraphical 1
          set -g __done_min_cmd_duration 8000

          # see https://github.com/LnL7/nix-darwin/issues/122
          set -ga PATH $HOME/.local/bin
          set -ga PATH /run/wrappers/bin
          set -ga PATH $HOME/.nix-profile/bin
          set -ga PATH /run/current-system/sw/bin
          set -ga PATH /nix/var/nix/profiles/default/bin

          # Adapt construct_path from the macOS /usr/libexec/path_helper executable for
          # fish usage;
          #
          # The main difference is that it allows to control how extra entries are
          # preserved: either at the beginning of the VAR list or at the end via first
          # argument MODE.
          #
          # Usage:
          #
          #   __fish_macos_set_env MODE VAR VAR-FILE VAR-DIR
          #
          #   MODE: either append or prepend
          #
          # Example:
          #
          #   __fish_macos_set_env prepend PATH /etc/paths '/etc/paths.d'
          #
          #   __fish_macos_set_env append MANPATH /etc/manpaths '/etc/manpaths.d'
          #
          # [1]: https://opensource.apple.com/source/shell_cmds/shell_cmds-203/path_helper/path_helper.c.auto.html .
          #
          function macos_set_env -d "set an environment variable like path_helper does (macOS only)"
            # noops on other operating systems
            if test $KERNEL_NAME darwin
              set -l result
              set -l entries

              # echo "1. $argv[2] = $$argv[2]"

              # Populate path according to config files
              for path_file in $argv[3] $argv[4]/*
                if [ -f $path_file ]
                  while read -l entry
                    if not contains -- $entry $result
                      test -n "$entry"
                      and set -a result $entry
                    end
                  end <$path_file
                end
              end

              # echo "2. $argv[2] = $result"

              # Merge in any existing path elements
              set entries $$argv[2]
              if test $argv[1] = "prepend"
                set entries[-1..1] $entries
              end
              for existing_entry in $entries
                if not contains -- $existing_entry $result
                  if test $argv[1] = "prepend"
                    set -p result $existing_entry
                  else
                    set -a result $existing_entry
                  end
                end
              end

              # echo "3. $argv[2] = $result"

              set -xg $argv[2] $result
            end
          end
          macos_set_env prepend PATH /etc/paths '/etc/paths.d'

          set -ga MANPATH $HOME/.local/share/man
          set -ga MANPATH $HOME/.nix-profile/share/man
          if test $KERNEL_NAME darwin
            set -ga MANPATH /opt/homebrew/share/man
          end
          set -ga MANPATH /run/current-system/sw/share/man
          set -ga MANPATH /nix/var/nix/profiles/default/share/man
          macos_set_env append MANPATH /etc/manpaths '/etc/manpaths.d'

          if test $KERNEL_NAME darwin
            set -gx HOMEBREW_PREFIX /opt/homebrew
            set -gx HOMEBREW_CELLAR /opt/homebrew/Cellar
            set -gx HOMEBREW_REPOSITORY /opt/homebrew
            set -gp INFOPATH /opt/homebrew/share/info
          end
        '';
    };

    ssh.enable = true;

    git = {
      enable = true;
      ignores = [ "*.swp" ];
      userName = "dingari";
      userEmail = "daniel@genkiinstruments.com";
      lfs.enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        core.autocrlf = "input";
        pull.rebase = true;
        rebase.autoStash = true;
      };
    };

    zellij = {
      enable = true;
      enableFishIntegration = true;
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = false;
        command_timeout = 1000;
        scan_timeout = 3;
      };
    };
  };
}
