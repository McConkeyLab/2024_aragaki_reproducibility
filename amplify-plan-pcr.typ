#import "@preview/fletcher:0.5.2" as fletcher: diagram, node, edge
#import fletcher.shapes: pill
= `amplify`, `plan-pcr`

#figure(
    grid(
        columns: (1fr, 1fr),
        rows: 50pt,
        image("figures/amplify/amplify-logo.png"),
        image("figures/amplify/plan-pcr-logo.png"),
    ),
    caption: [The `amplify` and `plan-pcr` logos]
)

== Problem
qPCR assays are routine in the McConkey lab. Both #sym.Delta#sym.Delta~C#sub([t]) qPCR assays as well as standard curve assays are frequently used in our workflows. Despite their regularity and consistency, these calculations were often performed manually on paper or in Excel. This is not only tedious, but leaves room for human error. Furthermore, these calculations were largely seen as intermediate and were usually unsaved.

Downstream visualization is possible using exported data, but challenging if recalculations are necessary. While it is possible to go back to the original software to perform recalculations, the software is not available for all operating systems, and it is not immediately obvious how to recalculate manually and consistently to ensure parity with what the default software would provide.

== Solution

=== `plan-pcr`
`plan-pcr` #link("(https://kai-a.shinyapps.io/plan-pcr/)") is a web--based `Shiny` application front--end for the `amplify` package (@plan-pcr_landing), designed to be used with the in--house #sym.Delta#sym.Delta~C#sub([t]) RT--qPCR assay protocol (https://kai.quarto.pub/bok/dd-ct-pcr.html). With `plan-pcr`, users can log into and upload a raw NanoDrop file or other tabular data describing the concentrations (and optionally sample names).

#figure(
    image("figures/amplify/plan-pcr_landing.png"),
    caption: [The default landing page for `plan-pcr`],
) <plan-pcr_landing>

From there, dilutions are calculated with volumes adjusted to the number of selected primers, and mastermix volumes are calculated based on the number of samples (@plan-pcr_sample-prep).

#figure(
    grid(
        rows: 2,
        inset: 1em,
        image("figures/amplify/plan-pcr_sample-prep.png"),
        image("figures/amplify/plan-pcr_mastermix.png"),
    ),
    caption: [Sample and mastermix preparation tables that react dynamically to arguments set in sidebar]
) <plan-pcr_sample-prep>

Additional features include the ability to error if a user is trying to plate an experiment that is larger than the selected plate has space for, or warn if the user may have forgotten a control probe (such as GAPDH). A no--template control (NTC) is included by default, and mastermix volumes increased to account for it. Finally, suggested plate layouts are created, as well as the ability to download a report that specifies all details provided and calculated for the experiment (@plan-pcr_layout).

#figure(
    grid(
        columns: 2,
        inset: 1em,
        image("figures/amplify/plan-pcr_mastermix-layout.png"),
        image("figures/amplify/plan-pcr_sample-layout.png"),
    ),
    caption: [Suggested mastermix and sample layouts]
) <plan-pcr_layout>

=== `amplify`
`amplify` is the backend library that drives `plan-pcr`, and thus anything that can be done in `plan-pcr` can also be done in `amplify`. This is useful for those that prefer a code--based workflow (especially useful in the case of automation).

Consider a toy dataset included with `amplify`:

```r
library(amplify)
dummy_rna_conc
```

```
       sample   conc
1 24hr_DMSO_1 126.80
2 48hr_DMSO_1  93.00
3  24hr_1uM_1 143.07
4  48hr_1uM_1  67.09
5 24hr_DMSO_2  88.32
6 48hr_DMSO_2 123.53
7  24hr_1uM_2  94.24
8  48hr_1uM_2  80.18
```

All arguments that can be set in the sidebar of the web app can be set in arguments to the function `pcr_plan`:

```r
planned <- pcr_plan(
  data = dummy_rna_conc,
  n_primers = 2,
  format = 384,
  exclude_border = TRUE,
  primer_names = c("GENEX", "GENEY")
)

planned
```

```
$mm_prep
# A tibble: 4 × 2
  reagent             vol
  <chr>             <dbl>
1 2X RT-PCR Buffer  206.
2 Primer             20.6
3 25X RT-PCR Enzyme  16.5
4 Nuclease Free H2O 103.

$sample_prep
# A tibble: 8 × 7
  sample       conc dilution_factor diluted_concentration diluted_rna_to_add
  <chr>       <dbl>           <int>                 <dbl>              <dbl>
1 24hr_DMSO_1 127.                5                  25.4               4.73
2 48hr_DMSO_1  93                 1                  93                 1.29
3 24hr_1uM_1  143.                5                  28.6               4.19
4 48hr_1uM_1   67.1               1                  67.1               1.79
5 24hr_DMSO_2  88.3               1                  88.3               1.36
6 48hr_DMSO_2 124.                5                  24.7               4.86
7 24hr_1uM_2   94.2               1                  94.2               1.27
8 48hr_1uM_2   80.2               1                  80.2               1.50
# ℹ 2 more variables: water_to_add <dbl>, final_vol <dbl>

$plate

      3
   ______
1 | ◯ ◯ ◯

Start corner: tl
Plate dimensions: 16 x 24

$n_primers
[1] 2

$format
[1] "384"

$exclude_border
[1] TRUE

$primer_names
[1] "GENEX" "GENEY"
```

