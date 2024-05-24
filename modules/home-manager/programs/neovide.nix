{ pkgs, ... }:
{
  home.packages = [ pkgs.neovide ];
  xdg.configFile."neovide/config.toml".source = (pkgs.formats.toml { }).generate "neovide" {
    maximized = false;
    fork = true;
    font = {
      normal = [ "FiraCode Nerd Font" ];
      size = 13;
      edging = "subpixelantialias";
      features."FiraCode Nerd Font" = [
        "+zero"
        "+onum"
        "+ss04"
        "+cv19"
        "+cv23"
        "+ss09"
        "+ss06"
        "+ss07"
        "+ss10"
      ];
    };
  };
}
