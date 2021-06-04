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

  def route(%Conv{ method: "GET", path: "/wildthings"} = conv), do: %{ conv | resp_body: "Bears, Lions, Tigers" }
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
    %{ conv | resp_body: "No #{path} here", status: 404 }
  end

  def handle_file({:ok, content}, %Conv{} = conv), do: %{ conv | status: 200, resp_body: content}
  def handle_file({:error, :enoent}, %Conv{} = conv), do: %{ conv | status: 404, resp_body: "File not found"}
  def handle_file({:error, reason}, %Conv{} = conv), do: %{ conv | status: 500, resp_body: "File error: #{reason}"}

  @spec format_response(atom | %{:resp_body => binary, :status => any, optional(any) => any}) ::
          <<_::64, _::_*8>>
  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}

    """
  end
end

request = """
GET /wildthings HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

# expected_response = """
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 20

# Bears, Lions, Tigers
# """

response = Servy.Handler.handle(request)
IO.puts response


request = """
GET /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

# expected_response = """
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 25

# Teddy, Smokey, Paddington
# """

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bigfoot HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

# expected_response = """
# HTTP/1.1 404 Not Found
# Content-Type: text/html
# Content-Length: 16

# No /bigfoot here
# """

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /bears/1 HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

# expected_response = """
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 6

# Bear 1
# """

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /wildlife HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

# expected_response = """
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 6

# Bear 1
# """

response = Servy.Handler.handle(request)
IO.puts response

request = """
GET /about HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*

"""

# expected_response = """
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 6

# Bear 1
# """

response = Servy.Handler.handle(request)
IO.puts response

request = """
POST /bears HTTP/1.1
Host: example.com
User-Agent: ExampleBrowser/1.0
Accept: */*
Content-Type: application/x-www-form-urlencoded
Content-Length: 21

name=Baloo&type=Brown
"""

# expected_response = """
# HTTP/1.1 200 OK
# Content-Type: text/html
# Content-Length: 6

# Bear 1
# """

response = Servy.Handler.handle(request)
IO.puts response
