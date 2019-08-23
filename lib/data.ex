defmodule ElixirXmlParserBenchmark.Data do
  def read(filename) do
    base_dir = :code.priv_dir(:elixir_xml_parser_benchmark)

    [base_dir, "xmls", "#{filename}.xml"]
    |> Path.join()
    |> File.read!()
  end
end
