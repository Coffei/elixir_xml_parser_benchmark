defmodule ElixirXmlParserBenchmark.ParserEqualityTest do
  use ExUnit.Case
  doctest ElixirXmlParserBenchmark

  alias ElixirXmlParserBenchmark.Data
  alias ElixirXmlParserBenchmark.Parsers.ErlsomSimple
  alias ElixirXmlParserBenchmark.Parsers.ErlsomSax
  alias ElixirXmlParserBenchmark.Parsers.FastXmlFull
  alias ElixirXmlParserBenchmark.Parsers.Meeseeks
  alias ElixirXmlParserBenchmark.Parsers.Saxy
  alias ElixirXmlParserBenchmark.Parsers.SaxySimple
  alias ElixirXmlParserBenchmark.Parsers.SweetXmlStream
  alias ElixirXmlParserBenchmark.Parsers.SweetXmlXpath
  alias ElixirXmlParserBenchmark.Parsers.Xmerl
  alias ElixirXmlParserBenchmark.Parsers.XmerlSimple

  test "all parsers output the same on small.xml" do
    file = Data.read("small")

    reference = Xmerl.transform(file)

    assert XmerlSimple.transform(file) == reference
    assert FastXmlFull.transform(file) == reference
    assert ErlsomSimple.transform(file) == reference
    assert ErlsomSax.transform(file) == reference
    assert Meeseeks.transform(file) == reference
    assert Saxy.transform(file) == reference
    assert SaxySimple.transform(file) == reference
    assert SweetXmlXpath.transform(file) == reference
    assert SweetXmlStream.transform(file) == reference
  end

  test "all parsers output the same on medium.xml" do
    file = Data.read("medium")

    reference = Xmerl.transform(file)

    assert XmerlSimple.transform(file) == reference
    assert FastXmlFull.transform(file) == reference
    assert ErlsomSimple.transform(file) == reference
    assert ErlsomSax.transform(file) == reference
    assert Meeseeks.transform(file) == reference
    assert Saxy.transform(file) == reference
    assert SaxySimple.transform(file) == reference
    assert SweetXmlXpath.transform(file) == reference
    assert SweetXmlStream.transform(file) == reference
  end

  test "all parsers output the same on big.xml" do
    file = Data.read("big")

    reference = Xmerl.transform(file)

    assert XmerlSimple.transform(file) == reference
    assert FastXmlFull.transform(file) == reference
    assert ErlsomSimple.transform(file) == reference
    assert ErlsomSax.transform(file) == reference
    assert Meeseeks.transform(file) == reference
    assert Saxy.transform(file) == reference
    assert SaxySimple.transform(file) == reference
    assert SweetXmlXpath.transform(file) == reference
    assert SweetXmlStream.transform(file) == reference
  end

  test "all parsers output the same on huge.xml" do
    file = Data.read("huge")

    reference = Xmerl.transform(file)

    assert XmerlSimple.transform(file) == reference
    assert FastXmlFull.transform(file) == reference
    assert ErlsomSimple.transform(file) == reference
    assert ErlsomSax.transform(file) == reference
    assert Meeseeks.transform(file) == reference
    assert Saxy.transform(file) == reference
    assert SaxySimple.transform(file) == reference
    assert SweetXmlXpath.transform(file) == reference
    assert SweetXmlStream.transform(file) == reference
  end
end
