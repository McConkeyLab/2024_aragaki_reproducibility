= `gplate`

#let src_and_img(src, img, cap) = {
    figure(
        kind: image,
        grid(
            columns: (1.5fr, 1fr),
            gutter: 1em,
            align:left + horizon,
            src,
            img
        ),
        caption: [#cap]
    )
}


#figure(
    image("figures/gplate/logo.png"),
    caption: [The `gplate` package hex logo]
)


== Problem
Microwell plates are usually arranged in visually meaningful ways but are not tidy data ('tidy' is a format in which each column of data is a variable, each row is a 'case', and each cell/box is a value), and their manipulation to and from a tidy form is cumbersome. While packages like `plater` exist, they require creation of a template file, which limits its usefulness in a programmatic setting and reduces reproducibility.

== Solution
`gplate` provides a grammar of plates. The goal is to provide a succinct yet flexible language for specifying a variety of common plate layouts. This allows for both rapid tidying of data as well as plotting plate layouts, useful for instances like writing documentation (for protocols specifying plate layouts), user interfaces, and quality control (such as to check for spatial patterns of variables).

`gplate` has three main verbs:
- `gp`, which creates the plate
- `gp_sec`, which adds sections to the plate
- `gp_plot`, which plots the plate with a variable overlaid

=== Plotting
`gplate` can be used to plot plate layouts. To begin, we first need to create a `gp` object:

```r
gp <- gp(rows = 8, cols = 12)
```

Then we can plot it with `gp_plot`:

#src_and_img(
    [```r
gp_plot(gp)
    ```],
    image("figures/gplate/sec.png"),
    [A `gp`, plotted]
)

By default, this is not particularly useful. By adding 'sections', we can begin to specify common plate layouts. At its simplest, consider a plate divided into four quadrants:
#src_and_img(
    ```r
gp_quads <- gp_sec(
  gp, name = "quadrant", nrow = 4, ncol = 6
)
gp_plot(gp_quads)
    ```,
    image("figures/gplate/quads.png"),
    [A `gp` plotted with quadrant sections]
)

Sections are, by default, 'nested' --- meaning sections can themselves have sections:
#src_and_img(
    ```r
gp_split <- gp_sec(
  gp_quads, name = "split", nrow = 2, ncol = 3
)
gp_plot(gp_split)
    ```,
    image("figures/gplate/split.png"),
    [A `gp` where the sections have sections]
)

By default, `gp_plot` will plot the most recently added section --- but lower sections can still be plotted by their section `name`:

#src_and_img(
    ```r
gp_plot(gp_split, quadrant)
    ```,
    image("figures/gplate/quads-from-sec.png"),
    [A `gp` with multiple layers, with a previous layer plotted]
)

Various arguments to `gp_sec` allow for more flexible specifications:

#src_and_img(
    ```r
with_margin <- gp_sec(
  gp, name = "with_margin", nrow = 3, ncol = 3, margin = 1
)
gp_plot(with_margin)
    ```,
    image("figures/gplate/margin.png"),
    [A `gp` where each section has a margin]
)

#src_and_img(
    ```r
with_wrapping <- gp_sec(
  gp, name = "with_wrap", nrow = 3, ncol = 7, wrap = TRUE
)
gp_plot(with_wrapping)
    ```,
    image("figures/gplate/wrap.png"),
    [A `gp` where sections can wrap to the next section below]
)

#src_and_img(
    ```r
no_breaking <- gp_sec(
  gp, name = "no_break", nrow = 3, ncol = 7,
  break_sections = FALSE
)
gp_plot(no_breaking)
    ```,
    image("figures/gplate/no_break.png"),
    [A `gp` where only whole sections are allowed]
)

#src_and_img(
    ```r
flow_by_col <- gp_sec(
  gp, name = "flow_col", nrow = 3, ncol = 7,
  wrap = TRUE, flow = "col"
)
gp_plot(flow_by_col)
    ```,
    image("figures/gplate/flow_col.png"),
    [A `gp` where the next section is in the same column, rather than the same row]
)

