{ ... }: {
  powerManagement.enable = true;

  ### Power management utilities
  # services.thermald.enable = true;
  # services.auto-cpufreq.enable = true;

  systemd.sleep.extraConfig = ''
    AllowSuspend=no
    AllowHibernation=no
    AllowHybridSleep=no
    AllowSuspendThenHibernate=no
  '';
}
