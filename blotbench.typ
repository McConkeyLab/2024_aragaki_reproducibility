#import "@preview/fletcher:0.5.2" as fletcher: diagram, node, edge
#import fletcher.shapes: pill

= `blotbench`

== Problem
A previous report has found that roughly 4% of 20,621 paper analyzed across 40 journals contained inappropriate image duplication @Bik_2016, particularly with western blots. When preparing western blots for presentation, typical workflows usually involve cropping the blots in something like PhotoShop, GIMP, FIJI, etc. Because this manipulation was done in a separate program, usually the best we can do in terms of reproducibility is by providing the original, unmodified images along with the cropped version (@traditional-wb-wf).
#figure(
    diagram(
        label-size: 8pt,
        spacing: 2em,
        node((0,0), [Raw Image]),
        edge("..|>", [Image Editor]),
        node((3,0), [Edited Image]),
        edge("->"),
        edge((0,0), (4,0), "->", bend: 30deg),
        node((4,0), [Publication]),
    ),
    caption: [A traditional western blot editing workflow]
) <traditional-wb-wf>


#figure(
    diagram(
        spacing: 2em,
        node((0,0), [Raw Image]),
        edge("->"),
        node((1,0), [Code]),
        edge("->"),
        node((2,0), [Edited Image]),
        edge("->"),
        edge((0,0), (3,0), "->", bend: 30deg),
        edge((1,0), (3,0), "->", bend: 30deg),
        node((3,0), [Publication]),
    ),
    caption: [Code-based western blot editing workflow]
) <code-wb-wf>

There are methods for reproducibly manipulating images in R (such as `magick` and `EBImage`) (@code-wb-wf), but they aren't nearly as convenient as the real--time visual feedback of typical photo--editing software --- the guess--then--render--repeat loop (@guess-then-render) of trying to find the perfect cropping geometry for an image without this visual feedback is tedious at best, and convenience and ease are important to promote adoption.

#figure(
    diagram(
        spacing: 2em,
        node((0,0), [Raw Image]),
        edge("->"),
        node((0,1), [Write Code]),
        edge("->"),
        node((0,2), [View]),
        edge("->"),
        node((0,3), [Looks Correct?]),
        edge((0,3), (0,1), [No], "->", bend: 50deg),
        edge((0,3), (0,4), [Yes], "->"),
        node((0,4), [Done]),
    ),
    caption: [Standard code--based guess--then--render--repeat loop]
) <guess-then-render>


== Solution
`blotbench` attempts to solve this by providing a Shiny app within the package to perform rudimentary image manipulations with visual feedback. This app outputs code that should be written to create these transformations (rather than the image itself) so the declarative and reproducible benefits of a script can be reaped while still leveraging the convenience of a graphical interface.

In addition, `blotbench` introduces a new object (a `wb` object) that can store row and column annotation much like a `SummarizedExperiment` (@wb). This provides additional benefits such as intuitive indexing (which allows for treating a blot image almost like a `data.frame`) and automatic annotation.

#figure(
    image("figures/blotbench/wb.png", width: 50%),
    caption: [An example `wb` object]
) <wb>

=== Creating a `wb` object

A `wb` object is composed of 4 components:

1. `imgs`: A vector of `image-magick` images
2. #text(fill: green)[`col_annot`]: A `data.frame` containing lane annotation, one line for each column, with the top row referring to the left-most lane
3. #text(fill: red)[`row_annot`]: A `data.frame` containing names of the protein blotted for in each image.
4. #text(fill: blue)[`transforms`]: A `data.frame` containing information detailing what transformations should be performed on the image for presentation.

When creating a `wb` object, you typically will not specify the transforms at the outset, and both `col_annot` and `row_annot` are optional. At bare minimum, you need to supply a vector of `image-magick` images. To demonstrate the full capabilities of `blotbench`, I will show an example with both row and column annotation.

Our experiment consisted of cells exposed to a drug (erdafitinib --- an FGFR inhibitor) at several timepoints. We blotted for three proteins --- TRAIL, PARP, and actin.

Here is our PARP blot:

#figure(
    kind: image,
    grid(
        columns: (2fr, 1fr),
        fill: luma(245),
        gutter: 1em,
        align:horizon,
        [```r
library(blotbench)
library(magick)
parp <- image_read(
  system.file("extdata", "parp.tif", package = "blotbench")
)
plot(parp)
        ```],
        image("figures/blotbench/parp.png")
    ),
    caption: [A raw image of a western blot of PARP]
)


After blotting for PARP, we probed the same blot again for TRAIL:

#figure(
    kind: image,
    grid(
        columns: (2fr, 1fr),
        fill: luma(245),
        gutter: 1em,
        align:horizon,
        [```r
trail <- image_read(
  system.file("extdata", "trail.tif", package = "blotbench")
)
plot(trail)
        ```],
        image("figures/blotbench/trail.png")
    ),
    caption: [A raw image of a western blot of PARP and TRAIL]
)

And finally for actin:

