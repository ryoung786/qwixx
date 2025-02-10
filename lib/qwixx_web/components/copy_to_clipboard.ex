defmodule QwixxWeb.Component.CopyToClipboard do
  @moduledoc """
  Implement of Dialog components from https://ui.shadcn.com/docs/components/dialog
  """
  use QwixxWeb.Component

  import QwixxWeb.Components

  attr :id, :string, required: true, doc: "required for hook"
  attr :target, :string, required: true
  attr :class, :string, default: ""

  def button(assigns) do
    ~H"""
    <button
      id={@id}
      phx-hook="CopyToClipboardHook"
      data-target={@target}
      class={[
        "rounded-lg grid place-items-center p-2 hover:bg-yellow-500 active:bg-yellow-600 active:scale-90 relative",
        @class
      ]}
    >
      <.icon name="lucide-copy-check" class="w-5 h-5 absolute opacity-0" />
      <.icon name="lucide-copy" class="w-5 h-5" />
    </button>
    """
  end
end