A report can be generated (identical to the web version) using `pcr_plan_report`

```r
pcr_plan_report(planned, "~/path/to/report.html")
```

=== Analysis

`amplify` is also capable of downstream analysis, after PCR is performed and data is exported.

==== #sym.Delta#sym.Delta~C#sub([t]) qPCR

`amplify` contains example data from a #sym.Delta#sym.Delta~C#sub([t]) qPCR experiment. Since these data are in a non--standard format, `amplify` also includes functions to convert them into a workable `data.frame`. These functions (`read_pcr`, `scrub`) are from the package `mop`, which will be covered in detail later sections of this chapter.

```r
dat <- system.file("extdata", "untidy-pcr-example-2.xlsx", package = "amplify") |>
  read_pcr() |>
  scrub()
dat
```

```
# A tibble: 384 × 41
    .row  .col  well well_position omit  sample_name target_name task   reporter
   <dbl> <dbl> <dbl> <chr>         <lgl> <chr>       <chr>       <chr>  <chr>
 1     1     1    NA NA            NA    NA          NA          NA     NA
 2     1     2     2 A2            FALSE UC3 PBS     CDH1        UNKNO… FAM
 3     1     3     3 A3            FALSE UC3 PBS     CDH1        UNKNO… FAM
 4     1     4     4 A4            FALSE UC3 Drug    CDH1        UNKNO… FAM
 5     1     5     5 A5            FALSE UC3 Drug    CDH1        UNKNO… FAM
 6     1     6     6 A6            FALSE UC3 Drug    CDH1        UNKNO… FAM
 7     1     7     7 A7            FALSE T24 PBS     CDH1        UNKNO… FAM
 8     1     8     8 A8            FALSE T24 PBS     CDH1        UNKNO… FAM
 9     1     9     9 A9            FALSE T24 PBS     CDH1        UNKNO… FAM
10     1    10    10 A10           FALSE T24 Drug    CDH1        UNKNO… FAM
# ℹ 374 more rows
# ℹ 32 more variables: quencher <chr>, quantity <lgl>, quantity_mean <lgl>,
#   quantity_sd <lgl>, rq <dbl>, rq_min <dbl>, rq_max <dbl>, ct <dbl>,
#   ct_mean <dbl>, ct_sd <dbl>, delta_ct <lgl>, delta_ct_mean <dbl>,
#   delta_ct_sd <dbl>, delta_ct_se <dbl>, delta_delta_ct <dbl>,
#   automatic_ct_threshold <lgl>, ct_threshold <dbl>, automatic_baseline <lgl>,
#   baseline_start <dbl>, baseline_end <dbl>, comments <lgl>, expfail <chr>, …
# ℹ Use `print(n = ...)` to see more rows
```

Typically, it's useful to get a 'bird's eye view' of the data --- particularly if return to the data after a long time. `amplify` includes two functions to do this. `pcr_plate_view` allows users to look at the data as though they were looking at the original plate, while `pcr_plot` plots the relative quantities of the primers in a traditional bar--plot format, stratified by primer.

By default, `pcr_plate_view` uses `target_name` as the variable to color on, showing the layout of the primers:


#figure(
    kind: image,
    grid(
        columns: (1fr, 1fr),
        gutter: 1em,
        fill: luma(245),
        align: left + horizon,
        [```r
pcr_plate_view(dat)
        ```],
        image("figures/amplify/plot-plate_target-name.png")
    ),
    caption: [Plate view of primer layout]
)

However, any column of `dat` can be used:

#figure(
    kind: image,
    grid(
        columns: (1fr, 1fr),
        gutter: 1em,
        fill: luma(245),
        align: left + horizon,
        [```r
pcr_plate_view(dat, sample_name)
        ```],
        image("figures/amplify/plot-plate_sample-name.png")
    ),
    caption: [Plate view of sample layout]
)

By plotting `ct`, we can see that some samples didn't seem to amplify at all:

#figure(
    kind: image,
    grid(
        columns: (1fr, 1fr),
        gutter: 1em,
        fill: luma(245),
        align: left + horizon,
        [```r
library(ggplot2)
pcr_plate_view(dat, ct) +
  scale_color_viridis_c(end = 0.9)
        ```],
        image("figures/amplify/plot-plate_ct.png")
    ),
    caption: [Plate view of C#sub([t]) values]
)

