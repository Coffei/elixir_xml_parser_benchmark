defmodule ElixirXmlParserBenchmark.Parsers.Xmerl do
  require Record
  Record.defrecord(:xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl"))
  Record.defrecord(:xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl"))

  Record.defrecord(
    :xmlAttribute,
    Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
  )

  def parse(string) do
    string
    |> :erlang.binary_to_list()
    |> :xmerl_scan.string(quiet: true)
    |> elem(0)
  end

  def transform(content) do
    content
    |> parse()
    |> process_root()
  end

  defp process_root(xmlElement(name: :trains, content: children)) do
    children
    |> Enum.map(&process_train/1)
    |> Enum.filter(& &1)
  end

  defp process_train(xmlElement(name: :train, content: children, attributes: attrs)) do
    children
    |> Enum.map(&process_train_inner/1)
    |> Enum.filter(& &1)
    |> Map.new()
    |> Map.merge(train_attrs(attrs))
  end

  defp process_train(_), do: nil

  defp process_train_inner(xmlElement(name: :id, content: content)) do
    id = String.to_integer(get_text(content))

    {:id, id}
  end

  defp process_train_inner(xmlElement(name: string_element, content: content))
       when string_element in [:type, :driver] do
    value = get_text(content)
    {string_element, value}
  end

  defp process_train_inner(xmlElement(name: :"operating-since", content: content)) do
    {:ok, date, _} = DateTime.from_iso8601(get_text(content))
    {:operating_since, date}
  end

  defp process_train_inner(xmlElement(name: :payloads, content: children)) do
    payloads =
      children
      |> Enum.map(&process_payload/1)
      |> Enum.filter(& &1)

    {:payloads, payloads}
  end

  defp process_train_inner(_), do: nil

  defp process_payload(xmlElement(name: :payload, content: children)) do
    children
    |> Enum.map(&process_payload_inner/1)
    |> Enum.filter(& &1)
    |> Map.new()
  end

  defp process_payload(_), do: nil

  defp process_payload_inner(xmlElement(name: :material, content: content)) do
    content = get_text(content)
    {:material, content}
  end

  defp process_payload_inner(xmlElement(name: :weight, content: content)) do
    weight = String.to_integer(get_text(content))
    {:weight, weight}
  end

  defp process_payload_inner(_), do: nil

  defp train_attrs(attrs) do
    attrs
    |> Enum.map(fn
      xmlAttribute(name: :active, value: value) -> {:active, value == 'true'}
      _ -> nil
    end)
    |> Enum.filter(& &1)
    |> Map.new()
  end

  defp get_text(children) do
    children
    |> Enum.filter(fn
      xmlText() -> true
      _ -> false
    end)
    |> Enum.map(fn xmlText(value: value) -> to_string(value) end)
    |> Enum.join()
  end
end
