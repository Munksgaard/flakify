# Flakify

Easily set up a Nix flake-based development environment for your
Elixir/Phoenix-project.

## Usage

To create a new Phoenix project that's already initialized with a Nix flake, run the following command:

```
mix igniter.new flakify_test --install flakify@github:Munksgaard/flakify --with phx.new --with-args="--no-ecto"
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

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `flakify` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:flakify, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/flakify>.