`pcr_plot` can quickly show RQ values:

#figure(
    kind: image,
    grid(
        columns: (1fr, 2fr),
        gutter: 1em,
        fill: luma(245),
        align: left + horizon,
        [```r
pcr_plot(dat)
        ```],
        image("figures/amplify/pcr_plot.png")
    ),
    caption: [Default plot of relative quantities]
)

One thing you'll notice is that the control probe (here PPIA) appears to have no expression. This is the default value exported by QuantStudio, and due to how #sym.Delta#sym.Delta~C#sub([t]) values are calculated, they should all be 1. However, they do have a certain amount of spread, which can be useful to visualize. We can force the RQ values to be calculated for all probes by using `pcr_rq`, which renormalizes the expression to a given sample name. If we supply the current relative sample (RT112 Drug), the only thing that will change is the addition of RQ values for PPIA:

#figure(
    kind: image,
    grid(
        columns: (1fr, 2fr),
        gutter: 1em,
        fill: luma(245),
        align: left + horizon,
        [```r
pcr_rq(dat, "RT112 Drug") |>
  pcr_plot()
        ```],
        image("figures/amplify/pcr_plot_after_rq.png")
    ),
    caption: [Plot of relative quantities with PPIA relative quantities included]
)

We can use the `group` parameter to normalize within a given subgroup. This is useful for our case,  since it might make more sense to normalize within each cell line, rather than globally.

#figure(
    kind: image,
    grid(
        rows: 2,
        gutter: 1em,
        fill: luma(245),
        [```r
dat |>
  tidyr::separate(sample_name, c("cell_line", "sample_name"), remove = FALSE) |>
  pcr_rq("PBS", group = "cell_line") |>
  pcr_plot() +
  ggplot2::facet_grid(cell_line~target_name) +
  ggplot2::scale_y_log10()
        ```],
        image("figures/amplify/pcr_rq_group.png")
    ),
    caption: [RQ values normalized to their respective cell line controls]
)

We can see from these data that TP63 tends to be down-regulated in our luminal (RT112, UC14) lines upon exposure to our drug (but not our basal lines, T24 and UC3, which appear not to express TP63).

==== Standard Curves PCR
Another routine PCR task in the McConkey lab is PCR to quantify library concentration. This is to ensure the correct absolute amount of library is loaded into the chip, to ensure equal balancing and thus equal depth of coverage for both samples within the same chip (multiplexing via barcoding), as well as additional samples across other chips for a given study.

`amplify` comes with toy data from one of these experiments:

```r
tidy_lib <- system.file("extdata", "untidy-standard-curve.xlsx", package = "amplify") |>
  read_pcr() |>
  tidy_lab(pad_zero = TRUE)
```

(The `pad_zero` argument converts sample names from "Sample 1" to "Sample 01" to ensure the proper order upon lexicographic ordering)

By default, `pcr_tidy` assumes a standards serial dilution starting at 6.8, diluted by a factor of 10, going all the way down to 0.00068, and that all of them should be included. There are a couple instances in which this might not be the case:

1. Different serial dilutions were used
2. A particularly bad standard is making slope calculations inaccurate

In that instance, supply a numeric vector to the `usr_standards` argument. If you wish to omit a given set of standards, simply do not include them in this vector:

```r
custom_lib <- system.file("extdata", "untidy-standard-curve.xlsx", package = "amplify") |>
  read_pcr() |>
  tidy_lab(pad_zero = TRUE, usr_standards = c(6.8, .68, .068, .0068))

scrub(custom_lib) |>
  dplyr::filter(task == "STANDARD") |>
  dplyr::select(sample_name, quantity)
```

```
   sample_name quantity
   <chr>          <dbl>
 1 Standard 01  6.80
 2 Standard 01  6.80
 3 Standard 01  6.80
 4 Standard 02  0.680
 5 Standard 02  0.680
 6 Standard 03  0.0680
 7 Standard 03  0.0680
 8 Standard 03  0.0680
 9 Standard 04  0.00680
10 Standard 04  0.00680
11 Standard 04  0.00680
```

This will automatically update the slope column of the dataframe as well. This can be called standalone (say, after manually removing a few standards replicates from your dataset) by running `pcr_calc_slope`.

Library concentrations can easily be calculated with `pcr_lib_calc`, specifying the sample dilution factor with `dil_factor` (here 1:1000):

```r
lib_conc <- tidy_lib |>
  pcr_lib_calc(dil_factor = 1000)

lib_conc |>
  scrub() |>
  dplyr::filter(task == "UNKNOWN") |>
  dplyr::select(sample_name, concentration)
```

