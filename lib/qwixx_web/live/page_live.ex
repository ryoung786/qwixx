defmodule QwixxWeb.PageLive do
  use QwixxWeb, :live_view
  import Ecto.Changeset
  alias Qwixx.GameServer

  @input_types %{name: :string, code: :string}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, join_changeset: join_changeset(), new_changeset: new_changeset())}
  end

  @impl true
  def handle_event("new", %{"new" => params}, socket) do
    new_changeset(params)
    |> validate_new_input()
    |> apply_action(:create_new)
    |> case do
      {:ok, %{name: name}} ->
        redirect_to_new_game(socket, name)

      {:error, changeset} ->
        {:noreply, assign(socket, new_changeset: changeset)}
    end
  end

  @impl true
  def handle_event("join", %{"join" => params}, socket) do
    join_changeset(params)
    |> validate_join_input()
    |> apply_action(:join)
    |> case do
      {:ok, input} ->
        url = Routes.session_path(socket, :join, code: input.code, name: input.name)
        {:noreply, redirect(socket, to: url)}

      {:error, changeset} ->
        {:noreply, assign(socket, join_changeset: changeset)}
    end
  end

  @impl true
  def handle_event("validate", %{"join" => params}, socket) do
    changeset = join_changeset(params)

    changeset
    |> validate_join_input()
    |> apply_action(:validate)
    |> case do
      {:ok, _input} ->
        {:noreply, assign(socket, join_changeset: changeset)}

      {:error, bad_changeset} ->
        {:noreply, assign(socket, join_changeset: bad_changeset)}
    end
  end

  def new_changeset(input \\ %{}) do
    {%{}, @input_types} |> cast(input, [:name])
  end

  def validate_new_input(changeset) do
    changeset
    |> update_change(:name, &String.trim/1)
    |> validate_required([:name])
    |> validate_length(:name, max: 20)
  end

  def join_changeset(input \\ %{}) do
    {%{}, @input_types} |> cast(input, [:name, :code])
  end

  def validate_join_input(changeset) do
    changeset
    |> update_change(:name, &String.trim/1)
    |> update_change(:code, &String.trim/1)
    |> update_change(:code, &String.upcase/1)
    |> validate_required([:name, :code])
    |> validate_length(:code, is: 4)
    |> validate_length(:name, max: 20)
    |> validate_gameserver_at_code_exists()
  end

  def validate_gameserver_at_code_exists(%{valid?: false} = cs), do: cs

  def validate_gameserver_at_code_exists(cs) do
    case fetch_field(cs, :code) |> GameServer.game_pid() do
      nil -> add_error(cs, :code, "Game does not exist")
      _ -> cs
    end
  end

  defp redirect_to_new_game(socket, name) do
    code = GameServer.new_game_server()
    GameServer.add_player(code, name)

    url = Routes.session_path(socket, :join, code: code, name: name)
    {:noreply, redirect(socket, to: url)}
  end
end
