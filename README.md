# infra

NixOS configuration for piquel-fr's machines, deployed with
[deploy-rs](https://github.com/serokell/deploy-rs).

## Layout

Every file under `nix/` is a [flake-parts](https://flake.parts) module, imported
with [import-tree](https://github.com/vic/import-tree). Paths containing `/_` are
skipped: they hold plain NixOS modules, such as hardware configurations.

- `nix/hosts.nix`: the host registry. Each `hosts.<name>` entry becomes
  `nixosConfigurations.<name>` and the deploy-rs node `deploy.nodes.<name>`.
- `nix/hosts/<name>/`: a host's entry and its own configuration.
- `nix/modules/`: NixOS modules every host imports, as `nixosModules.<name>`.
- `secrets/`: [agenix](https://github.com/ryantm/agenix) secrets and their recipients.

## Deploying

From `nix develop`, which provides `deploy` and `agenix`:

```sh
deploy .#piquel-pi
```

A host still running a configuration from before this layout needs sudo's
password once, since passwordless sudo only applies after that deploy:

```sh
deploy .#piquel-pi --interactive-sudo true
```

deploy-rs connects as the operator's user, `piquel` (the `admin` option in
`nix/modules/admin.nix`), and activates through passwordless sudo. If the host
stops answering after activation, it rolls back to the previous generation.

`nix flake check` evaluates every host and builds the deploy checks for the
current platform's hosts.
