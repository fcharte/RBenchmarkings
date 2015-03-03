library(microbenchmark)
library(ggplot2)
library(compiler)
library(Rcpp)
library(inline)

# Generating a data.frame containing character data with and without stringsAsFactors
numElements <- 1e6
someStrings <- sapply(1:25, function(x) paste(sample(c(letters, LETTERS), 10, replace = TRUE), collapse = ""))

aNumericVector <- runif(numElements)
aStringVector <- sample(someStrings, numElements, replace = TRUE)
bStringVector <- sample(someStrings, numElements, replace = TRUE)

result <- microbenchmark(
  data.frame(aNumericVector, aStringVector, bStringVector, stringsAsFactors = TRUE),
  data.frame(aNumericVector, aStringVector, bStringVector, stringsAsFactors = FALSE)
)

levels(result$expr) <- c('stringsAsFactors=T', 'stringsAsFactors=F')
print(result, unit="relative")
autoplot(result)

# Growing list vs preallocated list vs lapply
numElements <- 1e4

result <- microbenchmark(
{ v1 <- list() ; for(i in 1:numElements) v1[[i]] <- someStrings },
{ v2 <- vector('list', numElements) ; for(i in 1:numElements) v2[[i]] <- someStrings },
{ v3 <- lapply(1:numElements, function(i) someStrings)}
)

levels(result$expr) <- c('Empty list', 'Preallocated list', 'lapply')
print(result, unit="relative")
autoplot(result)

# $ vs [[ operator
aList <- list( a = 5, b = 'list', c = list(c1 = 25))

result <- microbenchmark(
{ c(aList$a, aList$b, aList$c$c1) },
{ c(aList[[1]], aList[[2]], aList[[2]][[1]]) }
)

levels(result$expr) <- c('$ operator', '[[ operator')
print(result, unit="relative")
autoplot(result)

# Comparison of two vector values
fgen <- function() runif(numElements, 1, 10)
v <- fgen()
t <- fgen()

result <- microbenchmark(
{ for(i in 1:length(v)) if(v[i] > t[i]) v[i] <- 0 },
{ v <- mapply(function(a,b) if(a > b) 0 else a, v, t) },
{ v[which(v > t)] <- 0 },
{ v[v > t] <- 0 },
{ v <- ifelse(v > t, 0, v) }
)

levels(result$expr) <- c('for', 'mapply', 'which', 'v > t', 'ifelse')
print(result, unit="relative")
autoplot(result)

v <- fgen()
t <- fgen()
f <- function(a, b) if(a > b) 0 else a
vf <- Vectorize(f)

result <- microbenchmark(
{ v[which(v > t)] <- 0 },
{ v <- vf(v, t) }
)

levels(result$expr) <- c('which', 'Vectorize')
print(result, unit="relative")
autoplot(result)

# R source code vs R compiled code vs C++ code
numElements <- 1e5
v <- fgen()
t <- fgen()

f <- function(v, t) for(i in 1:length(v)) if(v[i] > t[i]) v[i] <- 0
fc <- cmpfun(f)
cppFunction('
    void fCpp(NumericVector v, NumericVector t) {
      for(int i = 0; i < v.size(); i++)
         v[i] = v[i] > t[i] ? 0 : v[i];
    }
')

result <- microbenchmark(f(v, t), fc(v, t), fCpp(v, t))

levels(result$expr) <- c('R source', 'R compiled', 'Rcpp')
print(result, unit="relative")
autoplot(result)

v <- fgen()
t <- fgen()

result <- microbenchmark(v[which(v > t)] <- 0, fCpp(v, t))

levels(result$expr) <- c('which', 'Rcpp')
print(result, unit="relative")
autoplot(result)

# Reduce vs vectorized functions
numElements <- 1e5
v <- fgen()
result <- microbenchmark(sum(v), Reduce('+', v))

print(result, unit="relative")
autoplot(result)

numElements <- 1e4
aStringVector <- sample(someStrings, numElements, replace = TRUE)
result <- microbenchmark(paste(aStringVector, collapse = " "), Reduce(paste, aStringVector))

print(result, unit="relative")
autoplot(result)
