= Documentation

#figure(
    image("figures/documentation/logo.png", width: 40pt),
    caption: [The hex logo for our documentation]
)

== Problem
When I first joined the McConkey lab, protocols existed either as printed papers or in a large binder. This has advantages: being able to write on protocols, as well as being able to take protocols into places where an electronic device might not fit --- for instance, taped to a fume hood. However, it comes with disadvantages. Paper can become damaged or lost, and in several cases there were 'good' copies with notes, amendments, or differences from the other copies. Additionally, many things were not documented as they might have not made sense as a full--fledged protocol, but were still important knowledge that became 'implicit'. Finally, making the protocols we use in the lab open access allows for greater reproducibility and accountability.

== Solution
I created a publicly available repository of protocols at #link("https://kai.quarto.pub/bok"). Of the solutions I will present, creating documentation has had the highest impact within our lab, indicating that computational solutions need not be cutting--edge to be helpful.

Some advantages of this approach include the ability to cross--reference and search information, so protocols could be kept brief but still provide prerequisite information a link away, if needed. This also reduces redundancy. For example, the mycoplasma testing protocol need not recount how to split cells, but references it with a link for those who need to refresh their memory. Additionally, this allows like--information to be listed alongside the sought information, allowing users to stumble upon pertinent protocols and information.

This also encouraged the writing of 'protocol adjacent' information that was needed for the lab. For instance, diluting liquids is a frequent pain point for new members in the lab. I wrote a chapter on how to calculate dilutions, as well as the practical aspects of it (eg pipetting less than 1μL of volume is tricky --- best scale up). This chapter can serve as a reference for both mentees within and outside of our lab. Maintaining a stable repository of institutional knowledge is important in cases where new students are frequent and/or mentor time is limited.

I wrote the documentation in a Markdown--like language called Quarto, with the end goal of creating something that many students could contribute to. Markdown is an incredibly simple syntax that most users have already come across, though they may not know it by that name. Commonmark --- a type (also known as 'flavor') of Markdown --- has an incredibly gentle introduction that can be completed in the span of ten minutes. As most of the document is prose, rather than code, most contributors would not have to interact with the more technical aspects of Quarto.

In concert, these aspects have made thorough electronic documentation an incredibly useful piece of infrastructure for our lab, and continues to be my highest--yield endeavor.

== Limitations
Contributing to the documentation is non--trivial. While the language that produces the documents (Quarto, a markdown--like language) is fairly simple, there is still a significant barrier to entry for a lab member not familiar with code. An investigator who has no code experience must --- at the very least --- create a GitHub account and figure out how to modify the script to their liking. Pressed for time and with the lack of incentive and motivation to learn how, it is not particularly mysterious as to why contributions were rare.

Some attempts have been made to combat this. The first is by accepting contributions in a variety of formats. I told users --- both in person as well as in the contributions section --- that if they were able to email me or otherwise send me some version of their protocol or section, I could transcribe it and add it to the documentation myself. This allowed for a few contributions that would have not otherwise been made.

Another attempted solution was by created a wiki. One of the advantages of a wiki is an editor that allows rapid, visual, _in situ_ editing. However, this experiment was met with very little adoption. Data showing if and when users have attempted to log in to the wiki show that only 2/7 users have ever logged in once, and none have edited. This implies that it was not the content or structure of the wiki, but possibly due to lack of interest, motivation, or need.

== Conclusions
Despite low levels of contribution, documentation has appeared to be a large source of benefit for members of the lab, with high levels of adoption.
