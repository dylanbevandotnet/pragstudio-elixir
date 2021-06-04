defmodule Servy.Plugins do
  @moduledoc """
  Set of plugins for Servy
  """
  alias Servy.Conv

  @doc """
  Logs 404 requests
  """
  def track(%Conv{status: 404, path: path} = conv) do
    IO.puts "Warning: #{path} is on the loose!"
    conv
  end

  # make sure that the value passed in is a Conv
  def track(%Conv{} = conv), do: conv

  def rewrite_path(%Conv{ path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings"}
  end

  def rewrite_path(%Conv{} = conv), do: conv

  def log(%Conv{} = conv), do: IO.inspect conv
end
