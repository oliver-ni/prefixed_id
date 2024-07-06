defmodule PrefixedID do
  @moduledoc """
  Ecto type for human-readable prefixed Base62-encoded UUIDs.
  """
  use Ecto.ParameterizedType
  alias PrefixedID.Nifs

  @type t :: String.t()

  @impl true
  def type(_params) do
    :uuid
  end

  @impl true
  def init(opts) do
    field = Keyword.fetch!(opts, :field)
    schema = Keyword.fetch!(opts, :schema)

    cond do
      opts[:foreign_key] -> %{foreign_key: true, field: field, schema: schema}
      prefix = opts[:prefix] -> %{prefix: validate_prefix(prefix)}
      true -> raise "Must specify :prefix option if not used as a foreign key."
    end
  end

  defp validate_prefix(prefix) do
    if String.contains?(prefix, "_"), do: raise("The prefix must not contain an underscore.")
    prefix
  end

  @impl true
  def cast(nil, _params), do: {:ok, nil}
  def cast(<<_::128>> = raw_uuid, params), do: load(raw_uuid, nil, params)

  def cast(<<_::288>> = hex_uuid, params) do
    with {:ok, hex_uuid} <- Ecto.UUID.cast(hex_uuid),
         {:ok, raw_uuid} <- Ecto.UUID.dump(hex_uuid) do
      cast(raw_uuid, params)
    end
  end

  def cast(value, params) do
    with {:ok, _} <- to_numeric_uuid(value, params) do
      {:ok, value}
    end
  end

  @impl true
  def load(nil, _loader, _params), do: {:ok, nil}
  def load(<<uuid::128>>, _loader, params), do: {:ok, from_numeric_uuid(uuid, params)}

  @impl true
  def dump(nil, _dumper, _params), do: {:ok, nil}
  def dump(value, _dumper, params), do: to_numeric_uuid(value, params)

  @impl true
  def autogenerate(params) do
    Nifs.generate_numeric_uuidv7()
    |> from_numeric_uuid(params)
  end

  defp prefix(%{prefix: prefix}) do
    prefix
  end

  defp prefix(%{foreign_key: true, field: field, schema: schema}) do
    %{related: related, related_key: related_key} = schema.__schema__(:association, field)
    {:parameterized, __MODULE__, %{prefix: prefix}} = related.__schema__(:type, related_key)
    prefix
  end

  defp to_numeric_uuid(value, params) do
    prefix = prefix(params)

    with [^prefix, base62_uuid] <- String.split(value, "_"),
         {:ok, uuid} <- Nifs.base62_decode(base62_uuid) do
      {:ok, <<uuid::128>>}
    else
      _ -> :error
    end
  end

  defp from_numeric_uuid(uuid, params) do
    prefix(params) <> "_" <> Nifs.base62_encode(uuid)
  end
end
