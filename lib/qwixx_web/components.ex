defmodule QwixxWeb.Components do
  @moduledoc false
  use Phoenix.Component

  import QwixxWeb.CoreComponents

  alias Phoenix.LiveView.JS
  alias Qwixx.Scorecard

  embed_templates "components/*.html"

  attr :player_name, :string, required: true
  attr :scorecard, :map, required: true
  def scorecard(assigns)

  attr :player_name, :string, required: true
  attr :color, :atom, required: true
  attr :row, :list, required: true
  def scorecard_row(assigns)

  attr :marked?, :boolean, default: false
  def pass_block(assigns)

  attr :highlight_white?, :boolean, default: true
  attr :dice, :map, required: true
  def dice(assigns)

  attr :n, :integer, required: true
  attr :color, :atom, default: :white
  attr :class, :string, default: nil

  def dice_icon(assigns) do
    {light, dark} =
      case Map.get(assigns, :color) do
        :red -> {"bg-red-100", "bg-red-600"}
        :yellow -> {"bg-amber-50", "bg-amber-500"}
        :blue -> {"bg-blue-100", "bg-blue-600"}
        :green -> {"bg-green-100", "bg-green-600"}
        :white -> {"bg-gray-100", "bg-black"}
      end

    assigns = assign(assigns, light: light, dark: dark)

    ~H"""
    <div class={["rounded", @light]}>
      <.icon name={"lucide-dice-#{@n}"} class={"w-10 h-10 #{@class} #{@dark}"} />
    </div>
    """
  end
end
