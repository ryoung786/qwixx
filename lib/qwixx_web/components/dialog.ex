defmodule QwixxWeb.Component.Dialog do
  @moduledoc """
  Implement of Dialog components from https://ui.shadcn.com/docs/components/dialog
  """
  use QwixxWeb.Component

  @doc """
  Dialog component

  ## Examples:

        <.dialog :if={@live_action in [:new, :edit]} id="pro-dialog" show on_cancel={JS.navigate(~p"/p")}>
          <.dialog_content class="sm:max-w-[425px]">
            <.dialog_header>
              <.dialog_title>Edit profile</.dialog_title>
              <.dialog_description>
                Make changes to your profile here click save when you're done
              </.dialog_description>
            </.dialog_header>
              <div class_name="grid gap-4 py-4">
                <div class_name="grid grid-cols_4 items-center gap-4">
                  <.label for="name" class-name="text-right">
                    name
                  </.label>
                  <input id="name" value="pedro duarte" class-name="col-span-3" />
                </div>
                <div class="grid grid-cols-4 items_center gap-4">
                  <.label for="username" class="text-right">
                    username
                  </.label>
                  <input id="username" value="@peduarte" class="col-span-3" />
                </div>
              </div>
              <.dialog_footer>
                <.button type="submit">save changes</.button>
              </.dialog_footer>
              </.dialog_content>
        </.dialog>
  """
  attr :id, :string, required: true
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :class, :string, default: nil
  slot :inner_block, required: true

  def dialog(assigns) do
    ~H"""
    <div
      id={@id}
      phx-mounted={@show && JS.exec("phx-show-modal", to: "##{@id}")}
      phx-show-modal={show(@id)}
      phx-hide-modal={@on_cancel |> hide(@id)}
      class="relative z-50 hidden group/dialog"
    >
      <div
        id={"#{@id}-bg"}
        class="fixed inset-0 bg-black/80  group-data-[state=open]/dialog:animate-in group-data-[state=closed]/dialog:animate-out group-data-[state=closed]/dialog:fade-out-0 group-data-[state=open]/dialog:fade-in-0"
        aria-hidden="true"
      />
      <div
        class="fixed inset-0 flex items-center justify-center overflow-y-auto"
        role="dialog"
        aria-modal="true"
        tabindex="0"
      >
        <.focus_wrap
          id={"#{@id}-wrap"}
          phx-window-keydown={JS.exec("phx-hide-modal", to: "##{@id}")}
          phx-key="escape"
          phx-click-away={JS.exec("phx-hide-modal", to: "##{@id}")}
          class="w-full sm:max-w-[425px]"
        >
          <div
            role="dialog"
            aria-modal="true"
            tabindex="0"
            class={
              classes([
                "fixed left-[50%] top-[50%] z-50 grid w-full max-w-lg translate-x-[-50%] translate-y-[-50%] gap-4 bg-background p-6 shadow-lg duration-200 group-data-[state=open]/dialog:animate-in group-data-[state=closed]/dialog:animate-out group-data-[state=closed]/dialog:fade-out-0 group-data-[state=open]/dialog:fade-in-0 group-data-[state=closed]/dialog:zoom-out-95 group-data-[state=open]/dialog:zoom-in-95 group-data-[state=closed]/dialog:slide-out-to-left-1/2 group-data-[state=closed]/dialog:slide-out-to-top-[48%] group-data-[state=open]/dialog:slide-in-from-left-1/2 group-data-[state=open]/dialog:slide-in-from-top-[48%] sm:rounded-lg",
                @class
              ])
            }
          >
            {render_slot(@inner_block)}

            <button
              type="button"
              class="absolute right-4 top-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:xring-offset-2 focus:ring-white disabled:pointer-events-none group-data-[state=open]/dialog:hover:bg-blue-600 group-data-[state=open]/dialog:text-gray-300"
              phx-click={JS.exec("phx-hide-modal", to: "##{@id}")}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                class="w-5 h-5"
              >
                <path d="M18 6 6 18"></path>
                <path d="m6 6 12 12"></path>
              </svg>
              <span class="sr-only">Close</span>
            </button>
          </div>
        </.focus_wrap>
      </div>
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def header(assigns) do
    ~H"""
    <div class={classes(["flex flex-col space-y-1.5 text-center sm:text-left", @class])}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def title(assigns) do
    ~H"""
    <h3 class={classes(["text-lg font-semibold leading-none tracking-tight", @class])}>
      {render_slot(@inner_block)}
    </h3>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def description(assigns) do
    ~H"""
    <p class={classes(["text-sm text-muted-foreground", @class])}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  attr :class, :string, default: nil
  slot :inner_block, required: true

  def footer(assigns) do
    ~H"""
    <div class={classes(["flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2", @class])}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def show(js \\ %JS{}, id) when is_binary(id) do
    js
    |> JS.set_attribute({"data-state", "open"}, to: "##{id}")
    |> JS.show(to: "##{id}", transition: {"_", "_", "_"}, time: 130)
    |> JS.add_class("overflow-hidden", to: "body")
    |> JS.focus_first(to: "##{id}-content")
  end

  def hide(js \\ %JS{}, id) do
    js
    |> JS.set_attribute({"data-state", "closed"}, to: "##{id}")
    |> JS.hide(to: "##{id}", transition: {"_", "_", "_"}, time: 130)
    |> JS.remove_class("overflow-hidden", to: "body")
    |> JS.pop_focus()
  end

  @doc """
  Trigger this by adding or removing a `data-open` attribute
  """
  def overlay(assigns) do
    ~H"""
    <div class="fixed inset-0 bg-black/80 hidden opacity-0" aria-hidden="true" />
    """
  end

  def color_locked(assigns) do
    ~H"""
    <div
      id="color-locked-dialog"
      class="fixed inset-0 flex items-center justify-center overflow-y-auto hidden"
      role="dialog"
      aria-modal="true"
      tabindex="0"
      phx-hook="DialogHook"
    >
      <div data-overlay class="fixed inset-0 bg-black/80 hidden opacity-0" aria-hidden="true" />
      <div
        data-content
        role="dialog"
        aria-modal="true"
        tabindex="0"
        class="w-3/4 h-24 left-[50%] grid place-items-center opacity-0 -skew-x-6 bg-red-400 data-[color=blue]:bg-blue-400 data-[color=yellow]:bg-amber-300 data-[color=green]:bg-green-400 "
      >
        <div class="flex">
          <QwixxWeb.Components.icon name="hero-lock-closed-solid" />
          <span data-text class="ml-4"></span>
        </div>
      </div>
    </div>
    """
  end
end
