#import "@preview/cetz:0.3.0"
#import "@preview/fletcher:0.5.2" as fletcher: diagram, node, edge
= Overview
I developed packages on an as-needed basis, typically 'incubating' as a small set of functions in a generic lab package (`bladdr`) before growing them out into a standalone package. This was the case for packages like `qp`, `amplify`, and `ezmtt` Sometimes, patterns would appear in these packages that would warrant a separate 'backend' package, which created packages like `gplate` and `mop`. Still some other packages were created without any direct connection to the network of packages, and were motivated by the needs of current research - like `tidyestimate`, `reclanc`, and `classifyBLCA`.

#figure(
    diagram(
        label-size: 8pt,
        node((0,0), [#image("figures/gplate/logo.png", width: 30pt)]),
        edge((0,0), (1,0), "->"),
        edge((0,0), (0,1), "->"),
        edge((0,0), (1,1), "->"),
        node((1,0), [`mop`]),
        edge((1,0), (0,1), "->"),
        edge((1,0), (1,1), "->"),
        edge((1,0), (2,1), "->"),
        node((0,1), [#image("figures/amplify/amplify-logo.png", width: 30pt)]),
        edge((0,1), (0,2), "->"),
        node((1,1), [#image("figures/qp/logo.png", width: 30pt)]),
        edge((1,1), (1,2), "->"),
        node((2,1), [`ezmtt`]),
        node((0,2), [#image("figures/amplify/plan-pcr-logo.png", width: 30pt)]),
        node((1,2), [`qp_shiny`]),
    ),
    caption: [Dependency graph of selected packages]
)

All of these packages exist on a continuum of audience specificity. Some packages or apps are useful only to the members of the lab, as it is tailored to a specific protocol; others are more broadly applicable. One side of the gradient is not necessarily better than the other: large frameworks provide a solid foundation for more rapid future development, while not doing anything on their own. Specific packages and apps may not impact wide swaths of the scientific endeavor, but the users they do help - particularly those who are less familiar with code - are able to get things done.

#let hexagon(w, x, y, label) = {
    let z = w/(4 * calc.cos(calc.pi / 6))
    cetz.draw.line(
        (x + (w/2), y + z),
        (x + (w/2), y - z),
        (x, y - z*2),
        (x - (w/2), y - z),
        (x - (w/2), y + z),
        (x, y + z*2),
        close: true,
        fill: white
    )
    cetz.draw.content((x, y), label)
}
#[
    #set par(leading: 0.5em)
    #set text(8pt)
    #figure(
        cetz.canvas({
            import cetz.draw: *
            let amplify = [#image("figures/amplify/amplify-logo.png", width: 30pt)]
            let planpcr = [#image("figures/amplify/plan-pcr-logo.png", width: 30pt)]
            let gplate = [#image("figures/gplate/logo.png", width: 30pt)]
            let qp = [#image("figures/qp/logo.png", width: 30pt)]
            let tidyestimate = [#image("figures/tidyestimate/logo.png", width: 30pt)]
            let bok = [#image("figures/documentation/logo.png", width: 30pt)]
            let cellebrate = [#image("figures/cellebrate/logo.png", width: 30pt)]
            let bladdr = [#image("figures/bladdr/logo.png", width: 30pt)]
            let thermos = [#image("figures/thermos/logo.png", width: 30pt)]
            line((0,-2), (0,0), stroke: (dash: "dashed"))
            hexagon(1,0,-2, "reclanc")
            line((1,2), (1,0), stroke: (dash: "dashed"))
            content((1,2), gplate)
            line((1.5,-2), (1.5,0), stroke: (dash: "dashed"))
            content((1.5,-2), tidyestimate)
            line((2,2), (2,0), stroke: (dash: "dashed"))
            hexagon(1,2,2, "blot\nbench")
            line((4,2), (4,0), stroke: (dash: "dashed"))
            hexagon(1,4,2, "mop")
            line((3.5,-2), (3.5,0), stroke: (dash: "dashed"))
            content((3.5,-2), thermos)
            line((6,2), (6,0), stroke: (dash: "dashed"))
            hexagon(1,6,2, "classify\nBLCA")
            line((7,-2), (7,0), stroke: (dash: "dashed"))
            content((7,-2), cellebrate)
            line((10,2), (10,0), stroke: (dash: "dashed"))
            content((10,2), amplify)
            line((9.5,-2), (9.5,0), stroke: (dash: "dashed"))
            content((9.5,-2), qp)
            line((11,2), (11,0), stroke: (dash: "dashed"))
            content((11,2), bladdr)
            line((13,-2), (13,0), stroke: (dash: "dashed"))
            hexagon(1,13,-2, "qp\nshiny")
            line((13.5,2), (13.5,0), stroke: (dash: "dashed"))
            hexagon(1,13.5,2, "ezmtt")
            line((14,-2), (14,0), stroke: (dash: "dashed"))
            content((14,-2), bok)
            line((15,-2), (15,0), stroke: (dash: "dashed"))
            content((15,-2), planpcr)
            content((0, 0.3), [General])
            content((7.5, 0.3), [Domain specific])
            content((15, 0.3), [Lab/protocol specific])
            set-style(mark: (symbol: ">"))
            line((-1, 0), (16, 0))
        }),
        caption: [My packages placed pseudo-quantitatively on a gradient of specificity]
    )
]
