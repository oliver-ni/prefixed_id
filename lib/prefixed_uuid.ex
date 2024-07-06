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
    prefix =
      if opts[:primary_key] do
        Keyword.get(opts, :prefix) || raise "The :prefix option is required for primary keys."
      else
        field = Keyword.fetch!(opts, :field)
        schema = Keyword.fetch!(opts, :schema)
        %{related: related, related_key: related_key} = schema.__schema__(:association, field)
        {:parameterized, __MODULE__, %{prefix: prefix}} = related.__schema__(:type, related_key)
        prefix
      end

    if String.contains?(prefix, "_") do
      raise "The prefix must not contain an underscore."
    end

    %{prefix: prefix}
  end

  @impl true
  def cast(<<_::288>> = hex_uuid, params) do
    Ecto.UUID.cast(hex_uuid)
    |> cast(params)
  end

  @impl true
  def cast(<<_::128>> = raw_uuid, params) do
    load(raw_uuid, nil, params)
  end

  @impl true
  def cast(value, %{prefix: prefix}) do
    with [^prefix, base62_uuid] <- String.split(value, "_"),
         {:ok, _} <- Nifs.base62_decode(base62_uuid) do
      value
    else
      _ -> :error
    end
  end

  @impl true
  def load(nil, _loader, _params) do
    nil
  end

  @impl true
  def load(<<uuid::128>>, _loader, %{prefix: prefix}) do
    prefix <> "_" <> Nifs.base62_encode(uuid)
  end

  @impl true
  def dump(nil, _dumper, _params) do
    nil
  end

  @impl true
  def dump(value, _dumper, %{prefix: prefix}) do
    with [^prefix, base62_uuid] <- String.split(value, "_"),
         {:ok, uuid} <- Nifs.base62_decode(base62_uuid) do
      <<uuid::128>>
    else
      _ -> :error
    end
  end

  @impl true
  def autogenerate(%{prefix: prefix}) do
    prefix <> "_" <> Nifs.base62_encode(Nifs.generate_numeric_uuidv7())
  end
end
