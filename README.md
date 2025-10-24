# Flakify

Easily set up a Nix flake-based development environment for your
Elixir/Phoenix-project.

## Usage

To create a new Phoenix project that's already initialized with a Nix flake, run the following command:

```
mix igniter.new flakify_test --install flakify --with phx.new --with-args="--no-ecto"
```

This will:

 - Add a `flake.nix` with a development shell that contains elixir, tailwind and
   esbuild. And also sets the `MIX_TAILWIND_PATH` and `MIX_ESBUILD_PATH`
   environment variables.

 - Modify `config/config.exs` such that the `esbuild` and `tailwind`
   configurations use `MIX_ESBUILD_PATH` and `MIX_TAILWIND_PATH` respectively to
   find the corresponding executables.

After performing the install, you should be able to run `nix develop -c mix
phx.server` to run the Phoenix server using the flake development environment.

In an existing project, you can run:

```
mix igniter.install flakify
```

After running the installer, flakify will remove itself from your project
dependencies.

## Building a Mix release

When specifying `--package` (this is also the default), flakify will add a
package derivation that builds a Mix release of the Elixir project. It relies on
[deps_nix](https://hexdocs.pm/deps_nix) to convert Mix dependencies to Nix
derivations, so you will need to add the generated `deps.nix` to your git
repository. After doing so, building should be as simple as:

```console
$ nix build
```

The resulting release can be run by e.g. the following command:

```console
PHX_SERVER=1 SECRET_KEY_BASE=`mix phx.gen.secret` RELEASE_COOKIE="secret" ./result/bin/your_app start
```

## TODO

 - [x] Add option to also add a package definition to `flake.nix`, probably using `deps_nix`.
 - [ ] Add option to specify whether tailwind and esbuild should actually be installed.
 - [ ] Add option to add an .envrc file for direnv
 - [ ] Add option to specify the nixos/nixpkgs version to use
 - [ ] Add option to specify which version of elixir/beam to use
 - [ ] Add option to add a nixos module definition and/or systemd service definition
