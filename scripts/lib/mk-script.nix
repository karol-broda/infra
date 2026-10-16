# builds one script from a spec:
#   description    one line, for help, the devshell banner and `nix flake show`
#   text           bash body
#   args           positional arguments: {name, description?, choices?, optional?}.
#                  each is validated and set as a shell variable of the same name.
#                  scripts with args get -h/--help; scripts without pass it through.
#   rest           name of trailing arguments left in "$@", null to reject extras
#   env            readonly variables (lists become arrays)
#   runtimeInputs  extra packages on PATH
{
  lib,
  pkgs,
  prelude, # bash sourced before argument parsing
  setup, # bash sourced after argument parsing
  env,
  runtimeInputs,
}: name: specArgs: let
  spec =
    {
      args = [];
      rest = null;
      env = {};
      runtimeInputs = [];
    }
    // specArgs;

  validName = n: builtins.match "[a-z_][a-z0-9_]*" n != null;

  renderValue = v:
    if builtins.isList v
    then "(${lib.escapeShellArgs v})"
    else lib.escapeShellArg (toString v);

  renderEnv = vars: lib.concatStrings (lib.mapAttrsToList (k: v: "readonly ${k}=${renderValue v}\n") vars);

  isOptional = arg: arg.optional or false;
  required = lib.length (lib.filter (arg: !isOptional arg) spec.args);

  usage = let
    argLine = lib.concatStringsSep " " (
      [name]
      ++ map (arg:
        if isOptional arg
        then "[${arg.name}]"
        else "<${arg.name}>")
      spec.args
      ++ lib.optional (spec.rest != null) "[${spec.rest}...]"
    );
    argHelp = arg:
      "  ${arg.name}"
      + lib.optionalString (arg ? description) "  ${arg.description}"
      + lib.optionalString (arg ? choices) " (one of: ${lib.concatStringsSep ", " arg.choices})"
      + "\n";
  in
    "usage: ${argLine}\n\n${spec.description}\n"
    + lib.optionalString (spec.args != []) "\n${lib.concatMapStrings argHelp spec.args}";

  parseArg = arg: let
    var = "$" + arg.name;
  in
    ''
      ${arg.name}=''${1:-}
      (($#)) && shift
    ''
    + lib.optionalString (arg ? choices) ''
      if [[ -n ${var} ]] && ! one_of "${var}" ${lib.escapeShellArgs arg.choices}; then
        die "invalid ${arg.name} '${var}' (expected one of: ${lib.concatStringsSep ", " arg.choices})"
      fi
    '';

  parser = lib.optionalString (spec.args != [] || spec.rest == null) (
    ''
      _usage() {
        printf '%s' ${lib.escapeShellArg usage} >&2
        exit "''${1:-2}"
      }
    ''
    + lib.optionalString (spec.args != []) ''
      case "''${1:-}" in -h | --help) _usage 0 ;; esac
      (($# >= ${toString required})) || _usage
    ''
    + lib.concatMapStrings parseArg spec.args
    + lib.optionalString (spec.rest == null) ''
      (($# == 0)) || _usage
    ''
  );

  zshCompletion = let
    fn = "_script_" + lib.replaceStrings ["-"] ["_"] name;
    argSpec = i: arg: "${toString (i + 1)}:${arg.name}:${
      if arg ? choices
      then "(${lib.concatStringsSep " " arg.choices})"
      else " "
    }";
    specs = lib.imap0 argSpec spec.args ++ lib.optional (spec.rest != null) "*:${spec.rest}:_default";
  in
    lib.optionalString (specs != []) ''
      ${fn}() { _arguments ${lib.escapeShellArgs specs}; }
      compdef ${fn} ${name}
    '';
in
  assert lib.assertMsg (lib.all (arg: validName arg.name) spec.args)
  "script ${name}: argument names must be valid shell identifiers";
    pkgs.writeShellApplication {
      inherit name;
      runtimeInputs = runtimeInputs ++ spec.runtimeInputs;
      text = lib.concatStringsSep "\n" [
        (renderEnv (env // spec.env))
        prelude
        parser
        setup
        spec.text
      ];
      meta = {inherit (spec) description;};
      passthru = {
        isScript = true;
        inherit zshCompletion;
      };
    }
