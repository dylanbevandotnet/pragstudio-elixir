defmodule  Servy.Parser do
  #alias Servy.Conv, as: Conv
  #Shorthand way just keeps the last dotted value
  alias Servy.Conv
  @doc """
  Parses an HTTP request to a map
  """
  def parse(request) do
    [method, path, _] = request
                        |> String.split("\n")
                        |> List.first
                        |> String.split(" ")
    %Conv{
       method: method,
       path: path}
  end
end
