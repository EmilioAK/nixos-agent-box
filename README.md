# NixOS Agent Box

A personal x86_64 NixOS VM for running Codex, Claude Code, or both. The VM provides Git Twig, direnv with nix-direnv, tmux, rootless Docker with Compose, and common CLI tools. Projects choose their own runtimes and services.

## Install on your VM

1. SSH into your existing NixOS 26.05 VM with the developer login that has sudo access. Use **Use this template** on GitHub to make your own private copy, then clone it on the VM. To try the public starter directly, run these commands on the VM.

   ```sh
   git clone https://github.com/EmilioAK/nixos-agent-box.git "$HOME/nixos-agent-box"
   cd "$HOME/nixos-agent-box"
   ```

   If Git is missing, enter a shell with it first using `nix --extra-experimental-features 'nix-command flakes' shell github:NixOS/nixpkgs/nixos-26.05#git`.

2. For a VM using the standard `/etc/nixos/configuration.nix`, copy its existing configuration and hardware file. Bring over any other local files those modules import. This preserves the guest's users, SSH keys, networking, bootloader, and `system.stateVersion`.

   ```sh
   sudo cat /etc/nixos/configuration.nix > host/configuration.nix
   sudo cat /etc/nixos/hardware-configuration.nix > host/hardware-configuration.nix
   ```

   Edit [host/settings.nix](host/settings.nix). Set `agentBox.user` to your existing login and enable `codex`, `claudeCode`, or both. Keep credential values in private files outside the checkout and the Nix store.

3. Make the guest files visible to the flake, then test the configuration. Add any extra imports to the same Git command.

   ```sh
   git add -N host/configuration.nix host/hardware-configuration.nix
   nixos-rebuild test --sudo --flake .#agent-box
   ```

4. From a second SSH session, run `git twig --version` and `docker info`. If the rootless daemon needs to be started in your session, run `systemctl --user start docker.service`. Once access and tooling work, run `nixos-rebuild switch --sudo --flake .#agent-box` from the configuration checkout. Run `codex login` or open `claude` to sign in under your developer account.

If your VM already uses a flake, add `github:EmilioAK/nixos-agent-box` as an input and import its `nixosModules.default` in your existing host. Set the options from [host/settings.nix](host/settings.nix) in that host and set `agentBox.configurationDirectory` to its checkout path. To retain an existing rootful Docker setup, set `agentBox.dockerMode = "rootful";`.

## Start an agent

From a project's main checkout, create a sibling worktree and start an agent in it. Run `direnv allow` after reviewing its `.envrc`.

```sh
git twig new -b feat/my-task ../my-project-task HEAD
cd ../my-project-task
direnv allow
tmux new-session -s my-task 'direnv exec . codex'
```

Use `claude` in the tmux command for Claude Code. Detach with `Ctrl-b d` and reconnect with `tmux attach -t my-task`. After a reboot, reopen the same worktree and use `codex resume` or `claude --resume`.

The active VM installs its map at `/etc/agent-box/README.md`. To give agents that starting point across all repos, add “Read `/etc/agent-box/README.md` for the VM setup” to your `~/.codex/AGENTS.md` or `~/.claude/CLAUDE.md`. Agents customizing this repository can start with [AGENTS.md](AGENTS.md).

The [Python example](examples/python-project/) includes a project flake, an `.envrc`, and PostgreSQL and Redis in Compose.
