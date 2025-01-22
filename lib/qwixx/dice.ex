defmodule Qwixx.Dice do
  @moduledoc false
  defstruct red: :rand.uniform(6),
            yellow: :rand.uniform(6),
            blue: :rand.uniform(6),
            green: :rand.uniform(6),
            white: {:rand.uniform(6), :rand.uniform(6)}

  def roll, do: %__MODULE__{}
end
