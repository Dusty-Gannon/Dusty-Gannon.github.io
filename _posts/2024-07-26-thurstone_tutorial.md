---
layout: single
classes: wide
title:  "A tutorial on analyzing ranking data"
subtitle: "Casting Thurstone Case V models as SEMs"
date:   "July 2024"
categories: "Common issues"
usemathjax: true
toc: true
output:
  bookdown::github_document2:
    number_sections: false
    preserve_yaml: true
---

A tutorial on analyzing ranking data
================
July 2024

true

# Ranking data

Ranking data are common in survey-based research. Ranking data arise
from survey questions in which a respondent is asked to rank a set of
items by their priority or preference in the view of the respondent. I
have recently encountered this type of data in my consulting practice
and discovered that there is a relative paucity of approachable material
available on analyzing these data, particularly when the research
questions involve differences among populations of interest or
covariates that could drive different rankings. This post is meant to
act as a guide for graduate-level readers and above, with code for
fitting the popular Thurstone Case V model with the potential for
covariates using R package {% cite lavaan %}. I include some of the
mathematical details for interested readers, but I point to recently
developed R packages (shamelessly promoting one I am developing as well)
that do not require understanding of all the nuts and bolts.

> **Important note**: I am not a social scientist! I do not pretend to
> know or understand the human psychology and social science
> underpinning the development of these approaches. To any social
> scientists out there, please forgive any inaccuracies in that realm.

## The data structure

Ranking data generally come as a set of integers in response to a list
of items that a survey respondent is asked to rank in terms of
importance, priority, preference, etc. For this post, we will focus on
some example data (Table <a href="#tab:eg-data">1</a>) in which we
assume that 50 respondents were surveyed from 3 populations of interest.
To ground this example in the natural resources, assume that the
populations of interest are hikers, mountain bikers, and hunters in the
central Willamette Valley, OR. Each respondent is asked to rank the
items in a list of possible future projects in a local recreation area.
The list of items includes *trail maintenance* (of existing trails),
*trail construction* (building new trails), *invasive species
management*, and *forest thinning*. Assume for the purposes of this post
that the respondents answer honestly and that they constitute
representative samples of the populations of interest.

| Trail maintenance | Trail construction | Invasive species management | Forest thinning | Group  |
|------------------:|-------------------:|----------------------------:|----------------:|:-------|
|                 3 |                  2 |                           1 |               4 | hikers |
|                 3 |                  1 |                           2 |               4 | hikers |
|                 3 |                  1 |                           2 |               4 | hikers |
|                 3 |                  2 |                           1 |               4 | hikers |
|                 1 |                  2 |                           3 |               4 | hikers |
|                 3 |                  2 |                           1 |               4 | hikers |

<span id="tab:eg-data"></span>Table 1: Example dataset. Note that a
lower rank means higher priority or preference in this case.

Assume we have the following, seemingly straightforward research
question:

**Research question**: Do different user groups prefer different
management actions for the upcoming projects?

Addressing this question is trickier than it might seem on first glance.
These data are multivariate, since the measured unit is the respondent
and a respondent’s answer includes a set of four numbers, discrete, and
bounded on both ends (i.e., a rank of $$>4$$ or $$<1$$ is not possible).
Any one of these characteristics could complicate an analysis on its
own; now we get all of them at once!

# Analysis

Before we get into the approach this post is meant to introduce, let’s
consider some possible alternatives and their potential pitfalls. I only
include these considerations because I have seen these approaches used
in practice without recognition of the issues.

## Potential work-arounds?

### ANOVA?

In a simpler situation than our example above in which the question is
simply *is there a preference for some items over others*, it may be
tempting to make an appeal to the central limit theorem (CLT) and argue
that, despite the discrete nature of the data, the sampling distribution
of the mean rank should approach a normal distribution with large sample
sizes ($$n > 30$$?). Thus, perhaps one-way ANOVA may be appropriate,
treating each item as a group (*factor level* in the classical ANOVA
lingo) and testing the null hypothesis
$$H_0: \mu_1 = \mu_2 = \mu_3 = ... = \mu_K$$, where $$K$$ is the number
of items and $$\mu_k$$ is the mean rank of the $$k^\text{th}$$ item?
However, the first problem with this is that ranks from the same
respondent are not independent of one another. If I know that item 1 was
ranked first by respondent $$i$$, this gives me information about the
possible ranks of the remaining items ranked by respondent $$i$$. This
clearly violates the assumption of independent errors. Interestingly,
this will actually make the analysis overly conservative rather than
anti-conservative as is usually the case when the independence
assumption is violated. This is because the errors within a respondent
are *negatively* correlated, since, if I know item 1 is ranked with high
priority (i.e., ranked with a small number), then the remaining items
will be given lower priority (i.e., ranked with a large number). This
inverse relationship induced negative correlation among the errors
within a respondent.

