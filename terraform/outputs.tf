output "servers" {
  value = {
    for name, stack in module.stack : name => {
      ipv4 = stack.ipv4
      ipv6 = stack.ipv6
      fqdn = stack.fqdn
    }
  }
}
