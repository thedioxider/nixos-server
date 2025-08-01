{ lib, pkgs, ... }: {
  services.desktopManager.plasma6.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  environment.systemPackages = with pkgs; [ wayland-utils wl-clipboard ];
}
