defmodule Qwixx.PubSub.Msg do
  defstruct ~w(event game data)a
end

defmodule Qwixx.PubSub.Msg.Mark do
  defstruct ~w(player_name color number)a
end
