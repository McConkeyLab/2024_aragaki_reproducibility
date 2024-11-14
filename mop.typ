= `mop`
== Problem
Bench science typically involves receiving data from various machines, all with their own data output. Unfortunately, this format of data is rarely --- if ever --- conducive for data science. As Hadley Wickham (referencing Tolstoy) said in his seminal 'Tidy Data' paper@Wickham_2014,

#quote(block: true, emph("Tidy datasets are all alike but every messy dataset is messy in its own way"))

Standard workflows typically involve manual extraction of the data from the output file into a spreadsheet. While this is straightforward, it is neither reproducible, nor easily automated.

== Solution
In a similar vein, the package `broom` has been developed by Robinson et al.@Robinson_2014 to turn the heterogeneous outputs from various statistical tests into a normalized format. `mop` seeks to be the wet--lab analogue to `broom`, by providing a library of tidying methods for lab equipment.

As an example, consider the output from the SpectraMax Plus 384 microplate reader:

```
\u{23}\u{23}BLOCKS= 2
Plate:	Plate\u{23}1	1.3	PlateFormat	Endpoint	Absorbance	Raw	FALSE	1						2	562 660	1	12	96	1	8	None
	Temperature(°C)	1	2	3	4	5	6	7	8	9	10	11	12		1	2	3	4	5	6	7	8	9	10	11	12
	36.80	0.9351	1.0388	0.3033	0.1591	0.1249	0.053	1.0183	1.0368	0.3377	0.1362	0.1638	0.0473		0.087	0.0926	0.0546	0.0485	0.047	0.0434	0.106	0.0935	0.0559	0.0442	0.0435	0.0386
		1.0475	0.9804	0.2747	0.1357	0.1272	0.0513	0.9335	1.0021	0.2854	0.1253	0.1223	0.0582		0.0882	0.0871	0.0533	0.0488	0.0483	0.0442	0.0845	0.0893	0.054	0.0488	0.0485	0.0456
		1.0212	1.0776	0.2832	0.1408	0.1153	0.0512	0.9089	1.0131	0.296	0.1381	0.147	0.0494		0.0899	0.0962	0.0555	0.0483	0.0476	0.0444	0.0834	0.0896	0.0542	0.0476	0.0473	0.0431
		1.0481	1.0455	0.362	0.1302	0.1369	0.0541	0.9216	1.0161	0.2741	0.1387	0.1252	0.0575		0.0918	0.0928	0.061	0.0512	0.0513	0.0484	0.087	0.0989	0.061	0.0541	0.0563	0.0536
		1.0451	1.0136	0.307	0.1202	0.1483	0.0573	0.9561	1.0702	0.2318	0.1683	0.1083	0.0517		0.0995	0.0917	0.059	0.0498	0.0516	0.0482	0.0862	0.0945	0.0547	0.0509	0.0482	0.0454
		1.0999	1.0568	0.2795	0.1276	0.1227	0.0584	0.9058	1.0868	0.2685	0.134	0.1078	0.055		0.0984	0.0958	0.0609	0.0544	0.0542	0.0524	0.0888	0.0995	0.0611	0.0555	0.0533	0.0522
		1.1361	1.0054	0.294	0.1234	0.1262	0.0609	0.8984	1.0046	0.2102	0.1235	0.1219	0.0655		0.1049	0.0949	0.064	0.0564	0.0561	0.0535	0.0893	0.0961	0.058	0.0558	0.068	0.06
		1.1104	0.975	0.3491	0.1566	0.1234	0.0618	1.029	0.8426	0.2196	0.17	0.1288	0.0424		0.1033	0.0978	0.0688	0.0596	0.0586	0.0551	0.1028	0.0906	0.0618	0.0664	0.0577	0.0385

~End
Original Filename: Untitled   Date Last Saved: Unsaved
Copyright © 2003 Molecular Devices. All rights reserved.
```

It is difficult to tell with line--wrapping, but these data show absorbances of a 96 well plate at two wavelengths (562 and 660nm). A screenshot on a sufficiently wide editor will show this pattern:

#image("./figures/mop/spectramax.png")

This format may be useful for directly copy--pasting in to a spreadsheet, but is tremendously difficult to work with programatically in its current state.

Unlike `broom`, which can detect the kind of data given its `class`, there is no simple and robust way to automatically detect the kind of data provided. `mop` provides several 'reader' functions to wrangle data from a particular source:

#raw(block: true, lang: "R", "library(bladdr)
library(mop)

file <- bladdr::get_gbci(
  \u{22}Raw Data/SPECTRAmax/aragaki-kai/MTT/2024-07-21_upfl1r-309-erda-dr.txt\u{22}
)

tidy <- mop::read_spectramax(file, date = as.Date(\u{22}2024-07-21\u{22}))
tidy")

```
<spectramax[4]>
[[1]]
[[1]]$data

                12
   ________________________
  | ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯
  | ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯
  | ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯
  | ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯
8 | ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯
  | ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯
  | ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯
  | ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯ ◯

Start corner: tl
Plate dimensions: 8 x 12

[[1]]$type
[1] Plate

[[1]]$wavelengths
[1] 562 660


# Date: 2024-07-21
```

Each reader exports its own class (here a `spectramax`) that developers can use to form common interfaces for like--data on different machines. However, as an end user it can often be easier to work with the data as a flat `data.frame`. Each class also has its own `scrub` method to convert the object into a `data.frame`:

```r
scrub(tidy)
```

```
# A tibble: 96 × 6
    .row  .col nm562  nm660 exp_date   is_tidy
   <int> <dbl> <dbl>  <dbl> <date>     <lgl>  
 1     1     1 0.935 0.087  2024-07-21 TRUE   
 2     1     2 1.04  0.0926 2024-07-21 TRUE   
 3     1     3 0.303 0.0546 2024-07-21 TRUE   
 4     1     4 0.159 0.0485 2024-07-21 TRUE   
 5     1     5 0.125 0.047  2024-07-21 TRUE   
 6     1     6 0.053 0.0434 2024-07-21 TRUE   
 7     1     7 1.02  0.106  2024-07-21 TRUE   
 8     1     8 1.04  0.0935 2024-07-21 TRUE   
 9     1     9 0.338 0.0559 2024-07-21 TRUE   
10     1    10 0.136 0.0442 2024-07-21 TRUE   
# ℹ 86 more rows
# ℹ Use `print(n = ...)` to see more rows
```

== Conclusion
This package provides a starting point for a library of tidying functions. Each function has the following:
- A reading function
- A tidying function (often inextricably linked to the reading function)
- A `scrub` method

Current supported types include data exported from the Incucyte, QuantStudio, SpectraMax, and Nanodrop. Like `broom`, the straightforward and modular structure of this package makes contribution for additional machine types and data formats easy.
