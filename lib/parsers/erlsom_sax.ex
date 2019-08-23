defmodule ElixirXmlParserBenchmark.Parsers.ErlsomSax do
  def transform(content) do
    start_state = %{
      current_train: nil,
      current_payload: nil,
      current_payloads: nil,
      last_chars: nil,
      trains: []
    }

    {:ok, result, _} =
      :erlsom.parse_sax(content, start_state, fn
        :endDocument, state ->
          Enum.reverse(state.trains)

        {:startElement, _, 'train', _, attributes}, state ->
          {:attribute, _, _, _, active} =
            Enum.find(attributes, {:attribute, 'active', nil, nil, nil}, fn {:attribute, name, _,
                                                                             _, _} ->
              name == 'active'
            end)

          train = %{active: active == 'true'}
          %{state | current_train: train}

        # structural endings
        {:startElement, _, 'payloads', _, _}, state ->
          %{state | current_payloads: []}

        {:startElement, _, 'payload', _, _}, state ->
          %{state | current_payload: %{}}

        {:endElement, _, 'train', _}, state ->
          %{state | trains: [state.current_train | state.trains], current_train: nil}

        {:endElement, _, 'payload', _}, state ->
          %{
            state
            | current_payloads: [state.current_payload | state.current_payloads],
              current_payload: nil
          }

        # TRAIN attributes
        {:endElement, _, 'id', _}, state ->
          id = String.to_integer(state.last_chars)
          train = Map.put(state.current_train, :id, id)
          %{state | current_train: train, last_chars: nil}

        {:endElement, _, string_prop, _}, state when string_prop in ['type', 'driver'] ->
          prop_key = String.to_atom(to_string(string_prop))
          train = Map.put(state.current_train, prop_key, state.last_chars)
          %{state | current_train: train, last_chars: nil}

        {:endElement, _, 'operating-since', _}, state ->
          {:ok, date, _} = DateTime.from_iso8601(state.last_chars)
          train = Map.put(state.current_train, :operating_since, date)
          %{state | current_train: train, last_chars: nil}

        {:endElement, _, 'payloads', _}, state ->
          payloads = Enum.reverse(state.current_payloads)
          train = Map.put(state.current_train, :payloads, payloads)
          %{state | current_train: train}

        # PAYLOAD attributes
        {:endElement, _, 'material', _}, state ->
          payload = Map.put(state.current_payload, :material, state.last_chars)
          %{state | current_payload: payload, last_chars: nil}

        {:endElement, _, 'weight', _}, state ->
          payload = Map.put(state.current_payload, :weight, String.to_integer(state.last_chars))
          %{state | current_payload: payload, last_chars: nil}

        {:characters, text}, state ->
          %{state | last_chars: to_string(text)}

        _, state ->
          state
      end)

    result
  end
end
