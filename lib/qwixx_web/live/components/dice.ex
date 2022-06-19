defmodule QwixxWeb.Components.Dice do
  use Phoenix.Component

  def dice(assigns) do
    ~H"""
    <div class={"dice #{@color} #{if @highlight, do: "highlight"}"}>
      <div class="face">
        <%= for _ <- 1..@roll do %>
          <span class="pip"></span>
        <% end %>
      </div>
    </div>
    """
  end
end
