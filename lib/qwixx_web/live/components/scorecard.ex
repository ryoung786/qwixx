defmodule QwixxWeb.Components.Scorecard do
  use QwixxWeb, :live_component
  import Ecto.Changeset
  alias Qwixx.GameServer
  alias Qwixx.Validation
  alias Qwixx.Scorecard
  alias Qwixx.ScorecardRow, as: Row

  @impl true
  def handle_event("mark", params, socket) do
    %{code: code, name: name} = socket.assigns

    with {:ok, %{color: color, number: num}} <- normalize_mark_params(params),
         {:ok, game} <- GameServer.mark(code, name, color, num) do
      player = Map.get(game.players, name)

      # {:noreply,
      #  assign(socket, scorecard: player.scorecard, valid_moves: Validation.valid_moves(game, name))}
      {:noreply, socket}
    else
      {:error, %Ecto.Changeset{}} -> {:noreply, socket |> flash(:error, "Invalid input")}
      {:error, err} -> {:noreply, socket |> flash(:error, err)}
    end
  end

  @impl true
  def handle_event("pass", _params, socket) do
    %{code: code, name: name} = socket.assigns

    with {:ok, game} <- GameServer.pass(code, name) do
      {:noreply, assign(socket, game: game)}
    else
      {:error, err} -> {:noreply, put_flash(socket, :info, err)}
    end
  end

  defp normalize_mark_params(params) do
    types = %{
      color: {:parameterized, Ecto.Enum, Ecto.Enum.init(values: ~w(red yellow blue green)a)},
      number: :integer
    }

    {%{}, types}
    |> cast(params, [:color, :number])
    |> validate_inclusion(:color, ~w(blue green red yellow)a)
    |> validate_inclusion(:number, 2..12)
    |> apply_action(:normalize)
  end

  defp flash(socket, info_or_error, msg) do
    send(self(), {:put_flash, info_or_error, msg})
    socket
  end
end
