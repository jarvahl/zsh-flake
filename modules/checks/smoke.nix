{ config, lib, ... }:
{
  perSystem =
    { pkgs, ... }:
    let
      zshrc = config.flake.lib.zshConfiguration {
        inherit pkgs;
        modules = [{ initConfig = "export NIX_ZSH_SMOKE=42"; }];
      };
      attrsetApiZsh = config.flake.lib.zshConfiguration {
        inherit pkgs;
        modules = [
          {
            vi.enable = true;
            autosuggestion.enable = true;
            syntaxHighlighting.integrations.patina.enable = true;

            completion = {
              enable = true;
              integrations.fzf.enable = true;
            };

            history.integrations.fzf.enable = true;

            aliases = {
              ll = "ls -l";
              gs = "git status";
            };
          }
        ];
      };
      completionFzfWithoutCompletion = config.flake.lib.zshConfiguration {
        inherit pkgs;
        modules = [
          {
            completion.integrations.fzf.enable = true;
          }
        ];
      };
      completionFzfWithoutCompletionEval = builtins.tryEval completionFzfWithoutCompletion.drvPath;
      hjemIntegration = lib.evalModules {
        modules = [
          config.flake.hjemModules.default
          ({ lib, ... }: {
            options.rum.programs.zsh = {
              enable = lib.mkEnableOption "mock zsh";
              initConfig = lib.mkOption {
                type = lib.types.lines;
                default = "";
              };
            };
          })
          {
            rum.programs.zsh.flake = {
              enable = true;
              aliases.ll = "ls -l";
            };

            rum.programs.zsh.initConfig = lib.mkAfter ''
              echo after
            '';
          }
        ];
        specialArgs = {
          inherit pkgs;
        };
      };
      zdotdir = pkgs.runCommand "zdotdir" { } "mkdir -p $out && cp ${zshrc}/.zshrc $out/.zshrc";
      zsh = pkgs.symlinkJoin {
        name = "nix-zsh-smoke";
        paths = [ pkgs.zsh ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = "wrapProgram $out/bin/zsh --set ZDOTDIR ${zdotdir}";
        meta.mainProgram = "zsh";
      };
    in
    {
      checks.smoke = pkgs.runCommand "nix-zsh-smoke" { nativeBuildInputs = [ pkgs.zsh ]; } ''
        export HOME="$(mktemp -d)"
        output=$(${lib.getExe zsh} -i -c 'print -- "RESULT=$NIX_ZSH_SMOKE"' 2>/dev/null)
        echo "$output" | grep -q '^RESULT=42$'
        touch $out
      '';

      checks.attrset-api = pkgs.runCommand "nix-zsh-attrset-api" { } ''
        zshrc=${attrsetApiZsh}/.zshrc

        grep -q 'autoload -Uz compinit' "$zshrc"
        grep -q '^compinit$' "$zshrc"
        grep -q "^alias ll='ls -l'$" "$zshrc"
        grep -q "^alias gs='git status'$" "$zshrc"
        grep -q 'zsh-vi-mode.plugin.zsh' "$zshrc"
        grep -q 'zsh-autosuggestions.zsh' "$zshrc"
        grep -q 'zsh-patina activate' "$zshrc"
        grep -q 'fzf-tab.plugin.zsh' "$zshrc"
        grep -q 'zsh-fzf-history-search.plugin.zsh' "$zshrc"
        line() {
          grep -n "$1" "$zshrc" | head -n1 | cut -d: -f1
        }

        test "$(line 'zsh-vi-mode.plugin.zsh')" -lt "$(line 'zsh-autosuggestions.zsh')"
        test "$(line 'zsh-autosuggestions.zsh')" -lt "$(line 'zsh-patina activate')"
        test "$(line 'fzf-tab.plugin.zsh')" -lt "$(line 'zsh-fzf-history-search.plugin.zsh')"
        touch $out
      '';

      checks.completion-fzf-requires-completion =
        pkgs.runCommand "nix-zsh-completion-fzf-requires-completion" { } ''
          if ${lib.boolToString completionFzfWithoutCompletionEval.success}; then
            echo "expected completion.integrations.fzf.enable without completion.enable to fail evaluation"
            exit 1
          fi

          touch $out
        '';

      checks.hjem-integration = pkgs.runCommand "nix-zsh-hjem-integration" { } ''
        initConfig=${pkgs.writeText "hjem-zsh-init" hjemIntegration.config.rum.programs.zsh.initConfig}

        ${lib.optionalString (!hjemIntegration.config.rum.programs.zsh.enable) ''
          echo "expected rum.programs.zsh.flake.enable to enable rum.programs.zsh by default"
          exit 1
        ''}

        grep -q "^alias ll='ls -l'$" "$initConfig"
        grep -q 'echo after' "$initConfig"

        line() {
          grep -n "$1" "$initConfig" | head -n1 | cut -d: -f1
        }

        test "$(line "^alias ll='ls -l'$")" -lt "$(line 'echo after')"

        touch $out
      '';
    };
}
