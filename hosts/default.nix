{
  domain = "karolbroda.com";

  hosts = {
    matrix = {
      system = "x86_64-linux";
      profile = "server";
      hcloud.serverType = "cx23";
      dns.extra = [
        {
          name = "_matrix._tcp.matrix";
          type = "SRV";
          data = {
            priority = 10;
            weight = 5;
            port = 8448;
            target = "matrix.karolbroda.com";
          };
        }
      ];
    };

    desk = {
      system = "x86_64-linux";
      profile = "server";
      hcloud.serverType = "cx23";
    };
  };
}
