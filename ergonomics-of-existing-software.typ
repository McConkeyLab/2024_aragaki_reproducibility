= Increasing Ergonomics and Accessibility of Existing Packages

== Problem
An excellent data product can be hampered by its ability to be used. In some instances, it is the interface of the product that makes it challenging to use: if a given application does not meld with the current workflows of the people using it, it may very well not be used at all. Other times, simply obtaining the data product is difficult --- sometimes impossible.

These parts of software have relatively little to do with their core functionality, but are _required_ for their use and therefore demand as careful consideration as developing core functionality.

== Solution
In this section, I present two case studies (`tidyestimate` and `reclanc`) in which I have made pre--existing software (`ESTIMATE` and `ClaNC`) both more usable and available.

=== `tidyestimate`
`ESTIMATE` is an excellent R package used to estimate stromal and immune infiltration within a tumor on a single--sample basis, which can be used to infer tumor purity@Yoshihara_2013. However, its usefulness is hampered by its relatively poor ergonomics and discoverability. The most common sources of R packages are from the Comprehensive R Archive Network (CRAN), Bioconductor, or GitHub; ESTIMATE does not exist on any of these and instead exists on R--forge #link("https://r-forge.r-project.org/") and thus suffered from low visibility. `ESTIMATE` also relies on a workflow that both ingested and returned external .GCT files. While these are used by some external programs, it is uncommon and often unnecessary for them to exist in a standard R workflow, where it is often more convenient to keep data as R objects in the environment. Because of this, in a typical workflow, the user would need to turn their output into a .GCT file exclusively for `ESTIMATE`, which would produce a .GCT file, which the user would then need to read back in for further analysis. Additionally, since a .GCT file has a header, care would need to be taken to skip the two header lines to read in properly. Further, `ESTIMATE` lacked documentation for its functions, making it difficult to know what inputs and outputs are expected. Finally, `ESTIMATE` is over 10 years old, and many of its identifiers used for its gene signatures go by different names or no longer exist.

==== Solution
Each issue listed is by no means insurmountable, but as a sum they create enough friction to prevent usage. I maintained the algorithmic core of `ESTIMATE` and wrapped it in a new package, `tidyestimate`.

The stage at which single-sample gene set enrichment analysis comes is typically after normalization of gene expression, usually performed by packages like `limma`, `DESeq2`, or `edgeR`, and existing as some form of matrix of expression or something easily coercible to this form. Therefore, `tidyestimate` takes in `data.frame`, `matrix`, or similar objects opposed to external files that `ESTIMATE` accepts. A file is a responsibility: it must have a reasonable place and a reasonable name, and it requires special consideration in regards to inter--user portability. If we can do without creating an external file, we should. For `ESTIMATE`, this responsibility felt unnecessarily self--inflicted and was circumvented in `tidyestimate`.

`tidyestimate` also creates functions that are 'pipe--able' --- that is, the output of previous functions can serve as the input of the next function, allowing them to be chained in a natural and common pattern.

`ESTIMATE` also had little to no documentation for its functions. `tidyestimate` adds documentation to make clear what the expected input and output is, as well as what each function is doing. In addition, `tidyestimate` adds a vignette to demonstrate how to use the package.

Gene symbols have changed over time, in part due to our updated understanding of the purpose of the genes, and other times to avoid coercion to dates by Excel. The `ESTIMATE` algorithm is sensitive to the presence and expression not only the genes within each of its stromal and immune signatures, but to a large list of roughly 10,000 genes that were common to a variety of array--based expression platforms. To ensure maximal compatibility between old and new datasets, an optional, conservative alias matching algorithm is supplied. In the original dataset supplied with `ESTIMATE`, 488 of the 10364 (~5%) of the genes used for `ESTIMATE` were out of date; alias matching allowed 461 out of 488 (~94%) to be updated and therefore recovered.

Finally, and most importantly, this package has been made available on CRAN (Comprehensive R Archive Network), the de--facto repository for R packages. This, along with its inclusion in the R Task View for Omics #link("https://cran.r-project.org/web/views/Omics.html"), has greatly increased its visibility and discoverability.

The impact of these small changes has been surprising. The package has been downloaded over 8,000 times, and has been cited in journals such as Nature Medicine@Acanda_De_La_Rocha_2024, Cancer Cell International@Zhang_2024, Cell Reports@Ghoshdastider_2023, BMC Cancer@Hao_2024, JCI Insight@Sharifi_2024, and others.

==== Conclusion
It can not be overstated that the vast majority of the work to create this package was done by the original authors. However, the additional benefit provided by `tidyestimate` has shown to provide a clear additional benefit. This underscores the importance of the 'softer' aspects of software ergonomics for increasing adoption.

=== `reclanc`
Despite lacking physical form, the internet is prone to 'rot'. Known as 'link--rot', in a study performed by Pew, vast swaths --- nearly 40% --- of content on the internet from as little as 10 years ago is no longer available@Pew_2024. `ClaNC` (Classification of microarrays to nearest centroids) was a victim of such rot. Although the paper describing ClaNC remains@Dabney_2005, the original source code is no longer available.

