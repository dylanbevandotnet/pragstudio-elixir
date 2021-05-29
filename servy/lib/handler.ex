defmodule Servy.Handler do
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    |> log
    |> route
    |> track
    |> format_response
  end

  def track(%{status: 404, path: path} = conv) do
    IO.puts "Warning: #{path} is on the loose!"
    conv
  end
  def track(conv), do: conv

  def rewrite_path(%{ path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings"}
  end
  def rewrite_path(conv), do: conv

  def log(conv), do: IO.inspect conv

  def parse(request) do
    [method, path, _] = request
                        |> String.split("\n")
                        |> List.first
                        |> String.split(" ")
    %{ method: method,
       path: path,
       resp_body: "",
       status: 200}
  end

  def route(%{ method: "GET", path: "/wildthings"} = conv), do: %{ conv | resp_body: "Bears, Lions, Tigers" }
  def route(%{ method: "GET", path: "/bears"} = conv), do: %{ conv | resp_body: "Teddy, Smokey, Paddington" }
  def route(%{ method: "GET", path: "/bears/" <> id} = conv), do: %{ conv | resp_body: "Bear #{id}" }
  def route(%{ path: path} = conv) do
    %{ conv | resp_body: "No #{path} here", status: 404 }
  end

  @spec format_response(atom | %{:resp_body => binary, :status => any, optional(any) => any}) ::
          <<_::64, _::_*8>>
  def format_response(conv) do
    """
    HTTP/1.1 #{conv.status} #{status_reason(conv.status)}
    Content-Type: text/html
    Content-Length: #{String.length(conv.resp_body)}

    #{conv.resp_body}

    """
  end

  # private function defp
  defp status_reason(code) do
    %{
      200 => "OK",
      201 => "Created",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "Not Found",
      500 => "Internal Server Error"
    }[code]
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
