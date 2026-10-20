{ ... }: {
  powerManagement.enable = true;

  ### Power management utilities
  # services.thermald.enable = true;
  # services.auto-cpufreq.enable = true;

  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = false;
  };
}
