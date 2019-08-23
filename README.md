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

Benchee generated HTML results are located in `/docs/` and are accessible at
https://coffei.github.io/elixir_xml_parser_benchmark/.

```
##### With input small #####
Name                                                             ips        average  deviation         median         99th %
Elixir.ElixirXmlParserBenchmark.Parsers.Saxy                 75.17 K       13.30 μs   ±464.72%        8.41 μs       29.56 μs
Elixir.ElixirXmlParserBenchmark.Parsers.SaxySimple           71.75 K       13.94 μs   ±448.62%        8.71 μs       34.76 μs - 1.05x slower +0.63 μs
Elixir.ElixirXmlParserBenchmark.Parsers.FastXmlFull          63.42 K       15.77 μs   ±466.67%       11.86 μs       30.10 μs - 1.19x slower +2.47 μs
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSax            47.36 K       21.11 μs   ±358.31%        9.62 μs      307.90 μs - 1.59x slower +7.81 μs
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSimple         34.68 K       28.84 μs   ±254.32%       15.27 μs      438.17 μs - 2.17x slower +15.53 μs
Elixir.ElixirXmlParserBenchmark.Parsers.Xmerl                11.85 K       84.41 μs    ±77.97%       61.39 μs      375.60 μs - 6.35x slower +71.11 μs
Elixir.ElixirXmlParserBenchmark.Parsers.XmerlSimple          10.22 K       97.82 μs    ±69.69%       76.39 μs      361.09 μs - 7.35x slower +84.52 μs
Elixir.ElixirXmlParserBenchmark.Parsers.Meeseeks              8.80 K      113.65 μs    ±46.45%       98.99 μs      325.72 μs - 8.54x slower +100.35 μs
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlXpath         3.66 K      272.96 μs    ±19.74%      268.82 μs      429.60 μs - 20.52x slower +259.66 μs
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlStream        3.45 K      289.72 μs    ±17.51%      284.61 μs      459.57 μs - 21.78x slower +276.42 μs

##### With input medium #####
Name                                                             ips        average  deviation         median         99th %
Elixir.ElixirXmlParserBenchmark.Parsers.FastXmlFull           8.57 K      116.75 μs    ±64.02%       94.39 μs      399.84 μs
Elixir.ElixirXmlParserBenchmark.Parsers.Saxy                  7.48 K      133.68 μs    ±32.09%      118.71 μs      257.07 μs - 1.14x slower +16.92 μs
Elixir.ElixirXmlParserBenchmark.Parsers.SaxySimple            7.22 K      138.57 μs    ±33.80%      122.26 μs      268.53 μs - 1.19x slower +21.82 μs
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSax             4.82 K      207.67 μs    ±25.07%      206.94 μs      358.11 μs - 1.78x slower +90.91 μs
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSimple          3.98 K      251.17 μs    ±21.47%      251.73 μs      396.87 μs - 2.15x slower +134.42 μs
Elixir.ElixirXmlParserBenchmark.Parsers.Xmerl                 1.42 K      705.19 μs    ±16.46%      692.47 μs     1036.42 μs - 6.04x slower +588.44 μs
Elixir.ElixirXmlParserBenchmark.Parsers.XmerlSimple           1.25 K      799.83 μs    ±14.93%      775.59 μs     1171.58 μs - 6.85x slower +683.07 μs
Elixir.ElixirXmlParserBenchmark.Parsers.Meeseeks              0.98 K     1017.63 μs    ±12.89%      993.22 μs     1635.88 μs - 8.72x slower +900.88 μs
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlStream        0.77 K     1290.36 μs     ±9.53%     1274.56 μs     1717.87 μs - 11.05x slower +1173.61 μs
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlXpath         0.71 K     1410.90 μs    ±10.90%     1391.93 μs     1938.20 μs - 12.08x slower +1294.14 μs

##### With input big #####
Name                                                             ips        average  deviation         median         99th %
Elixir.ElixirXmlParserBenchmark.Parsers.FastXmlFull           913.00        1.10 ms    ±12.63%        1.07 ms        1.75 ms
Elixir.ElixirXmlParserBenchmark.Parsers.Saxy                  715.03        1.40 ms    ±11.98%        1.37 ms        2.14 ms - 1.28x slower +0.30 ms
Elixir.ElixirXmlParserBenchmark.Parsers.SaxySimple            677.98        1.47 ms     ±7.84%        1.46 ms        1.97 ms - 1.35x slower +0.38 ms
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSax             499.54        2.00 ms    ±13.83%        1.96 ms        2.90 ms - 1.83x slower +0.91 ms
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSimple          373.39        2.68 ms     ±6.76%        2.65 ms        3.66 ms - 2.45x slower +1.58 ms
Elixir.ElixirXmlParserBenchmark.Parsers.Xmerl                 136.37        7.33 ms     ±4.69%        7.30 ms        8.77 ms - 6.70x slower +6.24 ms
Elixir.ElixirXmlParserBenchmark.Parsers.XmerlSimple           123.30        8.11 ms     ±9.99%        8.23 ms        9.80 ms - 7.40x slower +7.01 ms
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlStream        119.37        8.38 ms    ±10.56%        8.18 ms       11.86 ms - 7.65x slower +7.28 ms
Elixir.ElixirXmlParserBenchmark.Parsers.Meeseeks               86.02       11.62 ms     ±3.94%       11.55 ms       13.93 ms - 10.61x slower +10.53 ms
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlXpath          66.73       14.98 ms     ±2.88%       14.89 ms       16.71 ms - 13.68x slower +13.89 ms

##### With input huge #####
Name                                                             ips        average  deviation         median         99th %
Elixir.ElixirXmlParserBenchmark.Parsers.FastXmlFull            16.49       60.63 ms     ±4.52%       60.59 ms       69.75 ms
Elixir.ElixirXmlParserBenchmark.Parsers.Saxy                   12.99       76.98 ms     ±2.12%       76.49 ms       81.09 ms - 1.27x slower +16.35 ms
Elixir.ElixirXmlParserBenchmark.Parsers.SaxySimple             11.83       84.52 ms     ±3.51%       84.16 ms       98.79 ms - 1.39x slower +23.88 ms
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSax               6.80      147.07 ms     ±2.63%      146.12 ms      161.56 ms - 2.43x slower +86.44 ms
Elixir.ElixirXmlParserBenchmark.Parsers.ErlsomSimple            5.34      187.43 ms     ±1.87%      186.85 ms      199.28 ms - 3.09x slower +126.80 ms
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlStream          2.14      468.24 ms     ±3.97%      465.01 ms      506.71 ms - 7.72x slower +407.61 ms
Elixir.ElixirXmlParserBenchmark.Parsers.Xmerl                   1.90      525.87 ms     ±0.77%      526.99 ms      533.50 ms - 8.67x slower +465.24 ms
Elixir.ElixirXmlParserBenchmark.Parsers.XmerlSimple             1.69      592.64 ms     ±1.04%      593.07 ms      603.30 ms - 9.77x slower +532.01 ms
Elixir.ElixirXmlParserBenchmark.Parsers.Meeseeks                1.42      702.51 ms     ±9.00%      725.32 ms      762.43 ms - 11.59x slower +641.88 ms
Elixir.ElixirXmlParserBenchmark.Parsers.SweetXmlXpath           1.01      991.81 ms     ±1.59%      996.98 ms     1004.46 ms - 16.36x slower +931.18 ms
```
