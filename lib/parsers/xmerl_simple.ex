defmodule ElixirXmlParserBenchmark.Parsers.XmerlSimple do
  def transform(content) do
    content
    |> parse()
    |> process_root()
  end

  def parse(string) do
    string
    |> :erlang.binary_to_list()
    |> :xmerl_scan.string(quiet: true)
    |> elem(0)
    |> :xmerl_lib.simplify_element()
    |> simplify()
  end

  defp process_root({"trains", _, children}) do
    Enum.map(children, &process_train/1)
  end

  defp process_train({"train", attrs, children}) do
    children
    |> Enum.into(%{}, &process_train_inner/1)
    |> Map.merge(train_attrs(attrs))
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
    case children do
      [_ | _] ->
        {:payloads, Enum.map(children, &process_payload/1)}

      _ ->
        {:payloads, []}
    end
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

  defp train_attrs(keylist) do
    %{
      active: Keyword.get_values(keylist, :active) == ['true']
    }
  end

  defp simplify({name, attributes, children}) do
    children = Enum.reject(children, &all_whitespace?/1)

    # convert name to binary and remove any namespacing
    # TODO: add test case for this
    name =
      case String.split(to_string(name), ":", parts: 2) do
        [name] -> name
        [_prefix, name] -> name
      end

    content =
      case children do
        [] -> nil
        other -> Enum.map(other, &simplify/1)
      end

    {name, attributes, content}
  end

  defp simplify([int | _rest] = charlist) when is_integer(int) do
    to_string(charlist)
  end

  defp all_whitespace?(item) do
    is_list(item) && Enum.all?(item, &(is_integer(&1) && &1 <= 32))
  end
end
