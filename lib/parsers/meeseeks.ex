defmodule ElixirXmlParserBenchmark.Parsers.Meeseeks do
  alias Meeseeks.Selector.Combinator
  alias Meeseeks.Selector.Element

  def parse(string) do
    Meeseeks.parse(string, :xml)
  end

  def transform(content) do
    parsed = parse(content)

    train_selector = tag_under_tag_selector("trains", "train")

    for train <- Meeseeks.all(parsed, train_selector) do
      id = Meeseeks.one(train, tag_selector("id"))
      type = Meeseeks.one(train, tag_selector("type"))
      driver = Meeseeks.one(train, tag_selector("driver"))
      operating_since = Meeseeks.text(Meeseeks.one(train, tag_selector("operating-since")))
      operating_since = date(operating_since)

      %{
        active: Meeseeks.attr(train, "active") == "true",
        id: Meeseeks.text(id) |> String.to_integer(),
        type: Meeseeks.text(type),
        driver: Meeseeks.text(driver),
        operating_since: operating_since,
        payloads: payloads(train)
      }
      |> Enum.reject(fn {_key, value} -> value == nil end)
      |> Map.new()
    end
  end

  def payloads(train) do
    payloads = Meeseeks.one(train, tag_selector("payloads"))

    if payloads do
      for payload <- Meeseeks.all(payloads, tag_selector("payload")) do
        material = Meeseeks.one(payload, tag_selector("material"))
        weight = Meeseeks.one(payload, tag_selector("weight"))

        %{
          material: Meeseeks.text(material),
          weight: Meeseeks.text(weight) |> String.to_integer()
        }
      end
    end
  end

  defp tag_selector(tag) do
    %Element{selectors: [%Element.Tag{value: tag}]}
  end

  defp tag_under_tag_selector(parent, child) do
    %Element{
      selectors: [%Element.Tag{value: parent}],
      combinator: %Combinator.ChildElements{
        selector: %Element{selectors: [%Element.Tag{value: child}]}
      }
    }
  end

  defp date(nil), do: nil

  defp date(string) do
    {:ok, date, _} = DateTime.from_iso8601(string)
    date
  end
end
