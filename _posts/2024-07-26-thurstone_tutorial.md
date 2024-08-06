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
|                 3 |                  1 |                           2 |               4 | hikers |
|                 3 |                  2 |                           1 |               4 | hikers |
|                 3 |                  1 |                           4 |               2 | hikers |
|                 1 |                  3 |                           2 |               4 | hikers |
|                 1 |                  3 |                           4 |               2 | hikers |
|                 3 |                  1 |                           2 |               4 | hikers |

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

## Ranks as pairs

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

## The magic of normal

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
P(U_1 < U_2) = \int_{u_1}^\infty \int_{-\infty}^{u_1} \int_{-\infty}^\infty \int_{-\infty}^\infty f_U({\bf u})du_3 du_4du_1 du_2
$$ which can be simplified greatly by other convenient properties of
normals, such as the linear combination property[^2]

## References

{% bibliography -f references_ranking_data_blog.bib %}

[^1]: *Utility* seems very, well, utilitarian to me. I would suggest
    that *value* might be better terminology for this day and age.

[^2]: Suppose we have a multivariate normal distribution with mean
    $${\boldsymbol \mu}$$ and variance $$\boldsymbol \Sigma$$. Then any
    linear combination $${\bf c}$$ of the component distributions will
    be normal with mean $${\bf c}^\top {\boldsymbol \mu}$$ and variance
    $${\bf c}^\top {\boldsymbol \Sigma} {\bf c}$$
