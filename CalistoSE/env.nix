{ lib, pkgs, ... }: {
  imports = [ ];

  ### Programs, Services & Environment
  programs = {
    fish.enable = true;
    git.enable = true;
    htop.enable = true;
    less.enable = true;
    neovim = {
      enable = true;
      defaultEditor = true;
    };
    yazi.enable = true;
  };

  services = { };

  environment.shellAliases = { };

  environment.systemPackages = with pkgs; [
    gcc
    age
    ssh-to-age
    sops
    trashy
    p7zip
    vim
  ];

  environment.variables = { EDITOR = "nvim"; };
}
