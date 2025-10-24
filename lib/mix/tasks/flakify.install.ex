defmodule Mix.Tasks.Flakify.Install.Docs do
  @moduledoc false

  @spec short_doc() :: String.t()
  def short_doc do
    "Modify your Phoenix project to work in a Nix flake development shell"
  end

  @spec example() :: String.t()
  def example do
    "mix igniter_install flakify"
  end

  @spec long_doc() :: String.t()
  def long_doc do
    """
    #{short_doc()}

    This task adds a `flake.nix` to your project with tailwind and esbuild
    installed, and alters your tailwind and esbuild configuration to use the
    versions from your Nix flake.

    ## Example

    ```sh
    #{example()}
    ```

    ## Options

    * `--package` - Include a package derivation for the Mix release build of the project (default). The package uses [deps_nix](https://hexdocs.pm/deps_nix/readme.html) to convert Mix dependencies to Nix derivations.
    * `--no-package` - Do not include a package derivation.
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
        schema: [package: :boolean],
        # Default values for the options in the `schema`
        defaults: [package: true],
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
            commonEnv = pkgs: {
              MIX_TAILWIND_PATH = pkgs.lib.getExe pkgs.tailwindcss_4;
              MIX_ESBUILD_PATH = pkgs.lib.getExe pkgs.esbuild;
            };

            beam_pkgs = pkgs: pkgs.beam.packagesWith pkgs.beam.interpreters.erlang;
          in {
            devShells = forEachSupportedSystem ({ pkgs }: {
              default = pkgs.mkShell {
                packages =
                  (if pkgs.stdenv.isLinux then [ pkgs.inotify-tools ] else [ ]) ++
                    [ (beam_pkgs pkgs).elixir pkgs.tailwindcss_4 pkgs.esbuild ];
                env = commonEnv pkgs;
              };
            });

            #{if Keyword.get(igniter.args.options, :package), do: package_text(Igniter.Project.Application.app_name(igniter))}
          };
      }
      """)
      |> then(fn igniter ->
        if Igniter.Project.Deps.has_dep?(igniter, :flakify) do
          Igniter.Project.Deps.remove_dep(igniter, :flakify)
        else
          igniter
        end
      end)
      |> maybe_add_deps_nix()
    end

    defp package_text(app_name) do
      """
      packages = forEachSupportedSystem ({ pkgs }: rec {
              #{app_name} = let
                mixNixDeps = pkgs.callPackages ./deps.nix { };
                pname = "#{app_name}";
                version = "0.0.1";
              in (beam_pkgs pkgs).mixRelease {
                inherit pname version mixNixDeps;
                src = pkgs.lib.cleanSource ./.;
                env = commonEnv pkgs;

                postBuild = ''
                  # As shown in
                  # https://github.com/code-supply/nix-phoenix/blob/2ab9b2f63dd85d5d6a85d61bd4fc5c6d07f65643/flake-template/flake.nix#L62-L64
                  ln -sfv ${mixNixDeps.heroicons} deps/heroicons

                  mix do \\
                    loadpaths --no-deps-check, \\
                    assets.deploy --no-deps-check
                '';

                meta.mainProgram = "server";
              };
              default = #{app_name};
            });
      """
    end

    defp maybe_add_deps_nix(igniter) do
      if Keyword.get(igniter.args.options, :package) do
        igniter
        |> then(fn igniter ->
          Igniter.Project.Deps.add_dep(igniter, {:deps_nix, "~> 2.5"})
        end)
        |> then(&Igniter.apply_and_fetch_dependencies/1)
        |> then(&Igniter.Project.TaskAliases.add_alias(&1, "deps.get", ["deps.get", "deps.nix"]))
        |> then(&Igniter.add_task(&1, "deps.get"))
      else
        igniter
      end
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
