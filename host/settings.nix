{
  agentBox = {
    # Use the existing login declared in this guest's configuration.
    user = "developer";

    # Turn on either client or both.
    codex.enable = false;
    claudeCode.enable = false;

    # Set configurationDirectory if you clone somewhere other than ~/nixos-agent-box.
    # dockerMode = "rootless";
  };
}
