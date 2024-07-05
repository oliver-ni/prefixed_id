defmodule PrefixedUUID do
  @moduledoc """
  Documentation for `PrefixedUUID`.
  """

  use Rustler, otp_app: :prefixed_uuid, crate: "prefixed_uuid"

  # When your NIF is loaded, it will override this function.
  def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
end
