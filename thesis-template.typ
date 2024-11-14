// Assumes text is left-to-right
#let thesis(
    title,
    subtitle,
    name,
    doc,
    print: false,
    copyright: false,
    year: datetime.today().display("[year]"),
    month: datetime.today().display("[month repr:long]"),
    fontsize: 10pt
) = {
    assert(fontsize.pt() >= 10, message: "fontsize must be 10pt or greater")
    let captionsize = fontsize - 2pt
    assert(captionsize.pt() >= 8, message: "caption must be 8pt or greater")
    set par(
        leading: 1em,
        justify: true
    )
    set text(fontsize, top-edge: 0.7em, bottom-edge: -0.3em)
    show footnote.entry: set text(captionsize)
    set page(
        paper: "us-letter",
        margin: if print {
            (inside: 1.5in, top: 1in, outside: 1in, bottom: 1in)
        } else {
            (1in)
        }
    )
    set align(center)
    v(0.5in)
    upper(title)
    linebreak()
    upper(subtitle)
    [
        #v(1fr)
    by \
    #name
    #v(1fr)
    A dissertation submitted to Johns Hopkins University in conformity with the requirements for the degree of Doctor of Philosophy
    #v(1fr)
    Baltimore, Maryland \
    #month, #year

        #if copyright [
            #v(1fr)
            #sym.copyright #year #name \
            All rights reserved
        ]
    ]
    v(0.5in)
    pagebreak()
    outline(indent: 2em)
    outline(
        indent: 2em,
        title: [Figures],
        target: figure.where(kind: image)
    )
    set page(numbering: "i")
    set align(left)
    doc
}
