{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.moq-relay;
in
{
  options.services.moq-relay = {
    enable = lib.mkEnableOption (lib.mdDoc "moq-relay");
    port = lib.mkOption {
      type = lib.types.port;
      default = 443;
      description = "Relay server port";
    };
    tls_cert = lib.mkOption {
      type = lib.types.string;
      description = "Path to TLS certificate";
    };
    tls_key = lib.mkOption { description = "Path to TLS key"; };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.moq-relay = {
      description = "Media over QUIC relay server";
      path = [ pkgs.moq-relay ];
      script = ''
        set -euo pipefail
        moq-relay --bind [::]:${builtins.toString cfg.port} --tls-cert ${cfg.tls_cert} --tls-key ${cfg.tls_key} 
      '';

      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "root";
        Restart = "1s";
      };
    };
  };
}
