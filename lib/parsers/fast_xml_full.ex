defmodule ElixirXmlParserBenchmark.Parsers.FastXmlFull do
  def transform(content) do
    content
    |> parse()
    |> process_root()
  end

  def parse(string) do
    :fxml_stream.parse_element(string)
  end

  defp process_root({:xmlel, "trains", _attrs, children}) do
    children
    |> Enum.map(&process_train/1)
    |> Enum.filter(& &1)
  end

  defp process_train({:xmlel, "train", attrs, children}) do
    children
    |> Enum.map(&process_train_inner/1)
    |> Enum.filter(& &1)
    |> Map.new()
    |> Map.merge(train_attrs(attrs))
  end

  defp process_train(_), do: nil

  defp train_attrs(keylist) do
    {_, active} = Enum.find(keylist, {"active", nil}, fn {key, _value} -> key == "active" end)

    %{
      active: active == "true"
    }
  end

  defp process_train_inner({:xmlel, "id", _attrs, [xmlcdata: id]}) do
    {:id, String.to_integer(id)}
  end

  defp process_train_inner({:xmlel, "type", _, [xmlcdata: type]}) do
    {:type, type}
  end

  defp process_train_inner({:xmlel, "driver", _, [xmlcdata: driver]}) do
    {:driver, driver}
  end

  defp process_train_inner({:xmlel, "operating-since", _, [xmlcdata: value]}) do
    {:ok, date, _} = DateTime.from_iso8601(value)
    {:operating_since, date}
  end

  defp process_train_inner({:xmlel, "payloads", _, children}) do
    payloads =
      children
      |> Enum.map(&process_payload/1)   
      |> Enum.filter(& &1)

    {:payloads, payloads}
  end

  defp process_train_inner(_), do: nil

  defp process_payload({:xmlel, "payload", _, children}) do
    children
    |> Enum.map(&process_payload_inner/1)
    |> Enum.filter(& &1)
    |> Map.new()
  end

  defp process_payload(_), do: nil

  defp process_payload_inner({:xmlel, "material", _, [xmlcdata: value]}) do
    {:material, value}
  end

  defp process_payload_inner({:xmlel, "weight", _, [xmlcdata: value]}) do
    {:weight, String.to_integer(value)}
  end

  defp process_payload_inner(_), do: nil
end