`ClaNC` was an R package that took expression data from pre--classified samples and generated centroids (collections of genes and their expression levels that are particular to a given class). These centroids could be used in turn to predict the class of additional samples. ClaNC differed from a similar centroid--based classifier PAM@Tibshirani_2002 (prediction analysis of microarrays) in ways that made it more sensitive and accurate, the details of which will be covered later in this section.

`ClaNC` was used by others in our field. Wanting to perform a similar but distinct analysis, I attempted to find the `ClaNC` software, but to no avail. The only place in which it could still incidentally be found was implemented in part of a larger pipeline known as `sake` #link("https://github.com/naikai/sake"). To revitalize `ClaNC`, I extracted it from `sake` to once again make it into stand--alone software, modernized it to fit within the current ecosystems of machine learning and bioinformatics in R, and created documentation.

==== Solution
`ClaNC`'s source was removed from `sake`. Dead code --- which referenced a now defunct graphical user interface (GUI) --- was removed, and code was rewritten to be more idiomatic. Significant attention was given to writing documentation. While previously there was no documentation for any of the functions, extensive documentation has been given for user facing functions, along with examples, a usage vignette, and a case study vignette. Additionally, an introductory 'theory of `ClaNC`' blog post was created to describe how `ClaNC` worked, rather than just how to use it, at an introductory level.

Beyond documentation, `ClaNC` was modernized to leverage the current machine learning ecosystem tooling. `ClaNC` used an internal resampling and hyper--parameter tuning algorithm, which were removed. This allows the user to use whatever method or package they would like to perform these tasks, and reduces the amount of code that need to be maintained within `reclanc`.

Finally, `reclanc` provides an additional prediction method that is correlation based, rather than distance based. This is particularly useful in cases where the scales of expression may be different from one another, such as in the case of cross--sequencing--platform classification and prediction.

===== Documentation
The paper associated with `ClaNC` was well written, but it was written with an expert audience in mind, particularly those with a stronger understanding of statistics. To assist users who might have less of a background in statistics in learning how `ClaNC` works, I wrote a less technical blog post helping to visually explain the process by which `ClaNC` both classified and predicted samples. This following description is an adaptation of that blog post.

====== What is classification, and why do it?
Classification, in essence, requires two steps:
1. Find the distinguishing features of each of the classes in your pre--labeled/clustered data (‘fitting’)
2. Use these distinguishing features to classify samples from other datasets that do not have these labels (‘predicting’)

Both of these steps provide utility.

For the first step, let's imagine you have tumors from cancer patients that responded to a drug and those that did not respond to a drug. We might use those as our ’labels’ for each class --- responders and non--responders. We could use a classifier to extract distinguishing features about each one of our classes. In the case of this package, these features refer to genes, and what distinguishes them from class to class is their expression levels. We can look at what features the classifier took and gain insight into the biology of these responders --- maybe even forming a hypothesis for the mechanism by which these responders respond. The extent which the features extracted represent anything useful depends on the intepretability of the model, of which `ClaNC` is highly interpretable.

The utility of the second step is more straightforward. If you want to apply the knowledge of a given subtype to a new set of data, classification is incredibly useful here. For instance, imagine you have developed a classifier that can help you predict whether a cancer patient will respond to a drug based on expression from their tumor. Being able to classify which class the new patients tumor falls into provides you with actionable information as to how to treat the patient.

(Aside: not all classifiers can classify new, single samples --- some require context of additional samples around them. However, `ClaNC` doesn't need this and can classify a single new sample (sometimes called a 'single sample classifier').)

====== What is ClaNC?

`ClaNC` both creates classifiers (fits) as well as uses the classifiers to assign new samples to a class (predicts). It is a nearest--centroid classifier. We'll get into the details later, but as a brief summary, it means it tries to find the average, distinguishing features of a given class (step 1), and then uses that average as a landmark to compare new samples to (step 2). Other nearest--centroid classifiers have existed (like, for instance, PAM), but `ClaNC` distinguishes itself by tending to be more accurate and sensitive than PAM.

====== How does it work?
======= Fitting
Our first step provides the algorithm with examples of what each class looks like so it can extract the features that distinguish one class from another. These 'examples' can come from some external phenotype (such as our responder/non--responder example from above) or from the data themselves (such as clusters from after doing, say, k--means clustering). Regardless, the input should be expression data that has been labeled with some kind of class (@sample_expression, left).


#figure(
    image("./figures/tidyestimate/clanc_hows-it-work_blog_01.svg"),
    caption: [*Left:* Our samples, colored by class, floating in N--dimensional space. *Right:* Each dimension separated from one another]
) <sample_expression>

The first assumption we make is that we can treat each gene independently. While this might not be exactly true in reality, it greatly simplifies the problem by allowing us to deal with each gene one at a time (@sample_expression, right). Despite this simplification, it also works pretty well.

