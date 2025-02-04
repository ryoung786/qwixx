defmodule QwixxWeb.PlaygroundLive.Stories do
  @moduledoc false
  use QwixxWeb, :html
  use QwixxWeb.Component

  import QwixxWeb.Components

  alias QwixxWeb.Component.Card

  embed_templates "*.html"

  def story(assigns) do
    ~H"""
    <div id={@id} class="mb-8">
      <h1 class="text-2xl font-bold mb-2">{render_slot(@title)}</h1>
      <p class="text-slate-400 mb-4">{render_slot(@description)}</p>

      <Card.card class="w-full p-4 mb-4">
        {render_slot(@inner_block)}
      </Card.card>

      <h2 class="text-lg font-semibold mb-2">Usage</h2>
      {render_slot(@usage)}
    </div>
    """
  end
end
