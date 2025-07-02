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

## TODO

 - [ ] Add option to also add a package definition to `flake.nix`, probably using `deps_nix`.
 - [ ] Add option to specify whether tailwind and esbuild should actually be installed.
