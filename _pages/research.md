---
permalink: /_pages/research
layout: single
classes: wide
toc: true
usemathjax: true
---

## Bayesian learning methods for time series modeling

Long-term data collection on ecological systems can help to illuminate how a system evolves through time with both internal mechanisms (e.g., competition between species or predation) and in response to external perturbations (e.g., anthropogenic disturbance). Long-term ecological (LTE) data is also critically important for projecting future states of a system with climate change, landscape conversion, and management efforts. While the recognition of the utility of LTE data is widespread, we are still in early stages of processing and analyzing the accumulating data, and modeling techniques continue to evolve. For this project, we are interested in exploring the utility of Bayesian regularization and unsupervised learning techniques in the analysis of LTE data with different goals in mind. These goals include:

  1. **Feature selection**: Time series analysis often begins with a series of steps to *detrend* and remove seasonal cycles in the data in order to construct a stationary time-series. This process inevitably introduces some subjectivity since the researcher must decide which long lags to subtract to remove seasonality and which short lags to keep to yield a stationary time series. However, seasonal time series can also be described using an AR($$p$$) model with \(p \to \infty\) and a sparse vector of AR coefficients \(\boldsymbol \phi\). Thus, given a sufficiently long time series, can we use Bayesian sparse learning techniques to fit the AR(\(p\)) model and bypass the differencing steps? This can also be extended to include arbitrarily many explanatory variables in the model.
  Feature selection may also be useful in a variety of ecological contexts. Using a community ecology example, there is mounting evidence to suggest that competitive communities can be effectively described with models that lie somewhere between a fully parameterized model with unique competition coefficients for each species and one in which all species share the same competitive effect, resulting in a single competition coefficient (e.g., [Skwara et al. 2023](https://doi.org/10.1111/2041-210X.14028)). Can we use unsupervised Bayesian learning techniques to efficiently collapse some competitive effects into a common, shared competition coefficient, while allowing estimates of different competitive effects for species that compete more strongly ([Weiss-Lehman et al. 2022](https://doi.org/10.1111/ele.13977)), and is there enough information in temporal fluctuations of species abundances to do so?
  
  2. **Forecasting**: Regularization / parameter ‘shrinkage’, or adding constraints to the model fitting procedure such that some regions of parameter space are penalized and some are favored, can help to protect against model overfitting, or fitting the model too closely to the observed data such that out-of-sample predictions are poor. Most Bayesian learning techniques include strongly informative prior distributions that favor parameter values close to zero. This can result in parameter shrinkage that may improve model forecasts of future states in time series, especially if the length of the observed time series is short and the data are noisy, making overfitting more likely.
  

  