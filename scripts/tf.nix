_: {
  description = "opentofu with credentials from sops and servers from the host inventory";
  rest = "tofu args";
  text = ''
    case "''${1:-}" in
    plan | apply | destroy | import | refresh | console | validate) write_inventory ;;
    esac

    prepare_tofu
    exec tofu -chdir="$TOFU_DIR" "$@"
  '';
}
