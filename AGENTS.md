# Working on the agent box

- On the guest, read `/etc/agent-box/README.md` for the configuration path and project workflow.
- VM-wide tooling lives in `modules/agent-box.nix`. Personal choices live in `host/settings.nix`. Preserve the guest's existing boot, networking, SSH access, and `system.stateVersion` when adopting its configuration.
- Keep project runtimes in their own flakes and project services in Compose. The Python example is under `examples/python-project/`.
- Run `nix flake check` and, for project example changes, `nix flake check ./examples/python-project`.
- Create linked worktrees with `git twig new -b <branch> <path> <ref>` or `git twig new --detach <path> <ref>`. Use the existing project's instructions from the new checkout.
