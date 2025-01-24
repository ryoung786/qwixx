defmodule Qwixx do
  @moduledoc """
  Qwixx keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
end

defimpl Jason.Encoder, for: Tuple do
  def encode(tuple, opts) do
    Jason.Encode.list(Tuple.to_list(tuple), opts)
  end
end