These can be combined for highly elaborate designs:

#src_and_img(
    ```r
with_wrapping <- gp_sec(
  gp, name = "with_wrap", nrow = 4, ncol = 4,
  margin = c(1, 1, 0, 0), wrap = TRUE, flow = "col"
)
gp_plot(with_wrapping)
    ```,
    image("figures/gplate/elaborate.png"),
    [A highly elaborate `gp`]
)

=== Tidying

With `gplate`, plotting and tidying go hand--in--hand. As a motivating example, `gplate` comes with absorbance data from a 96 well plate from a protein quantification (BCA) assay.

```r
protein_quant
```

```
       [,1]   [,2]   [,3]   [,4]   [,5]   [,6]   [,7]   [,8]   [,9]  [,10]  [,11]  [,12]
[1,] 0.0691 0.0801 0.0978 0.1212 0.1731 0.2395 0.3812 0.2402 0.2593 0.2525 0.2371 0.2572
[2,] 0.0693 0.0810 0.0966 0.1247 0.1732 0.2454 0.3988 0.2527 0.2636 0.2636 0.2419 0.2616
[3,] 0.0711 0.0827 0.1011 0.1256 0.1855 0.2466 0.3967 0.2515 0.2580 0.2602 0.2422 0.2608
[4,] 0.2735 0.2725 0.2583 0.2708 0.2693 0.2749 0.2610 0.0739 0.0718 0.0715 0.0682 0.0651
[5,] 0.2501 0.2634 0.2559 0.2630 0.2650 0.2629 0.2548 0.0696 0.0667 0.0646 0.0621 0.0622
[6,] 0.2549 0.2699 0.2513 0.2578 0.2588 0.2624 0.2463 0.0726 0.0727 0.0725 0.0710 0.0708
[7,] 0.0799 0.0951 0.0805 0.0796 0.0768 0.0792 0.0774 0.0762 0.0766 0.0767 0.0760 0.0784
[8,] 0.0456 0.0456 0.0505 0.0469 0.0469 0.0476 0.0474 0.0457 0.0456 0.0474 0.0467 0.0457
```

Coincidentally, the process of describing the layout of the plate through plotting and the process of tidying the data are one and the same:

Each sample is in triplicate, and each triplicate stands next to one another moving from left to right, wrapping around to the next ‘band’ of rows when it hits an edge. Or, more simply:

#src_and_img(
    ```r
gp(8, 12) |>
  gp_sec("samples", nrow = 3, ncol = 1) |>
  gp_plot(samples) +
  ggplot2::theme(legend.position = "none")
    ```,
    image("figures/gplate/all_samples.png"),
    [Protein quantification sample placement strategy]
)


However, there are some wells that have sample in them, and some that are empty. To specify the difference between the two:

#src_and_img(
    ```r
gp(8, 12) |>
  gp_sec(
    "has_sample", nrow = 3, ncol = 19,
    wrap = TRUE, labels = "sample"
  ) |>
  gp_plot(has_sample)
    ```,
    image("figures/gplate/has_sample.png"),
    [Wells that have samples]
)

Notice the `wrap = TRUE` --- this allows for sections that are bigger than the ‘parent section’ (here the plate) by wrapping them around to the next ‘band’.

To label each replicate as a number of a triplicate --- the top sample is 1, the middle is 2, and the bottom is 3 --- we do:

#src_and_img(
    ```r
gp(8, 12) |>
  gp_sec(
    "has_sample", nrow = 3, ncol = 19,
    wrap = TRUE, labels = "sample"
  ) |>
  gp_sec("replicate", nrow = 1) |>
  gp_plot(replicate)
    ```,
    image("figures/gplate/replicate.png"),
    [Technical replicate for each sample]
)

Here, specifying `ncol` is not necessary. This is because by default, a section will take up the maximum space possible (here 19).

