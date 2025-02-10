defmodule QwixxWeb.PlaygroundLive do
  @moduledoc false
  use QwixxWeb, :live_view

  alias Phoenix.LiveView.JS
  alias QwixxWeb.Component.Separator
  alias QwixxWeb.Component.Sidebar
  alias QwixxWeb.PlaygroundLive.Stories

  @sidebar_data %{
    nav_main: [
      %{
        title: "Getting Started",
        url: "#",
        items: [%{title: "Installation", url: "#"}, %{title: "Project Structure", url: "#"}]
      },
      %{
        title: "Components",
        url: "#",
        items: [
          %{title: "Copy to Clipboard", url: "#copy-to-clipboard-story"},
          %{title: "Player List", url: "#player-list-story", is_active: true}
        ]
      }
    ]
  }

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, data: @sidebar_data)}
  end
end