#figure(
    image("./figures/tidyestimate/clanc_hows-it-work_blog_02.svg"),
    caption: [*Top left:* The expression of a gene for each given class, with class means denoted by m#sub([a]), m#sub([b]), and m#sub([c]), and the overall mean as m#sub([o]). *Top middle:* distances between the class and overall means. *Top right:* Pooled standard deviations are calculated for each gene. *Bottom:* dividing each class distance by the pooled standard deviation]
) <t_scores>

For each gene, we calculate the overall mean, as well as the mean within each class (@t_scores, top left). We then find the distance between each class mean and the overall mean (@t_scores, top middle) and the pooled standard deviation for the gene (@t_scores, top right). Dividing the distance by the pooled standard deviation, we get, essentially, a t--statistic.

We repeat this calculation for every gene (@ranked, top), then take the absolute value of each statistic (@ranked, bottom left) and rank them per--class (that is, each class has a #1, #2, etc) (@ranked, bottom right).

#figure(
    image("./figures/tidyestimate/clanc_hows-it-work_blog_03.svg"),
    caption: [*Top:* t--statistics for each class (color) and each gene (row). *Bottom left:* absolute value of the t--statistics. *Bottom right:* class--wise rank of absolute value t--statistics]
) <ranked>

One thing to note is what Dabney calls 'active genes'. An 'active gene' is a gene that has been selected to be a distinguishing feature for a given class. At the outset, you can select how many active genes you want per class (and it needn't be the same number of genes per class).

One thing that sets `ClaNC` apart from other nearest--centroid classifiers is that it only lets each gene be 'used' as a distinguishing feature once. That is, it cannot be used in multiple classes. Because of this, the classes 'compete' with one another to see who gets what gene. It's based on the class--rank of the gene (using the underlying absolute value t--statistic as a tie--breaker) as well as if a class needs more 'active genes' or if it already has all that it needs.

The game of gene selection goes like this:

1. Each class tries to select its highest rated gene. In the case of @selection, panel 1, every class gets its desired gene. These genes are then taken out of future rounds (since each gene can only be in one class, a restriction we mentioned above).
2. Classes continue to select their next highest rated gene, so long as there isn't and conflict (panel 2).
3. If a class can't get its next highest rated gene (in this case, blue can't get 3 because it's been taken by red in a previous round), then it chooses its next best available choice (all the way at 6 for blue) (panel 3)
4. If there's a tie, it is typically resolved by looking at the underlying t--statistics. Whichever class has the larger absolute t--statistic wins the gene. However, in this case, suppose we set each class to only want 3 active genes. In that case, both blue and green have met their quota, and red wins by default (panel 4).

#figure(
    image("./figures/tidyestimate/clanc_hows-it-work_blog_04.svg"),
    caption: [*1:* All classes select their top rated gene. *2:* Classes continue to select their next highest rated gene. *3:* Blue selects its next best rank since previous ranks were taken. *4:* Despite a tie, since number of active genes = 3, red wins.]
) <selection>

Once all genes have been selected, the rest are tossed --- they're unneeded for defining the centroid (@selection, gene 3). If a given class 'won' a gene, it uses its class mean as a value for that gene (@selection, colored means). Otherwise, it uses the overall mean (@selection, black means). The pooled standard deviations are also brought along. These are our centroids!

#figure(
    image("./figures/tidyestimate/clanc_hows-it-work_blog_05.svg"),
    caption: [Centroids, at long last.]
) <centroids>


======= Predicting
Now we have created our centroids, we might be interested in applying them to classify future samples of unknown class.

Suppose we have a new sample that we have expression data of (@new_samples, panel 1). The genes that are not included in the centroids will have no bearing on the classification, so we can remove them (this might be a feature: perhaps an inexpensive assay is developed that only measures the expression of the centroid genes) (panel 2).

======== Distance-based metric

For every class, and every gene in that class, find the distance between the class centroid's mean and the new sample's mean and square it (@new_samples panels 3, 4, 5; numerator) and divide by the pooled standard deviation we kept in our centroids (@new_samples panels 3, 4, 5; denominator).

#figure(
    image("./figures/tidyestimate/clanc_hows-it-work_blog_06.svg"),
    caption: [Calculating the distance between centroids and a new sample]
) <new_samples>

Let's think about these new statistics and what they mean. If the sample gene's expression is very close to a class's expression, the statistic will be very small (scaled by how much it tends to deviate --- we shouldn't punish expression from being far from the mean if it's fairly typical). If a sample is very similar to a given class, we expect all of these scores to be quite small. To this end, we take the sum of all the scores for a given class and compare the sums across all classes. The one with the smallest score is the most similar class, to which the sample gets assigned. Note that it makes sense to square the distance between the sample's expression and the centroid's expression, because we don't want a sample that is 'equally wrong on both sides' to average out and get flagged as very similar.