### LMMs?

Indeed, an overly conservative analysis may not be much of a concern in
some cases. For example, if the goal is to inform policy or management
decisions, caution may be warranted. Alternatively, one may want
confidence intervals that are as tight as they can be and still be
valid. In this case, one may argue that we have tools to account for
correlated errors and that a linear mixed model with an unstructured
correlation matrix (see, for example, `?nlme::corStruct()` {% cite nlme
%}) to model the correlation of the errors within a respondent may be a
good option. Furthermore, one could concoct a model to address the
research question above using factors for the group to which the
respondent belongs and the item being ranked, as well as the interaction
between the two factors. This very well might be a reasonable approach,
*particularly if the sample sizes are large and the mean ranks don’t get
too close to the bounds of 1 and* $$K$$. Otherwise, due to the bounds on
the support of the response variable, residuals plots may commonly look
like Figure <a href="#fig:bad-resids"><strong>??</strong></a>, and an
appeal to the CLT may not be justified. **However**, there is one
additional problem with this approach that is more philosophical than it
is technically a statistical issue. Namely, is it really a good idea to
say that the difference between a rank of 1 and 2 is the same as the
difference between ranks 2 and 3? This is what we are implying by
treating the ranks as integer values in the approaches discussed thus
far, but I would argue that this seems to me to like it would rarely be
a good idea.

As an extreme example, consider the case where I am asked to rank the
foods ice cream (🍦), pie (🥧), and broccoli (🥦) in terms of what I
want for dessert tonight. If I give these items ranks $$\{1,2,3\}$$, is
it reasonable to think that my preference for ice cream over pie is of
the same magnitude as my preference for pie over broccoli!? Don’t get me
wrong, I love broccoli, but for dessert, pie and ice cream are *way*
better. The models discussed below handle all of these issues quite
elegantly.

## Thurstone’s model

Louis Leon Thurstone was an early pioneer in psychology and
psychometrics. He helped develop many analytical approaches still
commonly used in practice today, including factor analysis. In fact, the
Thurstone case V model that this post is about is a special case of
confirmatory factor analysis. Thurstone conceptualized his models
assuming that a person’s view or opinion of an item they are presented
with in a survey is on a continuum, a scale that he called the *utility
scale*. In other words, the item holds a certain *utility*[^1] to a
person that is not on a 1-5 or 1-10 integer scale as we often present in
a survey. Similarly, if the same item is presented to a population of
people, the utilities for these people should represent a distribution
of utilities.

Unfortunately, we have no way to measure the utility an item holds for a
person, but we can get a sense of utility distributions relative to one
another for a population of interest. We do this by asking a random
sample of respondents to rank a set of items in terms of the target of
the research (e.g., least to most preferred). The Thurstone models then
assume that, if a certain person is presented with items $$1,2,...,K$$,
then they will have a realized vector of utilities
$${\bf u} = (u_1, u_2, ..., u_K)^\top$$ that are draws from the utility
distributions (Figure <a href="#fig:concept-fig">1</a>). For brevity, I
will denote $${\bf U}$$ the random vector of utilities and denote
$$f_{U}({\bf u})$$ the joint probability density function. Now, assume
the respondent internally orders the elements of the vector $${\bf u}$$
in terms of the size, then responds with the rank orders. For example,
assume $$u_2 < u_1 < u_4 < u_3$$ (note that we need not worry about
equivalency because these are continuous random variables, so
$$P(u_j = u_k) = 0$$ for any $j \ne k$). With this ordering, the
response for items 1 – 4 would read as follows:

| item 1 | item 2 | item 3 | item 4 |
|-------:|-------:|-------:|-------:|
|      2 |      1 |      4 |      3 |

