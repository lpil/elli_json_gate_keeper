defmodule Elli.JsonGateKeeperTest do
  use ExUnit.Case

  defmodule MyHandler do
    @behaviour :elli_handler

    def handle(request, _config) do
      run(:elli_request.path(request), :elli_request.body(request))
    end

    def run(["echo"], body) do
      {200, [], body}
    end

    def run(_, _) do
      {404, [], %{error: "Not found"}}
    end

    def handle_event(_, _, _) do
      :ok
    end
  end

  setup_all do
    middleware_stack = [
      {Elli.JsonGateKeeper, []},
      {MyHandler, []}
    ]

    elli_config = [
      port: 8871,
      callback: :elli_middleware,
      callback_args: [mods: middleware_stack]
    ]

    {:ok, _} = :elli.start_link(elli_config)
    :ok
  end

  test "404 route" do
    {code, headers, body} = get("/nothing-here")
    assert body == ~s({"error":"Not found"})
    assert code == 404
    assert List.keyfind(headers, "content-type", 0) == {"content-type", "application/json"}
  end

  test "echo no body" do
    {code, headers, body} = post("/echo", "")
    assert body == ""
    assert code == 200
    refute List.keyfind(headers, "content-type", 0) == {"content-type", "application/json"}
  end

  test "echo JSON array" do
    {code, headers, body} = post("/echo", "[1 ,   2   ,   3]")

    assert body == "[1,2,3]"
    assert code == 200
    assert List.keyfind(headers, "content-type", 0) == {"content-type", "application/json"}
  end

  test "echo JSON object" do
    {code, headers, body} = post("/echo", ~s({  "ok" : true}))

    assert body == ~s({"ok":true})
    assert code == 200
    assert List.keyfind(headers, "content-type", 0) == {"content-type", "application/json"}
  end

  test "echo invalid JSON" do
    {code, headers, body} = post("/echo", ~s(==================))

    assert body == "{\"errors\":[{\"title\":\"Invalid JSON in request body\"}]}"
    assert code == 400
    assert List.keyfind(headers, "content-type", 0) == {"content-type", "application/json"}
  end

  defp post(path, body) do
    url = ~c[http://localhost:8871] ++ String.to_charlist(path)

    {:ok, {{_, code, _}, headers, body}} =
      :httpc.request(:post, {url, [], [], String.to_charlist(body)}, [], [])

    bin_headers = Enum.map(headers, fn {k, v} -> {to_string(k), to_string(v)} end)
    {code, bin_headers, to_string(body)}
  end

  defp get(path) do
    url = ~c[http://localhost:8871] ++ String.to_charlist(path)

    {:ok, {{_, code, _}, headers, body}} = :httpc.request(url)

    bin_headers = Enum.map(headers, fn {k, v} -> {to_string(k), to_string(v)} end)
    {code, bin_headers, to_string(body)}
  end
end
