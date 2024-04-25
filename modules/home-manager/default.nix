{
  username,
  osConfig,
  inputs,
  ...
}:
{
  home = {
    stateVersion = osConfig.system.stateVersion;
    inherit username;
    homeDirectory = "/home/${username}";
  };
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    inputs.anyrun.homeManagerModules.default
    ./programs/neovide.nix
    # ./default-apps.nix
    ./packages
    ./programs
    ./services
    ./desktops/hyprland
  ];
}
