defmodule PrefixedUUID do
  @moduledoc """
  Ecto type for human-readable prefixed Base62-encoded UUIDs.
  """
  use Ecto.ParameterizedType
  alias PrefixedUUID.Nifs

  @typedoc """
  The human-readable prefixed string format.
  """
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
      opts[:primary_key] -> %{primary_key: true, prefix: get_pkey_prefix(opts)}
      opts[:foreign_key] -> %{field: field, schema: schema}
      true -> raise "Must be used as either a primary or foreign key."
    end
  end

  @impl true
  def cast(nil, _params), do: {:ok, nil}
  def cast(<<_::288>> = hex_uuid, params), do: Ecto.UUID.cast(hex_uuid) |> cast(params)
  def cast(<<_::128>> = raw_uuid, params), do: load(raw_uuid, nil, params)

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

  defp get_pkey_prefix(opts) do
    prefix = Keyword.get(opts, :prefix)
    if is_nil(prefix), do: raise("The :prefix option is required for primary keys.")
    if String.contains?(prefix, "_"), do: raise("The prefix must not contain an underscore.")
    prefix
  end

  defp prefix(%{primary_key: true, prefix: prefix}) do
    prefix
  end

  defp prefix(%{field: field, schema: schema}) do
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