======== Correlation--based metric
The distance--based metric classification can fail, such as when samples are scaled differently or the expression comes from a different sequencing platform. Consider a particularly pathological example shown in @distance_fail, where the colored dots represent the training samples used to create our centroids, and the black dots represent new samples we want to classify. Despite our new samples showing three distinct clusters that appear to have a similar pattern to our training data clusters, they will all be called 'red' because it is the closest cluster.

#figure(
    image("./figures/tidyestimate/clanc_hows-it-work_blog_07.svg"),
    caption: [When distance metrics fail]
) <distance_fail>

One way around this is to look at the correlation between centroid expressions and the new sample's expression. If the centroid is related with the sample but for a difference in scaling, we expect a positive correlation between the two, such as shown between the unknown sample and the green centroid in @correlation.

#figure(
    image("./figures/tidyestimate/clanc_hows-it-work_blog_08.svg"),
    caption: [Classification through correlation]
) <correlation>

(For the sake of illustration, I've simplified the centroids to only use their class means for all genes, and don't consider anything about ‘winning’ genes --- the principle is the same though.)


===== Case Study
To provide a tangible and full--fledged exploration of the features of reclanc, I created a vignette showcasing how this package would be used on data 'in the wild'. This case study happened to be the analysis I set out to perform before learning of `ClaNC`'s disappearance.

====== Introduction
```r
library(reclanc)
library(aws.s3)
library(Biobase)
```

Let's consider a relatively full--featured, practical use case for `reclanc`. In this vignette, we'll go over the basics of fitting models, as well as how to leverage tidymodels to do more elaborate things like resampling and tuning hyperparameters. We'll fit a final model, then use that to predict subtypes of an entirely new dataset.

This vignette tries to assume very little knowledge about machine learning or `tidymodels`.

====== Fitting
======= A simple fit

Let's start with the fitting procedure. We first need gene expression data.

The data I'm using is from Sjödahl et al. (2012)@Sj_dahl_2012. It contains RNA expression from 308 bladder cancer tumors.

```r
lund <- s3readRDS("lund.rds", "reclanc-lund", region = "us-east-2")
lund
```

```
ExpressionSet (storageMode: lockedEnvironment)
assayData: 16940 features, 308 samples
  element names: exprs
protocolData: none
phenoData
  sampleNames: UC_0001_1 UC_0002_1 ... UC_0785_1 (308 total)
  varLabels: title source ... sample (16 total)
  varMetadata: labelDescription
featureData: none
experimentData: use 'experimentData(object)'
Annotation:
```

In their paper, Sjödahl et al. used the transcriptional data to classify the tumors into seven molecular subtypes (MS):

#raw(block: true, lang: "R", "table(lund$molecular_subtype)")

```
MS1a    MS1b  MS2a.1  MS2a.2  MS2b.1 MS2b2.1 MS2b2.2
  53      78      30      55      43      20      29
```

We'd like to apply this subtype framework to other datasets. To do this, we first need to generate centroids. Before we can begin, though, we need to convert our outcomes to factors. In this case, our outcomes are the molecular subtypes:

#raw(block: true, lang: "R", "lund$molecular_subtype <- factor(lund$molecular_subtype)")

In its simplest form, since `clanc` accepts `ExpressionSet` objects, we could do the following and be done with it:

#raw(block: true, lang: "R", "simple_centroids <- clanc(lund, classes = \u{22}molecular_subtype\u{22}, active = 5)
head(simple_centroids$centroids)")

```
  class    gene expression pooled_sd active     prior
1  MS1a   CXCL1   6.534490 0.8749133      5 0.1428571
2  MS1a     MMD   7.922508 0.6429620      5 0.1428571
3  MS1a C9orf19   8.378910 0.7510552      5 0.1428571
4  MS1a    BNC1   5.297095 0.2106762      5 0.1428571
5  MS1a  SLFN11   7.362887 0.6824663      5 0.1428571
6  MS1a    CRAT   6.004517 0.3425669      5 0.1428571
```

The problem with this method, though, is we have no idea if this is a good fit or not. active is an argument that specifies the number of genes that are used as distinguishing features for a given class. In this case, each class will find 5 genes that have expression patterns peculiar to that given molecular subtype, and each subtype will have 7 (the total number of subtypes) x 5 (number of active genes) = 35 genes in it (see my blog post or --- better yet --- the original paper for more details). Could we have gotten a better fit with more genes? Are we selecting more genes than we need? How would we know?

======= Setting the stage for more elaborate analyses
Before we can get started on tackling these larger questions, let's take a brief detour to the land of `tidymodels`. `tidymodels` is a collection of packages that make running and tuning algorithms like this much less painful and much more standardized.

In order to leverage `tidymodels`, we need to buy--in to their data structures.

(Aside: I don't mean to make the buy--in sound begrudging. When I say need, I really mean it: we're going to be specifying very long formulas, which for some reason R really, really hates. Emil Hvitfeldt recently (at time of writing) has allowed `tidymodels` to handle long formulas gracefully, so using `tidymodels` infrastructure is a gift, not a chore.)

