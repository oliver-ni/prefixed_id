# PrefixedID

This package provides an Ecto type for human readable IDs, like `user_2x2QlH09G3tPrptOPzhr5`, consisting of a string prefix plus a Base62-encoded UUIDv7.

Having different prefixes for each "ID type" makes them more readable, prevents human error, and enables features such as polymorphic lookup.

UUIDv7 generation and Base62 encode/decode are implemented in Rust using a NIF.

Inspiration for this package is taken from:

- <https://danschultzer.com/posts/prefixed-base62-uuidv7-object-ids-with-ecto>
- <https://dev.to/stripe/designing-apis-for-humans-object-ids-3o5a>

## Installation

The package can be installed by adding `prefixed_id` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:prefixed_id, "~> 0.1.0"}
  ]
end
```

## Usage

Use `PrefixedID` as the `@primary_key` type in your schema, providing a `prefix`:

```elixir
defmodule MyApp.User do
  use Ecto.Schema
  @primary_key {:id, PrefixedID, prefix: "user", autogenerate: true}
  ...
end
```

If referencing a table with a `PrefixedID` primary key, specify `@foreign_key_type`:

```elixir
defmodule MyApp.UserToken do
  use Ecto.Schema
  @foreign_key_type PrefixedID
  ...
end
```

To use `PrefixedID` for all keys, you can define your own `Schema` module:

```elixir
defmodule MyApp.Schema do
  defmacro __using__(opts) do
    id_prefix = Keyword.fetch!(opts, :id_prefix)

    quote do
      use Ecto.Schema
      @primary_key {:id, PrefixedID, prefix: unquote(id_prefix), autogenerate: true}
      @foreign_key_type PrefixedID
      @timestamps_opts [type: :utc_datetime_usec]
    end
  end
end
```
