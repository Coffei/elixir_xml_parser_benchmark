# Opinionated Elixir XML Benchmark

At work I stumbled across a problem of slow XML parsing, a bundle of 500 XMLs
took longer than 10s to parse, which seemed weirdly too much. Since I was using
a naive parsing built on top of xmerl (because it's already there), I assumed
xmerl is the cause and begain the quest of finding new XML parser. Few articles
later I was sure xmerl was the primary problem, but I also had a couple of
alternatives to choose from and I began wondering which is the right for me.

The primary issue is speed, luckily that can be easily answered with a proper
benchmark. Secondary problem is how the parsing code looks, how simple and
understandable it is and complicated and time-consuming it is to write.
Fortunately, that can also be tested easily, by writing a the same parser with
a couple of different parsers. So the answer was to write my own custom
benchmark.

NOTE: This is highly opinionated benchmark, it does NOT represent how these XML
parsers behave in general, even though I believe you can make some general
observations.

The implementation for each parser not only parses the XML but also transforms
it to a universal format (list of maps), so that every parser produces the same
output. This levels the field where some parsers do more than others (i.e.
conversion to binaries, or discarding whitespaces inside the XML).

## Included parsers

 - **XMerl** by parsing and walking/transforming the AST
 - **XMerl** with conversion to simple format which is then transformed (not a
   great candidate for improvement, but this is what I initially used)
 - **Erlsom** both SAX and regular parser (AST walking)
 - **Fast XML** using AST walking
 - **Meeseeks** with its simple selectors
 - **Saxy** both as SAX and regular parser
 - **SweetXml** using xpath selectors and streaming elements


## Examples and expected results
There's one type of XML in various sizes
The smallest is as follows, the bigger ones just add more attributes and trains.

```xml
<trains>
    <train active="true">
        <id>1</id>
    </train>
    <train active="false">
        <id>2</id>
    </train>
</trains>
```

There are 4 XML files included

 - **small** - 136B
 - **medium** - 2KB
 - **big** - 22KB
 - **huge** - 1,1MB

The parsers were implemented so they produce as elixir-native representation of
that XML as possible. The XML parsed above looks as follows.

```elixir
[
    %{active: true, id: 1}, 
    %{active: false, id: 2}
]
```

## Running
To verify all parsers produce the same output run `mix test`.

To start the performance benchmark run `mix run benchmarks/transform_test.exs`.

## Results
The included benchmark results were run on my Dell XPS13 with i7-7500U and 16GB
of RAM. Below is a comparison of every parser for each file.

HTML results are also in `/benchmarks/output/`.

```
##### With input small #####
Name                                                             ips        average  deviation         median         99th %
Elixir.ElixirXmlParserBenchmark.Parsers.Saxy                 76.06 K       13.15 μs   ±464.65%        8.28 μs       29.24 μs
Elixir.ElixirXmlParserBenchmark.Parsers.SaxySimple           72.57 K       13.78 μs   ±457.89%        8.57 μs       34.28 μs - 1.05x slower +0.63 μs
Elixir.ElixirXmlParserBenchmark.Parsers.FastXmlFull          64.40 K       15.53 μs   ±448.48%       11.88 μs       27.37 μs - 1.18x slower +2.38 μs
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSax            48.08 K       20.80 μs   ±360.50%        9.51 μs      304.73 μs - 1.58x slower +7.65 μs
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSimple         34.84 K       28.70 μs   ±254.43%       15.19 μs      434.61 μs - 2.18x slower +15.55 μs
Elixir.ElixirXmlParserBenchmark.Parsers.Xmerl                11.82 K       84.60 μs    ±78.39%       61.30 μs      372.30 μs - 6.43x slower +71.45 μs
Elixir.ElixirXmlParserBenchmark.Parsers.XmerlSimple          10.47 K       95.49 μs    ±64.82%       73.85 μs      354.32 μs - 7.26x slower +82.34 μs
Elixir.ElixirXmlParserBenchmark.Parsers.Meeseeks              9.07 K      110.25 μs    ±47.19%       96.23 μs      320.78 μs - 8.38x slower +97.10 μs
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlXpath         3.69 K      270.84 μs    ±19.56%      267.04 μs      413.97 μs - 20.60x slower +257.69 μs
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlStream        3.45 K      289.64 μs    ±16.93%      284.95 μs      443.20 μs - 22.03x slower +276.50 μs

##### With input medium #####
Name                                                             ips        average  deviation         median         99th %
Elixir.ElixirXmlParserBenchmark.Parsers.FastXmlFull           8.50 K      117.60 μs    ±65.64%       95.35 μs      400.04 μs
Elixir.ElixirXmlParserBenchmark.Parsers.SaxySimple            7.43 K      134.50 μs    ±34.48%      117.53 μs      264.57 μs - 1.14x slower +16.90 μs
Elixir.ElixirXmlParserBenchmark.Parsers.Saxy                  7.36 K      135.78 μs    ±34.81%      119.36 μs      283.86 μs - 1.15x slower +18.18 μs
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSax             4.86 K      205.67 μs    ±24.56%      206.40 μs      347.60 μs - 1.75x slower +88.07 μs
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSimple          4.15 K      240.82 μs    ±21.65%      241.48 μs      381.45 μs - 2.05x slower +123.21 μs
Elixir.ElixirXmlParserBenchmark.Parsers.Xmerl                 1.44 K      696.07 μs    ±18.00%      672.90 μs     1054.40 μs - 5.92x slower +578.47 μs
Elixir.ElixirXmlParserBenchmark.Parsers.XmerlSimple           1.25 K      801.35 μs    ±15.28%      773.81 μs     1173.99 μs - 6.81x slower +683.74 μs
Elixir.ElixirXmlParserBenchmark.Parsers.Meeseeks              1.01 K      993.62 μs     ±9.96%      980.20 μs     1287.18 μs - 8.45x slower +876.02 μs
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlStream        0.77 K     1303.02 μs    ±10.56%     1281.68 μs     1898.00 μs - 11.08x slower +1185.42 μs
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlXpath         0.70 K     1430.92 μs     ±8.66%     1410.52 μs     1811.16 μs - 12.17x slower +1313.32 μs

##### With input big #####
Name                                                             ips        average  deviation         median         99th %
Elixir.ElixirXmlParserBenchmark.Parsers.FastXmlFull           906.00        1.10 ms    ±11.10%        1.08 ms        1.56 ms
Elixir.ElixirXmlParserBenchmark.Parsers.Saxy                  747.89        1.34 ms     ±9.58%        1.32 ms        1.80 ms - 1.21x slower +0.23 ms
Elixir.ElixirXmlParserBenchmark.Parsers.SaxySimple            697.94        1.43 ms     ±7.02%        1.42 ms        1.73 ms - 1.30x slower +0.33 ms
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSax             501.52        1.99 ms    ±14.28%        1.94 ms        2.87 ms - 1.81x slower +0.89 ms
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSimple          377.09        2.65 ms     ±9.51%        2.62 ms        3.52 ms - 2.40x slower +1.55 ms
Elixir.ElixirXmlParserBenchmark.Parsers.Xmerl                 138.16        7.24 ms     ±4.99%        7.20 ms        8.80 ms - 6.56x slower +6.13 ms
Elixir.ElixirXmlParserBenchmark.Parsers.XmerlSimple           123.45        8.10 ms    ±10.07%        8.23 ms        9.91 ms - 7.34x slower +7.00 ms
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlStream        118.56        8.43 ms    ±11.01%        8.22 ms       12.15 ms - 7.64x slower +7.33 ms
Elixir.ElixirXmlParserBenchmark.Parsers.Meeseeks               87.19       11.47 ms     ±3.96%       11.39 ms       13.39 ms - 10.39x slower +10.36 ms
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlXpath          66.99       14.93 ms     ±4.19%       14.77 ms       17.24 ms - 13.52x slower +13.82 ms

##### With input huge #####
Name                                                             ips        average  deviation         median         99th %
Elixir.ElixirXmlParserBenchmark.Parsers.FastXmlFull            17.04       58.68 ms     ±4.00%       58.66 ms       64.91 ms
Elixir.ElixirXmlParserBenchmark.Parsers.Saxy                   13.22       75.66 ms     ±2.16%       75.11 ms       81.54 ms - 1.29x slower +16.98 ms
Elixir.ElixirXmlParserBenchmark.Parsers.SaxySimple             11.96       83.60 ms     ±2.77%       83.23 ms       88.76 ms - 1.42x slower +24.93 ms
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSax               6.90      145.02 ms     ±2.59%      143.74 ms      155.06 ms - 2.47x slower +86.34 ms
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSimple            5.31      188.28 ms     ±1.62%      187.59 ms      195.84 ms - 3.21x slower +129.60 ms
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlStream          2.07      482.69 ms     ±4.96%      472.55 ms      521.47 ms - 8.23x slower +424.01 ms
Elixir.ElixirXmlParserBenchmark.Parsers.Xmerl                   1.92      519.73 ms     ±0.66%      519.47 ms      524.41 ms - 8.86x slower +461.05 ms
Elixir.ElixirXmlParserBenchmark.Parsers.XmerlSimple             1.69      592.43 ms     ±1.98%      587.52 ms      620.10 ms - 10.10x slower +533.76 ms
Elixir.ElixirXmlParserBenchmark.Parsers.Meeseeks                1.45      688.99 ms     ±8.39%      694.03 ms      758.79 ms - 11.74x slower +630.31 ms
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlXpath           1.01      985.38 ms     ±1.28%      989.97 ms      994.75 ms - 16.79x slower +926.71 ms
```
