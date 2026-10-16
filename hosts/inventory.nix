{
  domain = "karolbroda.com";

  # can decrypt every secret
  admins = ["age1fpupstjs0zr4lrs4ucz87wz5ll9e3h53h3495hupjh0n0qkpt53qpywjur"];

  hosts = {
    matrix = {
      hcloud.serverType = "cx23";
    };

    desk = {
      hcloud.serverType = "cx23";
      # ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
      ageKey = "age1v5h3jfn877tgn7av3zd67mphmqqcx0rp7u3dxww3y364f8ssj9qsz66dnd";
    };
  };
}