```
# A tibble: 42 × 2
   sample_name concentration
   <chr>               <dbl>
 1 Sample 06           2039.
 2 Sample 06           2039.
 3 Sample 06           2039.
 4 Sample 12           1893.
 5 Sample 12           1893.
 6 Sample 12           1893.
 7 Sample 04           1694.
 8 Sample 04           1694.
 9 Sample 04           1694.
10 Sample 16           1493.
# ℹ 32 more rows
# ℹ Use `print(n = ...)` to see more rows
```

Routine quality control plots can also be generated quickly. First, the data is generated using `pcr_lib_qc`:

```r
qc <- pcr_lib_qc(lib_conc)
```

This output is generally not useful by itself. Using `pcr_lib_qc_plot_*` functions on it, however, generates plots that display valuable visual QC summaries

Making standard curve for libraries requires making a serial dilution of standards. It is important we determine that this serial dilution was diluted properly, or the results calculated from it will be unreliable. The standard dilution plot helps with this:

#figure(
    kind: image,
    grid(
        columns: (1fr, 2fr),
        gutter: 1em,
        fill: luma(245),
        align: left + horizon,
        [```r
pcr_lib_qc_plot_dil(qc)
       ```],
        image("figures/amplify/pcr_lib_qc_plot_dil.png")
    ),
    caption: [A standard curve quality control plot]
)


From this plot, we can see the relative dilution factors between samples. From this example, we can see a 9.3x dilution between the first and second, 12.2x dilution between second and third, etc. They gray dots represent where our blue dots should land if all the dilutions are perfect AND if efficiency is 100%. The red dots represent where the samples lie.

This plot can catch three sources of issues:

- Inconsistent pipetting, which would show dilution factors widely varying from 10x or
- Systematically incorrect pipetting, which would show dilutions consistently below or above 10x or
- Poor efficiency of the enzyme, which would appear to show dilutions consistently above 10x.

Determining efficiency issues vs consistently under-pipetting, however, is impossible to determine with the data alone.

Another useful diagnostic plot involves plotting the logarithm of the known concentrations of standards against their observed C#sub([t]) values:

#figure(
    kind: image,
    grid(
        columns: (1fr, 1fr),
        gutter: 1em,
        fill: luma(245),
        align: left + horizon,
        [```r
pcr_lib_qc_plot_slope(qc)
       ```],
        image("figures/amplify/pcr_lib_qc_plot_slope.png")
    ),
    caption: [A diagnostic plot of log(quantity) versus log(C#sub([t]))]
)

In this plot, the log10 of the theoretical values of the standards is plotted against the C#sub([t]) values of the standards. In a perfect world, where the enzyme perfectly doubles the amount of product each cycle, we would expect that a standard 1/10th of the concentration would reach the same level of amplification in around 3.3 cycles (2#super([3.3]) is approximately 10). Thus, in a perfect world we expect to see a slope of -3.3, an R#super([2]) of 1, and an efficiency of 100%.

Additional diagnostic plots, such as outlier detection and removal, can be generated along with all the other plots and combined in a report using the `pcr_lib_qc_report` function. This report includes annotations for each plot to help users interpret their results.

== Conclusion
`amplify` (which powers `plan-pcr`) provides straightforward and consistent means for both experimental setup and analysis for #sym.Delta#sym.Delta~C#sub([t]) and standard curve PCR experiments. Importantly, it does not attempt to be an all purpose tool, but rather to be tailored specifically to routine tasks in the McConkey lab.

#figure(
    grid(
        fill: luma(245),
        rows: 2,
        gutter: 1em,
        inset: 1em,
        diagram(
            node((0, 0), [RNA Concentration Data]),
            edge("->"),
            edge((1,1), "->"),
            node((1, 0), image("figures/amplify/plan-pcr-logo.png", width: 30pt)),
            node((1, 1), image("figures/amplify/amplify-logo.png", width: 30pt)),
            edge((1, 1), (1, 0), "..>"),
            edge((1, 0), (2, 0), "->"),
            edge((1, 1), (2, 0), "->"),
            node((2, 0), [Report], width: 50pt),
        ),
        diagram(
            node((0, 0), [QuantStudio]),
            edge("..>", [Export]),
            node((2, 0), image("figures/amplify/amplify-logo.png", width: 30pt)),
            edge("->"),
            node((3, -1), [Standard Curve]),
            edge((2,0), (3,1), "->"),
            node((3, 1), [#sym.Delta#sym.Delta~C#sub([t]) qPCR]),
            edge((3, -1), (4, -1), "->"),
            node((4, -1), [Report], width: 50pt),
            edge((3, 1), (4,1), "->"),
            node((4, 1), [Plot]),
        ),
    ),
    caption: [A broad overview of workflows. Top: Workflows for experiment setup. Bottom: Workflows for result analysis]
)
