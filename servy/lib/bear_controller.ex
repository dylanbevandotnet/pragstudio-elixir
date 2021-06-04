defmodule Servy.BearController do
  alias Servy.Conv
  alias Servy.Bear
  alias Servy.Wildthings

  @template_path Path.expand("../../templates", __DIR__)

  defp render(conv, template, bindings \\ []) do
    content =
      @template_path
      |> Path.join(template)
      |> EEx.eval_file(bindings)
    %{ conv | resp_body: content }
  end

  def index(%Conv{} = conv) do
    bears = Wildthings.list_bears()
            |> Enum.sort(&Bear.order_asc_by_name/2)
    render(conv, "index.eex", bears: bears)
  end

  def show(%Conv{} = conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    render(conv, "show.eex", bear: bear)
  end

  def create(%Conv{} = conv, %{"name" => name, "type" => type}) do
    %{ conv | status: 201, resp_body: "Created a #{type} bear named #{name}" }
  end
end