#raw(block: true, lang: "R", "library(tidymodels)")

Many `tidymodels` workflows begin with a model specification. The rationale behind this is to separate the model specification step from the model fitting step (whereas in base R, they generally all happen at once). `reclanc` makes it easy to specify a model by adding a custom engine to `parsnip::discrim_linear`, so specifying a model looks like this:

#raw(block: true, lang: "R", "mod <- discrim_linear() |>
  set_engine(
    engine = \u{22}clanc\u{22}, # Note: \u{22}clanc\u{22}, not \u{22}reclanc\u{22}
    active = 5
  )")

This `mod` doesn't do anything --- and that's kind of the point: it only specifies the model we will later fit with, but doesn't do any fitting itself. This allows us to reuse the specification across our code.

The next step is to wrangle our data a bit to be in a 'wide' format, where all columns are outcomes (classes) and predictors (genes), and all rows are observations (samples):

#raw(block: true, lang: "R", "wrangled <- data.frame(class = lund$molecular_subtype, t(exprs(lund)))
head(wrangled[1:5])")

```
           class LOC23117   FCGR2B    TRIM44 C15orf39
UC_0001_1   MS1b 5.565262 5.306654  9.305053 6.430063
UC_0002_1 MS2b.1 5.505854 5.731128  9.242790 7.265748
UC_0003_1 MS2a.2 5.336140 5.540470  9.888668 7.244976
UC_0006_2 MS2b.1 5.576748 5.847743  9.408895 7.377358
UC_0007_1 MS2a.2 5.414919 5.510507 10.482469 6.435552
UC_0008_1 MS2b.1 5.279174 5.633093  9.112754 7.057977
```

Finally, we specify a formula for fitting the model. This uses the recipes package from `tidymodels`. While this is a delightful package that can help you preprocess your data, it's out of the scope of this vignette. Instead, just think of it as a way to specify a formula that keeps R from blowing up:

#raw(block: true, lang: "R", "# Note that the recipe requires 'template data'
recipe <- recipe(class ~ ., wrangled)")

We can bundle our model specification (mod) and our preprocessing steps (recipe, which is just a formula) into a workflow:

#raw(block: true, lang: "R", "wf <- workflow() |>
  add_recipe(recipe) |>
  add_model(mod)
wf")

#raw(block: true, "══ Workflow ════════════════════════════════════════════════════════════════════
Preprocessor: Recipe
Model: discrim_linear()

── Preprocessor ────────────────────────────────────────────────────────────────
0 Recipe Steps

── Model ───────────────────────────────────────────────────────────────────────
Linear Discriminant Model Specification (classification)

Engine-Specific Arguments:
  active = 5

Computational engine: clanc")

Now we can fit our model:

#raw(block: true, lang: "R", "tidymodels_fit <- fit(wf, data = wrangled)
head(extract_fit_parsnip(tidymodels_fit)$fit$centroids)")

```
  class    gene expression pooled_sd active     prior
1  MS1a   CXCL1   6.534490 0.8749133      5 0.1428571
2  MS1a     MMD   7.922508 0.6429620      5 0.1428571
3  MS1a C9orf19   8.378910 0.7510552      5 0.1428571
4  MS1a    BNC1   5.297095 0.2106762      5 0.1428571
5  MS1a  SLFN11   7.362887 0.6824663      5 0.1428571
6  MS1a    CRAT   6.004517 0.3425669      5 0.1428571
```

You'll notice that our results are the same as what we saw previously, demonstrating that while we're using tidymodels rather than base R, we're still doing the same thing.

======= Measuring fit accuracy with cross--validation
Now that we've dialed in to the `tidymodels` framework, we can do a lot of elaborate things with ease. One of our concerns is whether 5 active genes was a good choice (active = 5). A somewhat simple way to determine how good our choice of 5 genes is to use cross--validation. Cross--validation allows us to test how good our fit is by training our model on, say, 80% of our data, and testing it on the rest (see the Wikipedia diagram of a k--fold cross validation). This allows us to get a measure of how good our fit is, without having to break out our actual test data --- which in general should only be used when we're ready to finalize our model.

Speaking of test data, let's go ahead and split that off now. We'll lock our test data away and only use it once we've fit our final model. Until then, we'll use cross validation to assess how good the fit is, essentially using our training data as its own testing data.

Of course, `tidymodels` makes this easy too, by using `rsample::initial_split`:

#raw(block: true, lang: "R", "set.seed(123)
splits <- initial_split(wrangled, prop = 0.8, strata = class)
train <- training(splits)
test <- testing(splits)")

`train` and `test` are just subsets of the original data, containing 80% and 20% of the original data (respectively). It also tries to maintain the relative proportions of each of the classes within each of the datasets (because we set `strata = class`):

#raw(block: true, lang: "R", "round(prop.table(table(train$class)), 2)")

