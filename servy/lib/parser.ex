defmodule  Servy.Parser do
  @doc """
  Parses an HTTP request to a map
  """
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
end
