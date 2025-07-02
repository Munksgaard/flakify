defmodule Mix.Tasks.Flakify.Install.Docs do
  @moduledoc false

  @spec short_doc() :: String.t()
  def short_doc do
    "A short description of your task"
  end

  @spec example() :: String.t()
  def example do
    "mix flakify --example arg"
  end

  @spec long_doc() :: String.t()
  def long_doc do
    """
    #{short_doc()}

    Longer explanation of your task

    ## Example

    ```sh
    #{example()}
    ```

    ## Options

    * `--example-option` or `-e` - Docs for your option
    """
  end
end

if Code.ensure_loaded?(Igniter) do
  defmodule Mix.Tasks.Flakify.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()}"

    @moduledoc __MODULE__.Docs.long_doc()

    use Igniter.Mix.Task

    @impl Igniter.Mix.Task
    def info(_argv, _composing_task) do
      %Igniter.Mix.Task.Info{
        # Groups allow for overlapping arguments for tasks by the same author
        # See the generators guide for more.
        group: :flakify,
        # *other* dependencies to add
        # i.e `{:foo, "~> 2.0"}`
        adds_deps: [],
        # *other* dependencies to add and call their associated installers, if they exist
        # i.e `{:foo, "~> 2.0"}`
        installs: [],
        # An example invocation
        example: __MODULE__.Docs.example(),
        # a list of positional arguments, i.e `[:file]`
        positional: [],
        # Other tasks your task composes using `Igniter.compose_task`, passing in the CLI argv
        # This ensures your option schema includes options from nested tasks
        composes: [],
        # `OptionParser` schema
        schema: [],
        # Default values for the options in the `schema`
        defaults: [],
        # CLI aliases
        aliases: [],
        # A list of options in the schema that are required
        required: []
      }
    end

    @impl Igniter.Mix.Task
    def igniter(igniter) do
      # Do your work here and return an updated igniter
      igniter
      |> Igniter.Project.Config.configure(
        "config.exs",
        :tailwind,
        [:path],
        {:code,
         Sourceror.parse_string!("""
         System.get_env("MIX_TAILWIND_PATH")
         """)}
      )
      |> Igniter.Project.Config.configure(
        "config.exs",
        :tailwind,
        [:version_check],
        {:code,
         Sourceror.parse_string!("""
         false
         """)}
      )
      |> Igniter.Project.Config.configure(
        "config.exs",
        :esbuild,
        [:path],
        {:code,
         Sourceror.parse_string!("""
         System.get_env("MIX_ESBUILD_PATH")
         """)}
      )
      |> Igniter.Project.Config.configure(
        "config.exs",
        :esbuild,
        [:version_check],
        {:code,
         Sourceror.parse_string!("""
         false
         """)}
      )
      |> Igniter.create_new_file("flake.nix", """
      {
        inputs = { nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; };

        outputs = inputs:
          let
            supportedSystems =
              [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
            forEachSupportedSystem = f:
              inputs.nixpkgs.lib.genAttrs supportedSystems
              (system: f { pkgs = import inputs.nixpkgs { inherit system; }; });

          in {
            devShells = forEachSupportedSystem ({ pkgs }: {
              default = pkgs.mkShell {
                packages =
                  (if pkgs.stdenv.isLinux then [ pkgs.inotify-tools ] else [ ]) ++
                    [ pkgs.elixir pkgs.tailwindcss_4 pkgs.esbuild pkgs.go ];
                MIX_TAILWIND_PATH = "${pkgs.tailwindcss_4}/bin/tailwindcss";
                MIX_ESBUILD_PATH = "${pkgs.esbuild}/bin/esbuild";
              };
            });
          };
      }
      """)
    end
  end
else
  defmodule Mix.Tasks.Flakify.Install do
    @shortdoc "#{__MODULE__.Docs.short_doc()} | Install `igniter` to use"

    @moduledoc __MODULE__.Docs.long_doc()

    use Mix.Task

    @impl Mix.Task
    def run(_argv) do
      Mix.shell().error("""
      The task 'flakify' requires igniter. Please install igniter and try again.

      For more information, see: https://hexdocs.pm/igniter/readme.html#installation
      """)

      exit({:shutdown, 1})
    end
  end
end
