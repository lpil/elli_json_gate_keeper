# Elli.JsonGateKeeper middleware.

Request bodies are decoded from JSON if present. Bodies containing invalid
JSON are rejected with 400.

Response bodies are encoded into JSON. The `content-type: application/json`
header is added to encoded requests.

This is a rather heavy handed approach, only suited to applications that
only consume JSON bodies.


## Installation

Add the dep.

```elixir
def deps do
  [
    {:elli_json_gate_keeper "~> 0.1.0"}
  ]
end
```

Add to your Elli middleware stack when starting Elli.

```elixir
def start(_type, _args) do
  import Supervisor.Spec, warn: false

  middleware_stack = [
    {Elli.JsonGateKeeper, []},
    {YourElliHandler []}
  ]

  elli_config = [
    callback: :elli_middleware,
    callback_args: [mods: middleware_stack]
  ]

  children = [
    worker(:elli, [elli_config])
  ]

  Supervisor.start_link(children, strategy: :one_for_one, name: Dylan.Supervisor)
end
```
