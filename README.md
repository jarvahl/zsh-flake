# zsh-flake

## Disclaimer

⚠️ **This is a personal hobby project** developed in spare time.

- The API surface is **unstable** and may change without notice
- **Pin a revision** in your flake if you depend on zsh-flake
- Built with **AI assistance**
- No support commitment or warranty

## Configuration

```nix
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

  setopt = [
    "AUTO_CD"
    "EXTENDED_GLOB"
  ];
  unsetopt = [ "BEEP" ];
}
```

Run the same style of configured shell with:

```console
nix run
```

### Extending Zsh with Custom Modules

#### How to add a custom module

You can define a module directly in your configuration and add it to the `imports` list. This approach gives you full access to the NixOS module system.

```nix
{
  imports = [
    ({ config, lib, pkgs, ... }: {
      # Define your module's logic
      zsh.startPlugins.my-plugin = {
        package = pkgs.zsh-autosuggestions;
        source = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      };

      initConfig = "echo 'Hello from my custom module!'";
    })
  ];
}
```
