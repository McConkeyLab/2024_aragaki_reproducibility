#import "thesis-template.typ": thesis
#show: doc => thesis(
    [Laboratory Development Operations],
    [A case (study) for bespoke software],
    [Adam "Kai" Aragaki],
    doc
)

#show raw.where(block: true): block.with(
    fill: luma(245),
    width: 100%,
  inset: 10pt
)

#include "intro.typ"
#pagebreak()
#include "overview.typ"
#pagebreak()
#include "documentation.typ"
#pagebreak()
#include "blotbench.typ"
#pagebreak()
#include "amplify-plan-pcr.typ"
#pagebreak()
#include "gplate.typ"
#pagebreak()
#include "mop.typ"
#pagebreak()
#include "ergonomics-of-existing-software.typ"

#bibliography("sources.bib", style: "nature")
