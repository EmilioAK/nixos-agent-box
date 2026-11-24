{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.agentBox;
  rootless = cfg.dockerMode == "rootless";
  rootful = cfg.dockerMode == "rootful";
in
{
  options.agentBox = {
    user = lib.mkOption {
      type = lib.types.str;
      example = "developer";
      description = "Existing normal user who owns this agent box.";
    };

    configurationDirectory = lib.mkOption {
      type = lib.types.str;
      default = "${config.users.users.${cfg.user}.home}/nixos-agent-box";
      description = "Location of this VM's configuration checkout, as reported in the VM guide.";
    };

    dockerMode = lib.mkOption {
      type = lib.types.enum [
        "rootless"
        "rootful"
        "off"
      ];
      default = "rootless";
      description = "Docker setup provided by this module.";
    };

    codex.enable = lib.mkEnableOption "Codex CLI";
    claudeCode.enable = lib.mkEnableOption "Claude Code";
  };

  config = {
    assertions = [
      {
        assertion = config.users.users.${cfg.user}.isNormalUser or false;
        message = "agentBox.user must name the existing normal user from the guest configuration.";
      }
      {
        assertion = !(rootless && config.virtualisation.docker.enable);
        message = ''The guest already enables rootful Docker. Select agentBox.dockerMode = "rootful" or remove the guest's rootful Docker setting before switching.'';
      }
      {
        assertion = !(rootful && config.virtualisation.docker.rootless.enable);
        message = ''The guest already enables rootless Docker. Select agentBox.dockerMode = "rootless" or remove the guest's rootless Docker setting before switching.'';
      }
    ];

    services.openssh.enable = lib.mkDefault true;
    users.users.${cfg.user} = {
      linger = lib.mkDefault true;
      extraGroups = lib.mkIf rootful [ "docker" ];
    };

    nix.settings.experimental-features = [
      "nix-command"
      "flakes"
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    virtualisation.docker = lib.mkMerge [
      (lib.mkIf rootless {
        rootless.enable = true;
        rootless.setSocketVariable = true;
      })
      (lib.mkIf rootful { enable = true; })
    ];

    nixpkgs.config.allowUnfreePackages = lib.optionals cfg.claudeCode.enable [ "claude-code" ];

    environment.systemPackages =
      (with pkgs; [
        (callPackage ../pkgs/git-twig.nix { })
        bat
        curl
        fd
        fzf
        gh
        git
        git-lfs
        htop
        jq
        neovim
        openssl
        ripgrep
        rsync
        shellcheck
        tmux
        tree
        unzip
        wget
        zip
      ])
      ++ lib.optional cfg.codex.enable pkgs.codex
      ++ lib.optional cfg.claudeCode.enable pkgs.claude-code;

    environment.etc."agent-box/README.md".text = ''
      # Agent box

      Developer login is `${cfg.user}`. The NixOS configuration checkout is
      `${cfg.configurationDirectory}`. Read its flake and host modules for the
      desired configuration. Use `nixos-version --configuration-revision` to
      identify the configuration revision of the running generation.

      Start each parallel editing task in its own worktree. From the main
      checkout, use `git twig new -b feat/task ../task HEAD`. Keep the path
      beside the main checkout on the same filesystem.

      Use the project flake for runtime dependencies. Review its `.envrc`,
      authorize it with `direnv allow`, and run noninteractive commands with
      `direnv exec . <command>`. Use a named tmux session for interactive
      work that needs to continue after SSH disconnects.

      Docker mode for this module is `${cfg.dockerMode}`. Projects own their
      Compose stacks. Use distinct Compose project names and host ports for
      concurrent stacks. Inspect the Docker data root with
      `docker info --format '{{.DockerRootDir}}'`.

      Keep agent session state in the developer's home and private env files
      in `~/.agents/secrets/`. Load a project credential only for commands
      that use it.
    '';
  };
}
