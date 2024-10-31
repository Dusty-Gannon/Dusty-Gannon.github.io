
set.seed(5663)
mu <- c(-3, -2, -1, 0)

surveys <- 1000

ranks <- sapply(
  1:surveys,
  function(x){
    s <- rnorm(length(mu), mean = mu)
    return(order(s, decreasing = T))
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


A <- rbind(
  c(1,-1,0,0),
  c(1,0,-1,0),
  c(1,0,0,-1),
  c(0,1,-1,0),
  c(0,1,0,-1),
  c(0,0,1,-1)
)

mu_star <- A%*%mu 
Sig_ystar <- A %*% t(A)
D <- diag(Sig_ystar)^(-0.5) |> diag()
P <- D %*% Sig_ystar %*% D

thresh <- -D %*% mu_star

colMeans(pairs_dat)
1 - pnorm(thresh)

# specify model components
reg <- '
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
  i1 ~~ 1 * i1
  i2 ~~ 1 * i2
  i3 ~~ 1 * i3
  i4 ~~ 1 * i4
  i1i2 ~~ 2 * i1i2
  i1i3 ~~ 2 * i1i3
  i1i4 ~~ 2 * i1i4
  i2i3 ~~ 2 * i2i3
  i2i4 ~~ 2 * i2i4
  i3i4 ~~ 2 * i3i4
'

derived <- '
  mu1 := sqrt(2) * d14
  mu2 := sqrt(2) * d24
  mu3 := sqrt(2) * d34
'


# fit the model
library(lavaan)
mfit <- lavaan(
  model = c(reg, meas, covars, derived),
  data = pairs_dat,
  ordered = names(pairs_dat)[1:6],
  parameterization = "theta",
  meanstructure = TRUE,
  orthogonal = T,
  std.lv = T
)
summary(mfit)
