{ self, lib, ... }:

{
  perSystem =
    { pkgs, ... }:
    let
      zsh = self.lib.zshConfiguration {
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

            integrations = {
              git.enable = true;
              docker.enable = true;
              npm.enable = true;
              mvn.enable = true;
            };

            aliases = {
              ll = "ls -l";
              gs = "git status";
            };

            setopt = [
              "AUTO_CD"
              "EXTENDED_GLOB"
            ];
            unsetopt = [ "BEEP" ];

            initConfig = ''
              if [[ -n $SSH_CLIENT ]]; then
                PROMPT="%F{cyan}[zsh-flake]%f %F{green}%n@%m%f %B%F{magenta}❯%f%b "
              else
                PROMPT="%F{cyan}[zsh-flake]%f %B%F{magenta}❯%f%b "
              fi
            '';
          }
        ];
      };
    in
    { apps.default = { type = "app"; program = "${zsh}/bin/zsh"; }; };
}
