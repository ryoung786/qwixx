defmodule AdminWeb.HomeLive do
  @moduledoc false
  use AdminWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      Hello
    </Layouts.app>
    """
  end
end
