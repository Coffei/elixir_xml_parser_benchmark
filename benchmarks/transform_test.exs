alias ElixirXmlParserBenchmark.Parsers.{
  Xmerl,
  XmerlSimple,
  FastXmlFull,
  ErlsomSimple,
  ErlsomSax,
  Meeseeks,
  Saxy,
  SaxySimple,
  SweetXmlStream,
  SweetXmlXpath
}

inputs =
  ["small", "medium", "big", "huge"]
  |> Enum.into(%{}, fn file -> {file, ElixirXmlParserBenchmark.Data.read(file)} end)

tests =
  [
    Xmerl,
    XmerlSimple,
    FastXmlFull,
    ErlsomSimple,
    ErlsomSax,
    Meeseeks,
    Saxy,
    SaxySimple,
    SweetXmlXpath,
    SweetXmlStream
  ]
  |> Enum.into(%{}, fn mod -> {to_string(mod), fn input -> mod.transform(input) end} end)

Benchee.run(tests,
  inputs: inputs,
  formatters: [
    Benchee.Formatters.Console,
    {Benchee.Formatters.HTML, file: "docs/index.html", auto_open: false}
  ]
)
