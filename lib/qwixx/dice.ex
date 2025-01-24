defmodule Qwixx.Dice do
  @moduledoc false
  @derive Jason.Encoder
  defstruct red: 1, yellow: 1, blue: 1, green: 1, white: {1, 1}

  def roll do
    %__MODULE__{
      red: :rand.uniform(6),
      yellow: :rand.uniform(6),
      blue: :rand.uniform(6),
      green: :rand.uniform(6),
      white: {:rand.uniform(6), :rand.uniform(6)}
    }
  end
end