```
MS1a    MS1b  MS2a.1  MS2a.2  MS2b.1 MS2b2.1 MS2b2.2
0.17    0.25    0.10    0.18    0.15    0.07    0.08
```

#raw(block: true, lang: "R", "round(prop.table(table(test$class)), 2)")

```
MS1a    MS1b  MS2a.1  MS2a.2  MS2b.1 MS2b2.1 MS2b2.2
0.19    0.27    0.08    0.16    0.11    0.05    0.16
```

Creating folds for cross validation is nearly the same as `initial_split`:

#raw(block: true, lang: "R", "folds <- vfold_cv(train, v = 5, strata = class)
folds")

```
# 5-fold cross-validation using stratification
# A tibble: 5 × 2
  splits           id
  <list>           <chr>
1 <split [193/51]> Fold1
2 <split [193/51]> Fold2
3 <split [195/49]> Fold3
4 <split [197/47]> Fold4
5 <split [198/46]> Fold5
```

We can reuse our workflow `wf`, which contains our model and formula. The only difference is that we use `fit_resamples`, and we specify a metric we want to use to measure how good our fit is (remember that every fold has a chunk of data it uses to test the fit). For simplicity, let's use accuracy:

#raw(block: true, lang: "R", "fits <- fit_resamples(
  wf,
  folds,
  metrics = metric_set(accuracy)
)
fits")

```
35/35 (100%) genes in centroids found in data
35/35 (100%) genes in centroids found in data
35/35 (100%) genes in centroids found in data
35/35 (100%) genes in centroids found in data
35/35 (100%) genes in centroids found in data
# Resampling results
# 5-fold cross-validation using stratification
# A tibble: 5 × 4
  splits           id    .metrics         .notes
  <list>           <chr> <list>           <list>
1 <split [193/51]> Fold1 <tibble [1 × 4]> <tibble [0 × 3]>
2 <split [193/51]> Fold2 <tibble [1 × 4]> <tibble [0 × 3]>
3 <split [195/49]> Fold3 <tibble [1 × 4]> <tibble [0 × 3]>
4 <split [197/47]> Fold4 <tibble [1 × 4]> <tibble [0 × 3]>
5 <split [198/46]> Fold5 <tibble [1 × 4]> <tibble [0 × 3]>
```

We can then extract our accuracy metrics by using `collect_metrics`, which roots around in each of our fits and helpfully extracts the metrics, aggregates them, and calculated the standard error:

#raw(block: true, lang: "R", "metrics <- collect_metrics(fits)
metrics")


```
# A tibble: 1 × 6
  .metric  .estimator  mean     n std_err .config
  <chr>    <chr>      <dbl> <int>   <dbl> <chr>
1 accuracy multiclass 0.737     5  0.0289 Preprocessor1_Model1
```

Our model has an accuracy of about 74%. Applying this model to our testing data:

#raw(block: true, lang: "R", "# Fit a model using *all* of our training data
final_fit <- clanc(class ~ ., train, active = 5)

# Use it to predict the (known) classes of our test data
preds <- predict(final_fit, new_data = test, type = \u{22}class\u{22})
w_preds <- cbind(preds, test)
# Compare known class vs predicted class
metric <- accuracy(w_preds, class, .pred_class)
metric")

```
35/35 (100%) genes in centroids found in data
# A tibble: 1 × 3
  .metric  .estimator .estimate
  <chr>    <chr>          <dbl>
1 accuracy multiclass     0.734
```
Note that our testing data accuracy (%) approximates the training data accuracy (74%).
======= Tuning hyperparameters with tune
Now we at least have some measure of how good our model fits, but could it be better with more genes? Could we get away with fewer? Running the same command over and over again with different numbers is a drag --- fortunately, there's yet another beautiful package to help us: `tune`.

To use tune, we need to re--specify our model to let tune know what parameters we want to tune:

#raw(block: true, lang: "R", "tune_mod <- discrim_linear() |>
  set_engine(
    engine = \u{22}clanc\u{22},
    active = tune()
  )")

We could update our previous workflow using `update_model`, but let's just declare a new one:

#raw(block: true, lang: "R", "
tune_wf <- workflow() |>
  add_recipe(recipe) |>
  add_model(tune_mod)
")

We then have to specify a range of values of active to try:

#raw(block: true, lang: "R", "
values <- data.frame(active = seq(from = 1, to = 50, by = 4))
values
")

```
   active
1       1
2       5
3       9
4      13
5      17
6      21
7      25
8      29
9      33
10     37
11     41
12     45
13     49
```

We can then fit our folds using the spread of values we chose:

#raw(block: true, lang: "R", "# This is going to take some time, since we're fitting 5 folds 13 times each.
tuned <- tune_grid(
  tune_wf,
  folds,
  metrics = metric_set(accuracy),
  grid = values
)
tuned")

