defmodule Servy.BearController do
  alias Servy.Conv
  alias Servy.Bear
  alias Servy.Wildthings

  defp bear_item(%Bear{} = bear) do
    "<li>#{bear.name} - #{bear.type}</li>"
  end

  def index(%Conv{} = conv) do
    items = Wildthings.list_bears()
            |> Enum.filter(&Bear.is_grizzly/1)
            |> Enum.sort(&Bear.order_asc_by_name/2)
            # equivalent of above, but a bit more readable
            |> Enum.map(&bear_item(&1))
            |> Enum.join
    %{ conv | resp_body: "<ul>#{items}</ul>" }
  end

  def show(%Conv{} = conv, %{"id" => id}) do
    bear = Wildthings.get_bear(id)
    %{ conv | resp_body: "<h1>Bear #{bear.id}: #{bear.name}</h1>" }
  end

  def create(%Conv{} = conv, %{"name" => name, "type" => type}) do
    %{ conv | status: 201, resp_body: "Created a #{type} bear named #{name}" }
  end
end