Figure <a href="#fig:concept-fig">1</a> depicts this scenario. Notice
how the spacing between the elements of $$\bf u$$ is not reflected in
the rank data, only their order in terms of utility. So, how do we begin
to understand the spacing between the means of these utility
distributions?

<div class="figure" style="text-align: center">

<img src="../assets/images/thurstone_blog/densities_final.png" alt="Conceptual figure of the Thurstone model following the example given in the text." width="60%" />
<p class="caption">
<span id="fig:concept-fig"></span>Figure 1: Conceptual figure of the
Thurstone model following the example given in the text.
</p>

</div>

### Ranks as pairs

In order to fit Thurstone models, we transform the ranking data into
*pairs data* by listing all possible pairs of items, which is
$$K\choose{2}$$ for $$K$$ items. The new variables take the form

$$
y_{i,jk} = \begin{cases}
1 &  r_j < r_k\\
0 & \text{otherwise}
\end{cases}
$$

where $$r_j$$ is the rank given to item $$j$$ such that $$y_{i,jk}$$ is
an indicator variable indicating whether respondent $$i$$ ranked item
$$j$$ before (as in a smaller integer, which could mean higher priority
depending on the question) item $$k$$. Thus, the mean of these
indicators, $${\bar y}_{jk} = \frac{1}{n}\sum_{i=1}^n y_{i,jk}$$, is an
estimator for

$$
P(R_j < R_k) = P(U_j < U_k) = P(U_j - U_k < 0)
$$

where I am using capital letters to distinguish these random variables
from *realizations* of the random variables as above. Notice here that
we side-step the issue of not being able to measure $${\bf u}$$ by
focusing on estimating the probability that a given item is ranked
before another. This probability depends on the *difference* between the
utilities rather than a measure of the utilities themselves. This also
gets us closer to estimating the quantities of interest; namely, the
probabilities of specific *rankings*, such as
$$P(U_2 < U_1 < U_4 < U_3)$$.

### The magic of normal

While transforming the rank data to pairs data got us closer to
estimating the probabilities of certain rankings, we can’t actually go
from paired probabilities, that is $$P(U_j < U_k)$$ for all pairs of
$$j \ne k$$, to the probability of a specific ordering of the elements
of $$\bf U$$ without knowing something more about the joint distribution
of the $$U$$’s, $$f_U({\bf u})$$.

If we assume we know that
$$f_U({\bf u}) \sim \mathcal{N}({\boldsymbol \mu}, {\boldsymbol \Sigma_u})$$,
this allows us to estimate the latent model based on the pairs data due
to the magical properties (🍄) of normal distributions. Namely, that if
the joint distribution of $$\bf U$$ is multivariate normal, then any
subset of the $$U$$’s is also (multivariate) normal. Thus, since the
pairs data can give us information on quantities like $$P(U_1 < U_2)$$,
we know this probability can be derived from the joint distribution as

$$
P(U_1 < U_2) = \int_{-\infty}^\infty \int_{-\infty}^{u_2} f_{U_1, U_2}(u_1, u_2\ |\ \mu_1, \mu_2, {\boldsymbol \Sigma}_{12})du_1 du_2
$$

where $$\boldsymbol \Sigma_{12}$$ is a $$2\times 2$$ matrix composed of
the first two rows and columns of the joint covariance matrix. This
integral can be simplified greatly by other convenient properties of
normals, such as the linear combination property[^2].

Assuming a joint normal distribution for $$\bf U$$ allows us to know the
distribution of any subset of the $$\bf U$$’s, but there are still more
assumptions we need to make in order to estimate the model from data.
Specifically, we need to fix one of the elements of the mean vector,
$$\boldsymbol \mu$$, somewhere along the utility axis. This is because
the pairs data can only give us information about how far apart the
means are from one another, not their absolution location. It is
therefore customary to fix the last element in $$\boldsymbol \mu$$ to
zero such that $$\mu_K = 0$$. This may seem like a slight-of-hand, but
recall that the utility axis is a construct, so absolute positions along
it are totally arbitrary anyway. All we actually care about are the
probabilities of certain rankings, which depend on the order of a random
vector $$\bf U$$ drawn from the joint distribution, which ultimately
depends on the spacing among the means (Figure
<a href="#fig:concept-fig">1</a>) and the covariance structure. For the
purposes of this post, I only discuss the model for which the utilities
are assumed independent with equal variance such that the covariance
matrix $$\boldsymbol \Sigma = \sigma^2{\bf I}_K$$, where ${\bf I}_K$ is
the $$K\times K$$ identity matrix. This is known as the *Thurstone Case
V* model, and is the simplest (but most constrained case due to the
constraints on the covariance matrix) {% cite thurstone1931 %}.

