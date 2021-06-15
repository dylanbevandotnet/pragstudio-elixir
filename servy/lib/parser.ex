defmodule  Servy.Parser do
  #alias Servy.Conv, as: Conv
  #Shorthand way just keeps the last dotted value
  alias Servy.Conv
  @doc """
  Parses an HTTP request to a map
  """
  def parse(request) do
    [top, params_string] = String.split(request, "\r\n\r\n")
    [request_line | header_lines] = String.split(top, "\r\n")
    [method, path, _] = request_line |> String.split(" ")

    headers = parse_headers(header_lines, %{})
    params = parse_params(headers["Content-Type"], params_string)


    %Conv{
       method: method,
       path: path,
       params: params,
      headers: headers,
    }
  end

  @doc """
  Parses the given param string of the form `key1=value1&key2=value2`
  into a map with the corresponding keys and values.

  ## Examples
    iex> params_string = "name=Baloo&type=Brown"
    iex> Servy.Parser.parse_params("application/x-www-form-urlencoded", params_string)
    %{"name" => "Baloo", "type" => "Brown"}
    iex> Servy.Parser.parse_params("multipart/form-data", params_string)
    %{}
  """
  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim |> URI.decode_query
  end

  def parse_params("application/json", params_string) do
    params_string |> String.trim |> Poison.Parser.parse!(%{})
  end

  def parse_params(_, _), do: %{}

  def parse_headers([head | tail], headers) do
    [key, value] = String.split(head, ": ")
    headers = Map.put(headers, key, value)
    parse_headers(tail, headers)
  end

  def parse_headers([], headers), do: headers
end
