defmodule ElixirXmlParserBenchmark.Parsers.SweetXmlStream do
  import SweetXml

  def transform(content) do
    content
    |> stream_tags([:train])
    |> Enum.map(fn {:train, doc} ->
      %{
        id: xpath(doc, ~x"./id/text()"s |> transform_by(&String.to_integer/1)),
        active: xpath(doc, ~x"./@active" |> transform_by(&(&1 == 'true'))),
        type: xpath(doc, ~x"./type/text()"s),
        driver: xpath(doc, ~x"./driver/text()"s),
        operating_since: xpath(doc, ~x"./operating-since/text()"s |> transform_by(&date/1)),
        payloads_present: xpath(doc, ~x"./payloads" |> transform_by(&(&1 != nil))),
        payloads:
          xpath(doc, ~x"./payloads/payload"l,
            material: ~x"./material/text()"s,
            weight: ~x"./weight/text()"s |> transform_by(&String.to_integer/1)
          )
      }
    end)
    |> Enum.map(fn train ->
      train =
        if !train.payloads_present do
          Map.drop(train, [:payloads])
        else
          train
        end

      train
      |> Enum.reject(fn {key, value} -> key == :payloads_present || value in [nil, ""] end)
      |> Map.new()
    end)
  end

  defp date(string) do
    case string do
      "" ->
        nil

      _ ->
        {:ok, date, _} = DateTime.from_iso8601(string)
        date
    end
  end
end
