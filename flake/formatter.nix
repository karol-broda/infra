{inputs, ...}: {
  imports = [inputs.treefmt-nix.flakeModule];

  perSystem.treefmt = {
    projectRootFile = "flake.nix";

    programs = {
      alejandra.enable = true;
      deadnix.enable = true;
      terraform.enable = true;
      shfmt.enable = true;
      shellcheck = {
        enable = true;
        external-sources = true;
        source-path = "SCRIPTDIR";
      };
    };

    settings.formatter = {
      shfmt.includes = ["scripts/*"];
      shellcheck.includes = ["scripts/*"];
    };
  };
}
