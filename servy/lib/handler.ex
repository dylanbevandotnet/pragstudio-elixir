defmodule Servy.Handler do
  @moduledoc """
  Handles HTTP requests
  """

  # Declare a module attribute (like a static const)
  @pages_path Path.expand("../../pages", __DIR__)
  # import only the functions (and their arity (1))
  import Servy.Plugins, only: [rewrite_path: 1, log: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  alias Servy.Conv
  alias Servy.BearController


  @doc """
  Transforms the request into a response
  """
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def route(%Conv{ method: "GET", path: "/wildthings"} = conv), do: %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  def route(%Conv{ method: "GET", path: "/bears"} = conv), do: BearController.index(conv)
  def route(%Conv{ method: "GET", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{ method: "GET", path: "/about"} = conv) do
    @pages_path
    |> Path.join("about.html")
    |> File.read
    |> handle_file(conv)
  end

  #name=Baloo&type=Brown
  def route(%Conv{ method: "POST", path: "/bears"} = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{ path: path} = conv) do
    %{ conv | resp_body: "No #{path} here!", status: 404 }
  end

  def handle_file({:ok, content}, %Conv{} = conv), do: %{ conv | status: 200, resp_body: content}
  def handle_file({:error, :enoent}, %Conv{} = conv), do: %{ conv | status: 404, resp_body: "File not found"}
  def handle_file({:error, reason}, %Conv{} = conv), do: %{ conv | status: 500, resp_body: "File error: #{reason}"}

  @spec format_response(atom | %{:resp_body => binary, :status => any, optional(any) => any}) ::
          <<_::64, _::_*8>>
  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    Content-Type: text/html\r
    Content-Length: #{String.length(conv.resp_body)}\r
    \r
    #{conv.resp_body}
    """
  end
end