#figure(
    kind: image,
    grid(
        columns: (2fr, 1fr),
        fill: luma(245),
        gutter: 1em,
        align:horizon,
        [```r
actin <- image_read(
  system.file("extdata", "actin.tif", package = "blotbench")
)
plot(actin)
        ```],
        image("figures/blotbench/actin.png")
    ),
    caption: [A raw image of a western blot of PARP, TRAIL, and actin]
)

To make the column annotation, create a `data.frame` that has one row per lane in the blot. The columns should represent experimental conditions. The order of the rows should be the order of the columns _after image manipulation_. This is important, as these images are mirrored --- we'll flip them the right way once we get on to image manipulation.

```r
ca <- data.frame(
  drug = c("DMSO", "Erdafitinib", "Erdafitinib", "Erdafitinib"),
  time_hr = c(0, 24, 48, 72)
)
```

Row annotation can be supplied as a `data.frame` with just one column --- `name` --- or, much more simply, as a character vector, which is what we'll do here. The order should match the order of images.

With that, we have everything we need:

```r
wb <- wb(
  imgs = c(parp, trail, actin),
  col_annot = ca,
  row_annot = c("PARP", "TRAIL", "Actin")
)
```

=== Editing blots

Now that we have a blot object, we can call `wb_visual_edit` on it to help us generate code to transform out blots:


#figure(
    grid(
        columns: 3,
        image("figures/blotbench/shiny_init.png"),
        image("figures/blotbench/shiny_dropdown.png"),
    ),
    caption: [Some screenshots of the visual editor]
)


After editing your individual blots and clicking 'Done', the app will quit and the code to write the transformations will appear in your console:

```
Paste in your script to crop the images as seen in the app:
transforms(wb) <- tibble::tribble(
  ~width, ~height, ~xpos, ~ypos, ~rotate, ~flip,
    190L,     60L,   269,    51,    -0.5,  TRUE,
    190L,     50L,   238,   276,       0,  TRUE,
    190L,     30L,   283,   206,       0,  TRUE
  )
```

Doing so, we get:

```r
transforms(wb) <- tibble::tribble(
  ~width, ~height, ~xpos, ~ypos, ~rotate, ~flip,
    190L,     60L,   269,    51,    -0.5,  TRUE,
    190L,     50L,   238,   276,       0,  TRUE,
    190L,     30L,   283,   206,       0,  TRUE
  )
wb
```

```
imgs
# A tibble: 3 × 7
  format width height colorspace matte filesize density
  <chr>  <int>  <int> <chr>      <lgl>    <int> <chr>
1 TIFF     696    520 Gray       FALSE   728306 83x83
2 TIFF     696    520 Gray       FALSE   728306 83x83
3 TIFF     696    520 Gray       FALSE   728306 83x83

$col_annot
         drug time_hr
1        DMSO       0
2 Erdafitinib      24
3 Erdafitinib      48
4 Erdafitinib      72

$row_annot
   name
1  PARP
2 TRAIL
3 Actin

$transforms
# A tibble: 3 × 6
  width height  xpos  ypos rotate flip
  <int>  <int> <dbl> <dbl>  <dbl> <lgl>
1   190     60   269    51   -0.5 TRUE
2   190     50   238   276    0   TRUE
3   190     30   283   206    0   TRUE

attr(,"class")
[1] "wb"
```

Note that the transforms have not been *applied*: the `imgs` are still the width and height that they were before updating the transformations. This allows you to re--edit the blots if you so desire. The transformations can manually be applied using `apply_transforms`, but they are also automatically applied upon `wb_present`:

#figure(
    kind: image,
    grid(
        columns: (2fr, 1fr),
        align: left + horizon,
        gutter: 1em,
        fill: luma(245),
        [```r
wb_present(wb)
        ```],
        image("figures/blotbench/presented.png")
    ),
    caption: [Presented western blot, with transformations automatically applied]
)

If you want to exclude certain proteins, you can index by row just like a `data.frame`:

#figure(
    kind: image,
    grid(
        columns: (2fr, 1fr),
        align: left + horizon,
        gutter: 1em,
        fill: luma(245),
        [```r
wb_present(wb[-2, ])
        ```],
        image("figures/blotbench/presented_no-trail.png")
    ),
    caption: [Western blot with TRAIL removed through row indexing]
)

You can additionally select lanes as though they were columns:

#figure(
    kind: image,
    grid(
        columns: (2fr, 1fr),
        align: left + horizon,
        gutter: 1em,
        fill: luma(245),
        [```r
wb_present(wb[, 2:4])
        ```],
        image("figures/blotbench/presented_no-0.png")
    ),
    caption: [Western blot with 0hr timepoint removed through column indexing]
)

This workflow allows for a relatively painless way to link raw data to output figures. This also makes auditing simple: an outside investigator could be given the raw image and the code used to create the image and compare the output to the provided final blot.

== Conclusion
While this will not prevent fraud for those who wish to commit it, hopefully `blotbench` provides a simple mechanism for investigators to transparently show their editing processes. In future version of this application, an improved 'cropping' interface as well as the simultaneous display of all blots can be introduced. Hopefully these features can improve usability and --- in turn --- increase adoption.
