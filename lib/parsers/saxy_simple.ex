defmodule ElixirXmlParserBenchmark.Parsers.SaxySimple do
  def parse(string) do
    {:ok, parsed} = Saxy.SimpleForm.parse_string(string)
    parsed
  end

  def transform(content) do
    content
    |> parse()
    |> process_root()
  end

  defp process_root({"trains", [], children}) do
    children
    |> Enum.map(&process_train/1)
  end

  defp process_train({"train", attrs, children}) do
    {_, active} = Enum.find(attrs, {"active", nil}, fn {key, _} -> key == "active" end)

    children
    |> Enum.map(&process_train_inner/1)
    |> Map.new()
    |> Map.merge(%{active: active == "true"})
  end

  defp process_train_inner({"id", _, [value]}) do
    {:id, String.to_integer(value)}
  end

  defp process_train_inner({"type", _, [value]}) do
    {:type, value}
  end

  defp process_train_inner({"driver", _, [value]}) do
    {:driver, value}
  end

  defp process_train_inner({"operating-since", _, [value]}) do
    {:ok, date, _} = DateTime.from_iso8601(value)
    {:operating_since, date}
  end

  defp process_train_inner({"payloads", _, children}) do
    {:payloads, Enum.map(children, &process_payload/1)}
  end

  defp process_payload({"payload", _, children}) do
    Enum.into(children, %{}, &process_payload_inner/1)
  end

  defp process_payload_inner({"material", _, [value]}) do
    {:material, value}
  end

  defp process_payload_inner({"weight", _, [value]}) do
    {:weight, String.to_integer(value)}
  end
end