## Thurstone models as SEMs

Using the setup from above with the paired data to give information on
the relative distances among the means of the utility distributions, we
can represent Thurstone models as structural equation models (SEMs;
Figure <a href="#fig:sem">2</a>). The latent factors of the SEM are the
utilities, which we assume to have a multivariate normal distribution
with certain constraints. These utility distributions are measured by
the pairwise differences in their means, of which there are
$$K\choose 2$$ unique differences. If we let $$\bf A$$ be the design
matrix mapping a vector of means $$\boldsymbol \mu$$ to their pairwise
differences, we have the model

$$
{\boldsymbol \delta} = {\bf A} \boldsymbol\mu.
$$

As an example, the design matrix for our example with four items and
their respective population utility distributions, the design matrix
will take the form

$$
{\bf A} = \begin{bmatrix}
1 & -1 & 0 & 0\\
1 & 0 & -1 & 0\\
1 & 0 & 0 & -1\\
0 & 1 & -1 & 0\\
0 & 1 & 0 & -1\\
0 & 0 & 1 & -1\\
\end{bmatrix}
$$

with each row representing a difference between two of the means in the
vector of four. The vector of differences is then linked to the binary
pairs data,

$$
y_{ij} = \begin{cases}
1 & \text{if } u_i < u_j\\
0 & \text{otherwise}
\end{cases}
$$

