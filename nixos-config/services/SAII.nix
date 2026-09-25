{ config, pkgs, ... }: {
  systemd.user.services.sway-audio-idle-inhibit = {
    Unit = {
      Description = "Prevent idle/sleep when audio is playing";
    };

    Service = {
      Type = "simple";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
      ExecStart = "${pkgs.sway-audio-idle-inhibit}/bin/sway-audio-idle-inhibit";
      Restart = "on-failure";
      RestartSec = "5";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
