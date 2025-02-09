defmodule QwixxWeb.PlaygroundLive.Stories do
  @moduledoc false
  use QwixxWeb, :html
  use QwixxWeb.Component

  import QwixxWeb.Components

  alias QwixxWeb.Component.Card

  embed_templates "*.html"

  attr :id, :string, required: true
  slot :description
  slot :title
  slot :usage
  slot :inner_block

  def story(assigns) do
    ~H"""
    <div id={@id} class="mb-8 text-slate-100">
      <h1 class="text-2xl font-bold mb-2  text-yellow-500 drop-shadow-md">{render_slot(@title)}</h1>
      <p class="mb-4">{render_slot(@description)}</p>

      <Card.card class="w-full p-4 mb-4">
        {render_slot(@inner_block)}
      </Card.card>

      {render_slot(@usage)}
    </div>
    """
  end
end
