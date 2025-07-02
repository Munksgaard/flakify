defmodule Mix.Tasks.Flakify.InstallTest do
  use ExUnit.Case, async: true
  import Igniter.Test

  test "it adds a flake.nix and patches config.exs" do
    # generate a test project
    phx_test_project()
    # run our task
    |> Igniter.compose_task("flakify.install", [])
    # see tools in `Igniter.Test` for available assertions & helpers
    |> assert_creates("flake.nix")
    |> assert_has_patch("config/config.exs", """
    40 40   |    cd: Path.expand("../assets", __DIR__),
    41 41   |    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
    42    - |  ]
       42 + |  ],
       43 + |  path: System.get_env("MIX_ESBUILD_PATH"),
       44 + |  version_check: false
    43 45   |
    44 46   |# Configure tailwind (the version is required)
         ...|
    51 53   |    ),
    52 54   |    cd: Path.expand("..", __DIR__)
    53    - |  ]
       55 + |  ],
       56 + |  path: System.get_env("MIX_TAILWIND_PATH"),
       57 + |  version_check: false
    54 58   |
    55 59   |# Configures Elixir's Logger
    """)
  end
end