```
7/7 (100%) genes in centroids found in data
# Tuning results
# 5-fold cross-validation using stratification
# A tibble: 5 × 4
  splits           id    .metrics          .notes
  <list>           <chr> <list>            <list>
1 <split [193/51]> Fold1 <tibble [13 × 5]> <tibble [0 × 3]>
2 <split [193/51]> Fold2 <tibble [13 × 5]> <tibble [0 × 3]>
3 <split [195/49]> Fold3 <tibble [13 × 5]> <tibble [0 × 3]>
4 <split [197/47]> Fold4 <tibble [13 × 5]> <tibble [0 × 3]>
5 <split [198/46]> Fold5 <tibble [13 × 5]> <tibble [0 × 3]>
```

As before, we can collect our metrics --- this time, however, we have a summary of metrics for each of values for active:

#raw(block: true, lang: "R", "
tuned_metrics <- collect_metrics(tuned)
tuned_metrics
")

```
 # A tibble: 13 × 7
   active .metric  .estimator  mean     n std_err .config
    <dbl> <chr>    <chr>      <dbl> <int>   <dbl> <chr>
 1      1 accuracy multiclass 0.585     5  0.0368 Preprocessor1_Model01
 2      5 accuracy multiclass 0.737     5  0.0289 Preprocessor1_Model02
 3      9 accuracy multiclass 0.748     5  0.0496 Preprocessor1_Model03
 4     13 accuracy multiclass 0.781     5  0.0403 Preprocessor1_Model04
 5     17 accuracy multiclass 0.770     5  0.0280 Preprocessor1_Model05
 6     21 accuracy multiclass 0.774     5  0.0335 Preprocessor1_Model06
 7     25 accuracy multiclass 0.785     5  0.0378 Preprocessor1_Model07
 8     29 accuracy multiclass 0.794     5  0.0319 Preprocessor1_Model08
 9     33 accuracy multiclass 0.773     5  0.0281 Preprocessor1_Model09
10     37 accuracy multiclass 0.790     5  0.0295 Preprocessor1_Model10
11     41 accuracy multiclass 0.794     5  0.0339 Preprocessor1_Model11
12     45 accuracy multiclass 0.815     5  0.0267 Preprocessor1_Model12
13     49 accuracy multiclass 0.815     5  0.0277 Preprocessor1_Model13
```

Or graphically:

#raw(block: true, lang: "R", "ggplot(tuned_metrics, aes(active, mean)) +
  geom_line() +
  coord_cartesian(ylim = c(0, 1)) +
  labs(x = \u{22}Number Active Genes\u{22}, y = \u{22}Accuracy\u{22})")

It looks like we read maximal accuracy at around 21 genes --- let's choose 20 genes for a nice round number:

#raw(block: true, lang: "R", "
final_fit_tuned <- clanc(class ~ ., data = train, active = 20)
# Use it to predict the (known) classes of our test data:
preds <- predict(final_fit_tuned, new_data = test, type = \u{22}class\u{22})
w_preds <- cbind(preds, test)
# Compare known class vs predicted class:
metric <- accuracy(w_preds, class, .pred_class)
metric
")

```
140/140 (100%) genes in centroids found in data
# A tibble: 1 × 3
  .metric  .estimator .estimate
  <chr>    <chr>          <dbl>
1 accuracy multiclass     0.812
```

It looks like our accuracy is a little better now that we've chosen an optimal number of active genes.

====== Predicting

Now we want to apply our classifier to new data. Our second dataset is RNAseq data from 30 bladder cancer cell lines:

#raw(block: true, lang: "R", "library(cellebrate)
cell_rna")

```
class: DESeqDataSet
dim: 18548 30
metadata(1): version
assays(2): counts rlog_norm_counts
rownames(18548): TSPAN6 TNMD ... MT-ND5 MT-ND6
rowData names(0):
colnames(30): 1A6 253JP ... UC7 UC9
colData names(5): cell bsl lum call clade
```

Predicting is incredibly simple. Since we're using a different sequencing method (RNAseq vs array--based sequencing), it probably makes sense to use a correlation based classification rather than the original distance--based metric used in the original ClaNC package. We can do that by specifying `type = "numeric"` and then whatever correlation method we prefer.

#raw(block: true, lang: "R", "
cell_preds <- predict(
  final_fit_tuned,
  cell_rna,
  assay = 2,
  type = \u{22}numeric\u{22},
  method = \u{22}spearman\u{22}
)

out <- cbind(colData(cell_rna), cell_preds) |>
  as_tibble()

out
")

