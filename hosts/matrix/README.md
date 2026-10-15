# matrix

matrix homeserver running tuwunel with cinny web client.

## services

- **tuwunel** - matrix homeserver (conduwuit fork)
- **caddy** - reverse proxy with automatic tls
- **cinny** - web client with catppuccin frappé theme

## endpoints

- `https://matrix.karolbroda.com` - web client and matrix api
- `https://matrix.karolbroda.com:8448` - federation

## configuration

- server type: cx22 (2vcpu, 4gb ram)
- location: nbg1 (nuremberg)
- registration: disabled
- federation: enabled

