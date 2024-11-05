
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


#### Okay good, now let's try with a covariate ####

mu1 <- c(-3, -2, -1, 0)
mu2 <- c(-3, -2.5, -0.5, 0)

ranks2 <- matrix(nrow = surveys, ncol = length(mu1))

for(n in 1:surveys){
  if(n <= surveys/2){
    ranks2[n, ] <- rnorm(length(mu1), mu1) |> order(decreasing = T)
  } else{
    ranks2[n, ] <- rnorm(length(mu2), mu2) |> order(decreasing = T)
  }
}

colnames(ranks2) <- paste0("i", 1:4)
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
pairs_dat2 <- matrix(0, nrow = nrow(ranks2), ncol = choose(ncol(ranks2), 2))
for(i in 1:nrow(pairs_dat2)){
  for(j in 1:ncol(pairs_dat2)){
    if(ranks2[i, indexes[[j]][1]] < ranks2[i, indexes[[j]][2]]){
      pairs_dat2[i, j] <- 1
    }
  }
}

# give better names
colnames(pairs_dat2) <- c("i1i2", "i1i3", "i1i4", "i2i3", "i2i4", "i3i4")
pairs_dat2 <- as.data.frame(pairs_dat2)
pairs_dat2$grp <- as.factor(rep(c(1,2), each = surveys/2))


# specify model components
reg2 <- '
  i4 ~ 0 * 1 + mu4 * 1
  i1i2 ~ d12 * 1 + g12 * grp
  i1i3 ~ d13 * 1 + g13 * grp
  i1i4 ~ d14 * 1 + g14 * grp
  i2i3 ~ d23 * 1 + g23 * grp
  i2i4 ~ d24 * 1 + g24 * grp
  i3i4 ~ d34 * 1 + g34 * grp
'

# fix the factor loadings as pairwise differences
meas2 <- '
  i1 =~ 1 * i1i2 + 1 * i1i3 + 1 * i1i4
  i2 =~ -1 * i1i2 + 1 * i2i3 + 1 * i2i4 
  i3 =~ -1 * i1i3 + -1 * i2i3 + 1 * i3i4
  i4 =~ -1 * i1i4 + -1 * i2i4 + -1 * i3i4
'

covars2 <- '
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

derived2 <- '
  mu11 := sqrt(2) * d14
  mu21 := sqrt(2) * d24
  mu31 := sqrt(2) * d34
  b1 := sqrt(2) * g14
  b2 := sqrt(2) * g24
  b3 := sqrt(2) * g34
  mu12 := sqrt(2) * (d14 + g14)
  mu22 := sqrt(2) * (d24 + g24)
  mu32 := sqrt(2) * (d34 + g34)
'

# fit the model
mfit2 <- lavaan(
  model = c(reg2, meas2, covars2, derived2),
  data = pairs_dat2,
  ordered = names(pairs_dat2)[1:6],
  parameterization = "theta",
  meanstructure = TRUE,
  orthogonal = T,
  std.lv = T
)
summary(mfit2)



