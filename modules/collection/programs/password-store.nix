{
  config,
  hjem-lib,
  lib,
  pkgs,
  ...
}: let
  inherit (hjem-lib) envVarType;
  inherit (lib.modules) mkIf;
  inherit (lib.options) literalExpression mkEnableOption mkOption mkPackageOption;

  cfg = config.rum.programs.password-store;
in {
  options.rum.programs.password-store = {
    enable = mkEnableOption "password-store";

    package = mkPackageOption pkgs "pass" {
      nullable = true;
      extraDescription = ''
        To get extensions to work, you will need to wrap the pass derivation
        with the extensions you want. Consult the [pass extensions directory]
        for a list of available extensions.

        [pass extensions directory]: https://github.com/NixOS/nixpkgs/tree/master/pkgs/tools/security/pass/extensions
      '';
      example = ''
        pkgs.pass.withExtensions (exts: [
          exts.pass-otp
          exts.pass-import
        ])
      '';
    };

    settings = mkOption {
      type = envVarType;
      default = {};
      example = literalExpression ''
        {
          PASSWORD_STORE_DIR = "''${config.xdg.data.directory}/password-store";
          PASSWORD_STORE_CLIP_TIME = 60;
        }
      '';
      description = ''
        The configuration added to `environment.sessionVariables`, as
        password-store is configured entirely through environment variables.
        Please reference {manpage}`pass(1)` for configuration options.

        These variables are only loaded by modules such as
        {option}`rum.programs.fish.enable`. See [environmental variables] for
        more information.

        [environmental variables]: https://github.com/snugnug/hjem-rum#environmental-variables
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [cfg.package];
    environment.sessionVariables = cfg.settings;
  };
}
