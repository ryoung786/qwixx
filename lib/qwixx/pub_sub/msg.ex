defmodule Qwixx.PubSub.Msg do
  @moduledoc false
  defstruct ~w/event game data/a

  defmodule Mark do
    @moduledoc false
    defstruct ~w/player_name color number/a
  end
end
