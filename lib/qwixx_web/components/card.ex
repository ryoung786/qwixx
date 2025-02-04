defmodule QwixxWeb.Component.Card do
  @moduledoc """
  Implement of card components from https://ui.shadcn.com/docs/components/card
  """
  use QwixxWeb.Component

  @doc """
  Card component

  ## Examples:

        <.card>
          <.header>
            <.title>Card title</.card_title>
            <.description>Card subtitle</.card_description>
          </.header>
          <.content>
            Card text
          </.content>
          <.footer>
            <.button>Button</.button>
          </.footer>
        </.card>
  """

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def card(assigns) do
    ~H"""
    <div class={classes(["rounded-xl border bg-card text-card-foreground shadow", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def header(assigns) do
    ~H"""
    <div class={classes(["flex flex-col space-y-1.5 p-6", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def title(assigns) do
    ~H"""
    <h3 class={classes(["text-2xl font-semibold leading-none tracking-tight", @class])} {@rest}>
      {render_slot(@inner_block)}
    </h3>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def description(assigns) do
    ~H"""
    <p class={classes(["text-sm text-muted-foreground", @class])} {@rest}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def content(assigns) do
    ~H"""
    <div class={classes(["p-6 pt-0", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true
  attr :rest, :global

  def footer(assigns) do
    ~H"""
    <div class={classes(["flex items-center justify-between p-6 pt-0 ", @class])} {@rest}>
      {render_slot(@inner_block)}
    </div>
    """
  end
end
