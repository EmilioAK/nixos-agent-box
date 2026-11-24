{
  # Evaluation fixture. Deployment uses the existing guest's configuration.
  boot.loader.grub.devices = [ "/dev/vda" ];
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
  system.stateVersion = "26.05";

  users.users.developer.isNormalUser = true;
  agentBox = {
    user = "developer";
    codex.enable = true;
    claudeCode.enable = true;
  };
}
