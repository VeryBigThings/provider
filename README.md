# Provider

Provider is a library which helps managing the operator configuration of a system.

The term operator configuration refers to the settings which have to be provided by the operator of the system before the system is started. Typical examples include database credentials (host, database name, login, password), http and https ports, 3rd party API keys, and such. On the other hand, things such as Ecto database adapter, or dev/test-only variations such as mocks, are not a part of operator configuration.

Provider offers the following features:

- Consolidation of operator settings into a single place
- Basic strong typing (automatic conversion of external settings to string, integer, or boolean)
- Compile time guarantees
- Runtime validation during the system startup
- Automatic creation of operator templates, such as .env file which lists all configuration parameters
- In-code provisioning of dev/test defaults, which removes the need to use external files such as .envrc, or manage duplicate settings in CI yamls

Provider was born out of real need and is based on lessons learned and issues experienced with config scripts and app config. Provider doesn't use app config, and is instead only focused on fetching values from external sources, such as OS env. The responsibility of working with those values is left to the client.

Provider is currently used in a few small projects, but it's not exhaustively tested nor optimized. The API is not considered as stable, and it may change significantly. Provider currently only supports the features needed by the projects it powers. Therefore, it has a couple of limitations:

- Provider can't be used to provide compile-time settings or to configure applications which require the settings before the main app is started (such as Kernel or Logger). In these cases you'll still need to use config.exs & friends.
- Only OS env is currently supported as an external source.
- No support for `nil` or empty strings. Each configured value has to be provided, and it can't be an empty string.

Tackling these shortcomings is on the roadmap, but it hasn't happen yet, because there was no actual need to address them so far.

## Quick start

Add provider as a dependency:

```elixir
defmodule MySystem.MixProject do
  # ...

  defp deps do
    [
      {:provider, github: "verybigthings/provider"},
      # ...
    ]
  end
end
```

Create a module where you'll consolidate your configuration:

```elixir
defmodule MySystem.Config do
  use Provider,
    source: Provider.SystemEnv,
    params: [
      # The `:dev` option sets a dev/test default. This default won't be used in `:prod` mix env.
      {:db_host, dev: "localhost"},

      # The `:test` option overrides the default in the test mix env.
      {:db_name, dev: "my_db_dev", test: "my_db_test"},

      # The `:default` option sets a default in all mix envs, which means that this setting is
      # optional.
      #
      # Owing to `type: :integer`, the external input will be converted into an integer. An error
      # will be raised if this conversion fails.
      {:db_pool_size, type: :integer, default: 10},

      # ...
    ]
end
```

Validate configuration during app startup:

```elixir
defmodule MySystem.Application do
  use Application

  def start(_type, _args) do
    MySystem.Config.validate!()

    # ...
  end

  # ...
end

```

Use config module functions to fetch the values:

```elixir
defmodule MySystem.Repo do
  use Ecto.Repo,
    otp_app: :my_system,
    adapter: Ecto.Adapters.Postgres

  @impl Ecto.Repo
  def init(_type, config) do
    {:ok,
      Keyword.merge(
        config,
        hostname: MySystem.Config.db_host(),
        database_name: MySystem.Config.db_name(),
        pool_size: MySystem.Config.db_pool_size(),
        # ...
      )
    }
  end
end
```

Invoke `MySystem.Config.template()` in prod Mix env to generate a .env template with all configuration parameters. The function will return a string which you can print to screen or save to a file.

## Documentation

Since this library is not currently published on hex, you need to build the documentation locally, or read the [moduledoc in source](https://github.com/VeryBigThings/provider/blob/master/lib/provider.ex#L2).

## Alternatives

A couple of libraries with similar features are available:

- [Vapor](https://github.com/keathley/vapor)
- [Skogsrå](https://github.com/gmtprime/skogsra)
- [Specify](https://github.com/Qqwy/elixir-specify)
