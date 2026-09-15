{ config, inputs, lib, ... }:

let
  flakeConfig = config;

  adapterModule = { lib, ... }: {
    options.enable = lib.mkEnableOption "zsh-flake integration";
  };
in
{
  flake.hjemModules.default =
    { config
    , lib
    , pkgs
    , ...
    }:
    let
      cfg = config.rum.programs.zsh.flake;
    in
    {
      options.rum.programs.zsh.flake = lib.mkOption {
        type = lib.types.submoduleWith {
          modules = flakeConfig.zsh.modules ++ [ adapterModule ];
          specialArgs = {
            inherit inputs pkgs;
            compileZshPlugin = flakeConfig.flake.lib.compileZshPlugin;
            dag = inputs.dag.lib { inherit lib; };
          };
        };
        default = { };
        description = "zsh-flake configuration rendered into hjem-rum zsh initConfig.";
      };

      config = lib.mkIf cfg.enable {
        rum.programs.zsh.enable = lib.mkDefault true;
        rum.programs.zsh.initConfig = lib.mkBefore cfg.zsh.rc;
      };
    };
}
