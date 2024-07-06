defmodule PrefixedUUID.Nifs do
  @moduledoc """
  Rust NIFs used by the `PrefixedUUID` module.
  """

  use Rustler, otp_app: :prefixed_uuid, crate: "prefixed_uuid"

  @doc """
  Encodes a 128-bit number as a Base62 string.
  """
  @spec base62_encode(number()) :: String.t()
  def base62_encode(_num), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Decodes a Base62 string into a 128-bit number.
  """
  @spec base62_decode(String.t()) :: {:ok, number()} | :error
  def base62_decode(_input), do: :erlang.nif_error(:nif_not_loaded)

  @doc """
  Generates a UUIDv7 as a 128-bit number.
  """
  @spec generate_numeric_uuidv7() :: number()
  def generate_numeric_uuidv7(), do: :erlang.nif_error(:nif_not_loaded)
end