```
118/140 (84%) genes in centroids found in data
 # A tibble: 30 × 12
   cell     bsl    lum call  clade            .pred_MS1a .pred_MS1b .pred_MS2a.1
   <chr>  <dbl>  <dbl> <chr> <fct>                 <dbl>      <dbl>        <dbl>
 1 1A6     99.0   1.02 BSL   Epithelial Other     0.0600      0.224        0.149
 2 253JP   76.6  23.4  BSL   Unknown              0.0574      0.240        0.219
 3 5637    98.5   1.46 BSL   Epithelial Other     0.0958      0.243        0.160
 4 BV      49.9  50.1  LUM   Unknown              0.0758      0.262        0.238
 5 HT1197  56.0  44.0  BSL   Epithelial Other     0.119       0.288        0.224
 6 HT1376  10.9  89.1  LUM   Epithelial Other     0.100       0.277        0.238
 7 J82     98.1   1.91 BSL   Mesenchymal          0.127       0.292        0.219
 8 RT112    0   100    LUM   Luminal Papilla…     0.173       0.380        0.294
 9 RT4      0   100    LUM   Luminal Papilla…     0.134       0.317        0.257
10 RT4V6    0   100    LUM   Luminal Papilla…     0.143       0.207        0.165
# ℹ 20 more rows
# ℹ 4 more variables: .pred_MS2a.2 <dbl>, .pred_MS2b.1 <dbl>,
#   .pred_MS2b2.1 <dbl>, .pred_MS2b2.2 <dbl>
# ℹ Use `print(n = ...)` to see more rows
```

#raw(block: true, lang: "R", "
plotting_data <- out |>
  pivot_longer(cols = starts_with(\u{22}.pred\u{22}))

plotting_data |>
  ggplot(aes(cell, value, color = name)) +
  geom_point() +
facet_grid(~clade, scales = \u{22}free_x\u{22}, space = \u{22}free_x\u{22})
")

In the Sjödahl paper, the seven subtypes were simplified into five subtypes by merging some of the two that had similar biological pathways activated. To ease interpretation, we can do that too:

#raw(block: true, lang: "R", "
table <- plotting_data |>
  summarize(winner = name[which.max(value)], .by = c(cell, clade)) |>
  mutate(
    five = case_when(
      winner %in% c(\u{22}.pred_MS1a\u{22}, \u{22}.pred_MS1b\u{22}) ~ \u{22}Urobasal A\u{22},
      winner %in% c(\u{22}.pred_MS2a.1\u{22}, \u{22}.pred_MS2a.2\u{22}) ~ \u{22}Genomically unstable\u{22},
      winner == \u{22}.pred_MS2b.1\u{22} ~ \u{22}Infiltrated\u{22},
      winner == \u{22}.pred_MS2b2.1\u{22} ~ \u{22}Uro-B\u{22},
      winner == \u{22}.pred_MS2b2.2\u{22} ~ \u{22}SCC-like\u{22}
    )
  ) |>
  relocate(cell, five, clade)

print(table, n = 30)
")

```
 # A tibble: 30 × 4
   cell   five                 clade             winner
   <chr>  <chr>                <fct>             <chr>
 1 1A6    SCC-like             Epithelial Other  .pred_MS2b2.2
 2 253JP  SCC-like             Unknown           .pred_MS2b2.2
 3 5637   SCC-like             Epithelial Other  .pred_MS2b2.2
 4 BV     Urobasal A           Unknown           .pred_MS1b
 5 HT1197 SCC-like             Epithelial Other  .pred_MS2b2.2
 6 HT1376 SCC-like             Epithelial Other  .pred_MS2b2.2
 7 J82    Urobasal A           Mesenchymal       .pred_MS1b
 8 RT112  Urobasal A           Luminal Papillary .pred_MS1b
 9 RT4    Urobasal A           Luminal Papillary .pred_MS1b
10 RT4V6  Urobasal A           Luminal Papillary .pred_MS1b
11 SCaBER SCC-like             Epithelial Other  .pred_MS2b2.2
12 SW780  Urobasal A           Luminal Papillary .pred_MS1b
13 T24    SCC-like             Mesenchymal       .pred_MS2b2.2
14 TCCSup SCC-like             Mesenchymal       .pred_MS2b2.2
15 UC10   SCC-like             Epithelial Other  .pred_MS2b2.2
16 UC11   SCC-like             Mesenchymal       .pred_MS2b2.2
17 UC12   Urobasal A           Mesenchymal       .pred_MS1b
18 UC13   SCC-like             Mesenchymal       .pred_MS2b2.2
19 UC14   Urobasal A           Luminal Papillary .pred_MS1b
20 UC15   SCC-like             Epithelial Other  .pred_MS2b2.2
21 UC16   SCC-like             Epithelial Other  .pred_MS2b2.2
22 UC17   SCC-like             Luminal Papillary .pred_MS2b2.2
23 UC18   SCC-like             Mesenchymal       .pred_MS2b2.2
24 UC1    Urobasal A           Luminal Papillary .pred_MS1b
25 UC3    SCC-like             Mesenchymal       .pred_MS2b2.2
26 UC4    Urobasal A           Unknown           .pred_MS1b
27 UC5    Urobasal A           Luminal Papillary .pred_MS1b
28 UC6    Urobasal A           Luminal Papillary .pred_MS1b
29 UC7    Urobasal A           Epithelial Other  .pred_MS1b
30 UC9    Genomically unstable Epithelial Other  .pred_MS2a.1
```
