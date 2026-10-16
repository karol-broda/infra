{arg, ...}: {
  description = "destroy a server and its dns records";
  args = [arg.host];
  text = ''
    warn "broo, this destroys server '$host' and its dns records"
    info "review the plan below before approving"

    write_inventory
    prepare_tofu
    exec tofu -chdir="$TOFU_DIR" destroy -target="module.stack[\"$host\"]"
  '';
}
