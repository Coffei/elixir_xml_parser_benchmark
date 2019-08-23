defmodule ElixirXmlParserBenchmark.Parsers.Saxy do
  defmodule TrainsHandler do
    @behaviour Saxy.Handler

    def handle_event(:start_document, _prolog, _state) do
      {:ok, %{current_train: nil, current_payload: nil, current_payloads: nil, last_chars: nil, trains: []}}
    end

    def handle_event(:end_document, _data, state) do
      {:ok, Enum.reverse(state.trains)}
    end

    def handle_event(:start_element, {"train", attributes}, state) do
      {_, active} = Enum.find(attributes, {"active", nil}, fn {key, _} -> key == "active" end)
      train = %{active: active == "true"}

      {:ok, %{state | current_train: train}}
    end

    def handle_event(:start_element, {"payloads", _}, state) do
      {:ok, %{state | current_payloads: []}}
    end

    def handle_event(:start_element, {"payload", _}, state) do
      {:ok, %{state | current_payload: %{}}}
    end

    def handle_event(:start_element, _, state) do
      {:ok, state}
    end

    # structural endings
    def handle_event(:end_element, "train", state) do
      {:ok, %{state | trains: [state.current_train | state.trains], current_train: nil}}
    end

    def handle_event(:end_element, "payload", state) do
      {:ok, %{state | current_payloads: [state.current_payload | state.current_payloads], current_payload: nil}}
    end

    # TRAIN attributes
    def handle_event(:end_element, "id", state) do
      id = String.to_integer(state.last_chars)
      train = Map.put(state.current_train, :id, id)

      {:ok, %{state | current_train: train, last_chars: nil}}
    end

    def handle_event(:end_element, string_prop, state) when string_prop in ["type", "driver"] do
      prop_key = String.to_atom(string_prop)
      train = Map.put(state.current_train, prop_key, state.last_chars)

      {:ok, %{state | current_train: train, last_chars: nil}}
    end

    def handle_event(:end_element, "operating-since", state) do
      {:ok, date, _} = DateTime.from_iso8601(state.last_chars)
      train = Map.put(state.current_train, :operating_since, date)

      {:ok, %{state | current_train: train, last_chars: nil}}
    end

    def handle_event(:end_element, "payloads", state) do
      payloads = Enum.reverse(state.current_payloads)
      train = Map.put(state.current_train, :payloads, payloads)

      {:ok, %{state | current_train: train}}
    end

    # PAYLOAD attributes
    def handle_event(:end_element, "material", state) do
      payload = Map.put(state.current_payload, :material, state.last_chars)
      {:ok, %{state | current_payload: payload, last_chars: nil}}
    end

    def handle_event(:end_element, "weight", state) do
      payload = Map.put(state.current_payload, :weight, String.to_integer(state.last_chars))
      {:ok, %{state | current_payload: payload, last_chars: nil}}
    end

    def handle_event(:end_element, _, state) do
      {:ok, state}
    end

    def handle_event(:characters, chars, state) do
      {:ok, %{state | last_chars: chars}}
    end
  end

  def transform(content) do
    {:ok, result} = Saxy.parse_string(content, TrainsHandler, [])
    result
  end
end
