
set.seed(5663)
mu <- c(-3, -2, -1, 0)

ranks <- sapply(
  1:100,
  function(x){
    s <- rnorm(length(mu), mean = mu)
    return(order(s))
  }
) |> t()

# give names
colnames(ranks) <- paste0("i", 1:4)
# create indexes
indexes <- list()
for(i in 1:(ncol(ranks) - 1)){
  for(j in (i+1):ncol(ranks)){
    indexes <- c(
      indexes,
      list(c(i, j))
    )
  }
}

# convert to pairs data
pairs_dat <- matrix(0, nrow = nrow(ranks), ncol = choose(ncol(ranks), 2))
for(i in 1:nrow(pairs_dat)){
  for(j in 1:ncol(pairs_dat)){
    if(ranks[i, indexes[[j]][1]] < ranks[i, indexes[[j]][2]]){
      pairs_dat[i, j] <- 1
    }
  }
}

# give better names
colnames(pairs_dat) <- c("i1i2", "i1i3", "i1i4", "i2i3", "i2i4", "i3i4")
pairs_dat <- as.data.frame(pairs_dat)


# specify model components
reg <- '
  i1 ~ mu1 * 1
  i2 ~ mu2 * 1
  i3 ~ mu3 * 1
  i4 ~ 0 * 1 + mu4 * 1
  i1i2 ~ d12 * 1
  i1i3 ~ d13 * 1
  i1i4 ~ d14 * 1
  i2i3 ~ d23 * 1
  i2i4 ~ d24 * 1
  i3i4 ~ d34 * 1
'
# fix the factor loadings as pairwise differences
meas <- '
  i1 =~ 1 * i1i2 + 1 * i1i3 + 1 * i1i4
  i2 =~ -1 * i1i2 + 1 * i2i3 + 1 * i2i4 
  i3 =~ -1 * i1i3 + -1 * i2i3 + 1 * i3i4
  i4 =~ -1 * i1i4 + -1 * i2i4 + -1 * i3i4
'

covars <- '
  # residual variances constrained
  i1i2 ~~ 0 * i1i2
  i1i3 ~~ 0 * i1i3
  i1i4 ~~ 0 * i1i4
  i2i3 ~~ 0 * i2i3
  i2i4 ~~ 0 * i2i4
  i3i4 ~~ 0 * i3i4
'

contr <- '
  d12 == mu1 - mu2
  d13 == mu1 - mu3
  d14 == mu1 - mu4
  d23 == mu2 - mu3
  d24 == mu2 - mu4
  d34 == mu3 - mu4
'

# fit the model
mfit <- lavaan(
  model = c(reg, meas, covars, contr),
  data = pairs_dat,
  ordered = names(pairs_dat)[1:6],
  parameterization = "theta",
  meanstructure = T,
  orthogonal = T,
  std.lv = T
)