through the [probit](https://en.wikipedia.org/wiki/Probit_model) link
function. Specifically, if we let

$$
{\bf z} = {\bf D}({\bf d} - {\boldsymbol \delta})
$$

be the standardized vector of a set of realized differences, $$\bf d$$,
with
$${\bf D} = \text{diag}({\bf A}{\boldsymbol \Sigma}{\bf A}^\top)^{-1/2}$$
as the diagonal matrix of the inverse standard deviations of the
differences, then the pairs data are related to the latent means through
what’s known as the *threshold relationship* {% cite
maydeu-olivares_SEM_2005 %}. Specifically,

$$
y_{ij} = \begin{cases}
1 & \text{if } z_{ij} \ge \tau_{ij}\\
0 & \text{if } z_{ij} < \tau_{ij}\\
\end{cases}
$$

where $${\boldsymbol \tau} = -{\bf DA}{\boldsymbol \mu}$$ is the vector
of thresholds.

As discussed above, the final component of formulating the Thurstone
Case V model as a SEM is to impose the constraints necessary for
identifiability. First, note that $$\bf A$$ is the factor loadings
matrix which is completely known in this case. Second, we need to
specify the variances and covariances of the latent factors (the
utilities), which, for the Case V model, we assume equal variances and
covariances equal to zero. Note that the exact value of the variances is
arbitrary since we can always find means, $$\mu_1, \mu_2, \mu_1'$$ and
$$\mu_2'$$ such that
$$P(X_1 < X_2 | \mu_1, \mu_2, \sigma_1^2) = P(Y_1 < Y_2 | \mu_1', \mu_2', \sigma_2^2)$$
for any specified $$\sigma_1^2$$ and $$\sigma_2^2$$ and
$$X_1, X_2, Y_1, Y_2$$ mutually independent. We therefore usually set
$$\sigma^2 = 1$$ for convenience. Finally, we need to fix one of the
latent means to some arbitrary value. As mentioned above, we usually set
$$\mu_K = 0$$, arbitrarily.

<div class="figure">

<img src="../assets/images/thurstone_blog/thurstone5_sem.png" alt="Path diagram of the Thurstone case V model cast as a SEM. All path coefficients from the latent means to the differences $$d_{ij}$$ are fixed at either 1 (black arrow) or -1, (red arrow). The exogenous variables, $$y_{ij}$$ are the pairs data, taking the value 1 if item $$i$$ was ranked ahead of item $$j$$ and 0 otherwise. These exogenous variables are linked to the latent differences through the probit link function, denoted $$\Phi()$$. The $$z_{ij}$$'s are the standardized latent differences." width="100%" />
<p class="caption">
<span id="fig:sem"></span>Figure 2: Path diagram of the Thurstone case V
model cast as a SEM. All path coefficients from the latent means to the
differences $$d_{ij}$$ are fixed at either 1 (black arrow) or -1, (red
arrow). The exogenous variables, $$y_{ij}$$ are the pairs data, taking
the value 1 if item $$i$$ was ranked ahead of item $$j$$ and 0
otherwise. These exogenous variables are linked to the latent
differences through the probit link function, denoted $$\Phi()$$. The
$$z_{ij}$$’s are the standardized latent differences.
</p>

</div>

# Fitting the model with `lavaan`

Okay, now that the model description is out of the way, let’s finally
learn how to fit this model in R! We will use the SEM software package
`lavaan` for this, which is very flexible and has many convenient
features. We will be using some infrequently used fitting options and
arguments, which is part of what prompted me to create this post. It
took me a while to figure out how to get `lavaan` to do what I wanted,
so I thought this might be helpful to others out there with ranking
data.

## Preparing the data

The first step to fitting this model is to prepare the data. For this,
we need to first convert the ranking data into pairs data. To do this, I
will use a custom function in a package I am developing called
`thurStEM` (you can find the code
[here](https://github.com/Dusty-Gannon/thurStEM) and download as a
package using `devtools::install_github()`).

``` r
library(tidyverse)
library(thurStEM)

head(rank_dat)
```

    ##   trail_maintenance new_trails invasives thinning  group
    ## 1                 3          2         1        4 hikers
    ## 2                 3          1         2        4 hikers
    ## 3                 3          1         2        4 hikers
    ## 4                 3          2         1        4 hikers
    ## 5                 1          2         3        4 hikers
    ## 6                 3          2         1        4 hikers

``` r
# convert to pairs data
pairs_dat <- ranks_as_pairs(rank_dat, cols = 1:4)

head(pairs_dat)
```

    ##   trail_maintenance_before_new_trails trail_maintenance_before_invasives
    ## 1                                   0                                  0
    ## 2                                   0                                  0
    ## 3                                   0                                  0
    ## 4                                   0                                  0
    ## 5                                   1                                  1
    ## 6                                   0                                  0
    ##   trail_maintenance_before_thinning new_trails_before_invasives
    ## 1                                 1                           0
    ## 2                                 1                           1
    ## 3                                 1                           1
    ## 4                                 1                           0
    ## 5                                 1                           1
    ## 6                                 1                           0
    ##   new_trails_before_thinning invasives_before_thinning  group
    ## 1                          1                         1 hikers
    ## 2                          1                         1 hikers
    ## 3                          1                         1 hikers
    ## 4                          1                         1 hikers
    ## 5                          1                         1 hikers
    ## 6                          1                         1 hikers

We can see how the function labels the new columns, which is meant to be
clear and informative, but for the sake of easier typing later, I’m
going to rename them.

``` r
pairs_dat <- pairs_dat %>% rename(
  i1i2 = trail_maintenance_before_new_trails,
  i1i3 = trail_maintenance_before_invasives,
  i1i4 = trail_maintenance_before_thinning,
  i2i3 = new_trails_before_invasives,
  i2i4 = new_trails_before_thinning,
  i3i4 = invasives_before_thinning
)
```

The next step is to convert the explanatory variable, `group`, into
something `lavaan` can work with, which is just converting the factor
into a matrix of indicator variables indicating if respondent $$i$$
belongs to group $$g$$. We will bind these indicator variables to the
pairs data for use with `lavaan`.

``` r
# create the dummy variables
X <- model.matrix(~ group, data = pairs_dat)
head(X)
```

    ##   (Intercept) grouphunters groupmtbikers
    ## 1           1            0             0
    ## 2           1            0             0
    ## 3           1            0             0
    ## 4           1            0             0
    ## 5           1            0             0
    ## 6           1            0             0

``` r
# bind the second and third columns to the data
pairs_dat <- pairs_dat %>%
  mutate(
    grp_hunt = X[, "grouphunters"],
    grp_bike = X[, "groupmtbikers"]
  )
```

Note that we did not bind the first column of the model matrix to the
data. The first column is the intercept, which represents the mean
latent vector $$\mu$$ when in the reference group (hikers in this case).
Including this in our data and model definition would lead to
identifiability issues.

The final thing we need to do to prepare the data is ensure that the
columns defining the binary pairs data are of class `"ordered"` so that
`lavaan` treats them as categorical and not numeric.

``` r
pairs_dat <- pairs_dat %>%
  mutate(
    across(i1i2:i3i4, .fns = as.ordered)
  )
```

## Fitting the model

We can now create the model definition using [`lavaan`
syntax](https://lavaan.ugent.be/tutorial/syntax1.html). As a first step,
let’s define the *regression* component in which the latent means are
modeled as a function of the grouping variable, `group`. The syntax here
is likely familiar to R users.

``` r
library(lavaan)
```

    ## This is lavaan 0.6-18
    ## lavaan is FREE software! Please report any bugs.

``` r
# notice the single quotes around all the model components
reg <- '
  item_1 ~ 1 + grp_hunt + grp_bike
  item_2 ~ 1 + grp_hunt + grp_bike
  item_3 ~ 1 + grp_hunt + grp_bike
  item_4 ~ 0 * 1
'
```

The `grp_hunt` and `grp_bike` variables are the indicator variables we
created above while we can name the latent variables whatever we like. I
chose `item_k` to keep the terminology consistent. Notice that we
include the `~ 1` terminology to specify the intercept, and
*premultiply* it by 0 in the last line to constrain the mean of the
utility distribution of `item_4` to zero. Note this constraint applies
regardless of the group since the group definitions should just affect
the spacing among the latent means.

The next step is to define the *indicator* section (not to be confused
with indicator variables), which specifies how the latent variables are
measured. In our case, they are measured by the pairs data with specific
constraints on the factor loadings. Constraints can be placed on nearly
any `lavaan` model component by premultiplying it by the constraint.
Here, we set the constraints on the factor loadings based on the design
matrix $$\bf A$$.

``` r
meas <- '
  item_1 =~ 1 * i1i2 + 1 * i1i3 + 1 * i1i4
  item_2 =~ -1 * i1i2 + 1 * i2i3 + 1 * i2i4
  item_3 =~ -1 * i1i3 + -1 * i2i3 + 1 * i3i4
  item_4 =~ -1 * i1i4 + -1 * i2i4 + -1 * i3i4
'
```

This model block defines the factor loadings based on the columns of
$$\bf A$$, and reflects the structure of Figure
<a href="#fig:sem">2</a>. Omitting the loadings with constraints to zero
as I have done here is the same as explicitly constraining them to zero
in the model definition.

Finally, we can place the necessary constraints on the (co)variances,
and fit the model. This is done using the `~~` syntax in `lavaan`.

``` r
covars <- '
  # constrain variances to one
  # the final item has zero variance since it is fixed to zero
  item_1 ~~ 1 * item_1
  item_2 ~~ 1 * item_2
  item_3 ~~ 1 * item_3
  item_4 ~~ 0 * item_4
  
  # now constrain the covariances to zero
  item_1 ~~ 0 * item_2
  item_1 ~~ 0 * item_3
  item_1 ~~ 0 * item_4
  item_2 ~~ 0 * item_3
  item_2 ~~ 0 * item_4
  item_3 ~~ 0 * item_4
'
```

We can now fit the model using the `lavaan()` function, being sure to
include a couple of somewhat obscure flags and arguments. Specifically,
we need to use the `ordered` argument to tell `lavaan` that the pairs
data are ordinal variables and not numeric, and we need to specify that
we want to estimate the mean structure of the latent variables by
setting the `meanstructure` argument to `TRUE`.

``` r
mfit <- lavaan(
  model = c(reg, meas, covars),
  data = pairs_dat,
  int.lv.free = T,
  ordered = names(pairs_dat)[1:6],
  parameterization = "theta",
  meanstructure = T
)
```

## Interpretting the fitted model

## References

{% bibliography -f references_ranking_data_blog.bib %}

[^1]: *Utility* seems very, well, utilitarian to me. I would suggest
    that *value* might be better terminology for this day and age.

[^2]: Suppose we have a multivariate normal distribution with mean
    $${\boldsymbol \mu}$$ and variance $$\boldsymbol \Sigma$$. Then any
    linear combination $${\bf c}$$ of the component distributions will
    be normal with mean $${\bf c}^\top {\boldsymbol \mu}$$ and variance
    $${\bf c}^\top {\boldsymbol \Sigma} {\bf c}$$