Some of these samples make up a standard curve, while others make up ‘unknowns’. Note how I specify a vector `c(7, 12)` to denote two differently sized sections, labeled as shown in the `labels` argument

#src_and_img(
    ```r
gp(8, 12) |>
  gp_sec(
    "has_sample", nrow = 3, ncol = 19,
    wrap = TRUE, labels = "sample"
  ) |>
  gp_sec("replicate", nrow = 1, advance = F) |>
  gp_sec(
    "type", nrow = 3, ncol = c(7, 12),
    labels = c("standard", "sample")
  ) |>
  gp_plot(type)
    ```,
    image("figures/gplate/is_sample.png"),
    [Annotating sample type]
)

Note the addition of the argument `advance = F` in the previous section. This ensures that the next section --- type --- will be a sibling of replicate, rather than its child. That is, we continue to annotate relative to `has_sample` rather than annotating relative to replicate.

Finally, I'm going to give an index for each sample:

#src_and_img(
    ```r
gp(8, 12) |>
  gp_sec(
    "has_sample", nrow = 3, ncol = 19,
    wrap = TRUE, labels = "sample"
  ) |>
  gp_sec("replicate", nrow = 1, advance = F) |>
  gp_sec(
    "type", nrow = 3, ncol = c(7, 12),
    labels = c("standard", "sample")
  ) |>
  gp_sec("sample", ncol = 1) |>
  gp_plot(sample) +
  theme(
    # Too many samples - clutters the plot
    legend.position = "none"
  )
    ```,
    image("figures/gplate/done.png"),
    [Finished annotated `gp` with sample indices]
)

Now, the fun part: since we described our data so well, tidying it is very easy. First, we supply our data as the third argument of `gp`:

```r
my_plate <- gp(8, 12, protein_quant) |>
  gp_sec(
    "has_sample", nrow = 3, ncol = 19,
    wrap = TRUE, labels = "sample"
  ) |>
  gp_sec("replicate", nrow = 1, advance = F) |>
  gp_sec(
    "type", nrow = 3, ncol = c(7, 12),
    labels = c("standard", "sample")
  ) |>
  gp_sec("sample", ncol = 1)
```
And now we use `gp_serve`:

```r
gp_serve(my_plate) |>
  dplyr::arrange(.row, .col) |>
  head(20)
```

```
# A tibble: 20 × 7
    .row  .col  value has_sample replicate type     sample
   <int> <int>  <dbl> <fct>      <fct>     <fct>    <fct>
 1     1     1 0.0691 sample     1         standard 1
 2     1     2 0.0801 sample     1         standard 2
 3     1     3 0.0978 sample     1         standard 3
 4     1     4 0.121  sample     1         standard 4
 5     1     5 0.173  sample     1         standard 5
 6     1     6 0.240  sample     1         standard 6
 7     1     7 0.381  sample     1         standard 7
 8     1     8 0.240  sample     1         sample   1
 9     1     9 0.259  sample     1         sample   2
10     1    10 0.252  sample     1         sample   3
11     1    11 0.237  sample     1         sample   4
12     1    12 0.257  sample     1         sample   5
13     2     1 0.0693 sample     2         standard 1
14     2     2 0.081  sample     2         standard 2
15     2     3 0.0966 sample     2         standard 3
16     2     4 0.125  sample     2         standard 4
17     2     5 0.173  sample     2         standard 5
18     2     6 0.245  sample     2         standard 6
19     2     7 0.399  sample     2         standard 7
20     2     8 0.253  sample     2         sample   1
```

Note that each well is properly annotated with its initial absorbance (in the `value` column), as well as all other details pertaining to each sample.

== Conclusion
`gplate` provides a succinct yet flexible grammar to allow for both plotting and tidying of microwell plate data. This package has been used to create the plate interfaces for `plan-pcr`, as well as for the `pcr_plate_view` function in `amplify`.
