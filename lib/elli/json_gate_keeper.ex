defmodule Elli.JsonGateKeeper do
  @moduledoc """
  Elli.JsonGateKeeper middleware.

  Request bodies are decoded from JSON if present. Bodies containing invalid
  JSON are rejected with 400.

  Response bodies are encoded into JSON. The `content-type: application/json`
  header is added to encoded requests.

  This is a rather heavy handed approach, only suited to applications that
  only consume JSON bodies.

  """

  @behaviour :elli_handler

  require Record
  Record.defrecord(:req, Record.extract(:req, from_lib: "elli/include/elli.hrl"))

  # Encoding responses

  def postprocess(_request, {code, body}, _config) when not is_binary(body) do
    encode({code, [], body})
  end

  def postprocess(_request, {code, headers, body}, _config) when not is_binary(body) do
    encode({code, headers, body})
  end

  def postprocess(_request, response, _config) do
    response
  end

  defp encode({code, headers, body} = response) do
    case Jason.encode(body) do
      {:ok, json} ->
        new_headers = [{"content-type", "application/json"} | headers]
        {code, new_headers, json}

      _ ->
        response
    end
  end

  # Decoding requests

  def preprocess(req(body: "") = request, _config) do
    request
  end

  def preprocess(req(body: body) = request, _config) do
    case Jason.decode(body) do
      {:ok, decoded} ->
        req(request, body: decoded)

      _ ->
        :invalid_json
    end
  end

  def handle(:invalid_json, _config) do
    {400, [{"content-type", "application/json"}],
     ~s({"errors":[{"title":"Invalid JSON in request body"}]})}
  end

  def handle(_request, _config) do
    :ignore
  end

  def handle_event(_, _, _) do
    :ok
  end
end
