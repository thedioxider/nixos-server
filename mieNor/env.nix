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
    firefox.enable = true;
  };

  services = { };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  environment.shellAliases = { };

  environment.systemPackages = with pkgs; [
    gcc
    age
    ssh-to-age
    sops
    trashy
    p7zip
    vim
    jq
    amneziawg-go
    amneziawg-tools
    lighttpd
    maliit-framework
    maliit-keyboard
  ];

  environment.variables = { EDITOR = "nvim"; };
}
