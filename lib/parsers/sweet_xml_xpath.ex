defmodule ElixirXmlParserBenchmark.Parsers.SweetXmlXpath do
  import SweetXml

  def transform(string) do
    string
    |> xpath(~x"//trains/train"l,
      id: ~x"./id/text()"s |> transform_by(&String.to_integer/1),
      active: ~x"./@active" |> transform_by(&(&1 == 'true')),
      type: ~x"./type/text()"s,
      driver: ~x"./driver/text()"s,
      operating_since: ~x"./operating-since/text()"s |> transform_by(&date/1),
      payloads_present: ~x"./payloads" |> transform_by(&(&1 != nil)),
      payloads: [
        ~x"./payloads/payload"l,
        material: ~x"./material/text()"s,
        weight: ~x"./weight/text()"s |> transform_by(&String.to_integer/1)
      ]
    )
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
