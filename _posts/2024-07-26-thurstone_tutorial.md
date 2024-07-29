---
layout: single
classes: wide
title:  "A tutorial on analyzing ranking data"
subtitle: "Casting Thurstone Case V models as SEMs"
date:   "July 2024"
categories: Common issues
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
covariates using R package `lavaan` {% cite lavaan %}. I include some of
the mathematical details for interested readers, but I point to recently
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
|                 3 |                  1 |                           2 |               4 | hikers |
|                 1 |                  3 |                           2 |               4 | hikers |
|                 1 |                  3 |                           2 |               4 | hikers |

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
tempting to make an appeal to the central limit theorem and argue that,
despite the discrete nature of the data, the sampling distribution of
the mean rank should approach a normal distribution with large sample
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
correlation matrix (see, for example, `?nlme::corStruct()`)

## References

{% bibliography –file references_ranking_data_blog.bib %}
