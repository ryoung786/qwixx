# Qwixx

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

- Official website: https://www.phoenixframework.org/
- Guides: https://hexdocs.pm/phoenix/overview.html
- Docs: https://hexdocs.pm/phoenix
- Forum: https://elixirforum.com/c/phoenix-forum
- Source: https://github.com/phoenixframework/phoenix


# TODO next
- game over screen
- smaller bg image
- more prominent highlight of current dice
- modal-ish UI event for turn change, player added/removed
- mobile layout
- end of action must animate events in sequence, not all at once
  - (two colors locked by different players during the white action, only one animation is shown)
  - requires rethinking event-driven system
