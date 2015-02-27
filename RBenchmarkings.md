# R Benchmarkings
Francisco Charte Ojeda  
Friday, February 27, 2015  

This document compares the performance in doing a task by means of different approaches in R. For doing so, the `microbenchmark` package is used, measuring the time spent by each approach. The results are shown numerically and plotting them using `ggplot2`.

The goal is to elucidate which is the best method to accomplish a certain task.

Generating a data.frame containing character data with and without stringsAsFactors
=================

With this code I want to test the difference between using `stringsAsFactors = TRUE` versus `stringsAsFactors = FALSE` while creating a new data.frame.




```r
library(microbenchmark)
library(ggplot2)

numElements <- 1e6
someStrings <- sapply(1:25, function(x) paste(sample(c(letters, LETTERS), 10, replace = TRUE), collapse = ""))

aNumericVector <- runif(numElements)
aStringVector <- sample(someStrings, numElements, replace = TRUE)
bStringVector <- sample(someStrings, numElements, replace = TRUE)

result <- microbenchmark(
    data.frame(aNumericVector, aStringVector, bStringVector, stringsAsFactors = TRUE),
    data.frame(aNumericVector, aStringVector, bStringVector, stringsAsFactors = FALSE)
)
```


```
## Unit: microseconds
##                expr       min        lq      mean     median        uq
##  stringsAsFactors=T 63663.300 68011.793 79166.269 70793.0625 98871.511
##  stringsAsFactors=F   202.341   216.087   252.626   256.7755   277.303
##         max neval
##  173628.180   100
##     330.271   100
```

![](figure/unnamed-chunk-1-1.png) 

Conclusion
----------------
Generating a `data.frame` containing character columns is quicker when `stringsAsFactors = FALSE` is used. Nonetheless, it may be taken into account that this option implies the use of more memory, as character strings are stored individually instead of as numeric values referencing the factor levels. For this same reason, further operations such as sorting by a character column can take more time (compared with sorting by a factor column).

Growing list vs preallocated list vs lapply
===============
With the code shown below I want to test the differences between creating a list growing it, preallocating the elements, and using the `lapply` function. 


```r
numElements <- 1e4

result <- microbenchmark(
  { v1 <- list() ; for(i in 1:numElements) v1[[i]] <- someStrings },
  { v2 <- vector('list', numElements) ; for(i in 1:numElements) v2[[i]] <- someStrings },
  { v3 <- lapply(1:numElements, function(i) someStrings)}
)
```


```
## Unit: milliseconds
##               expr        min         lq       mean     median         uq
##         Empty list 224.685868 257.948932 257.710482 262.888320 265.938461
##  Preallocated list   7.970467   8.197734   8.929039   8.370383   8.880268
##             lapply   2.262405   2.343781   2.549256   2.426257   2.515148
##         max neval
##  310.987875   100
##   44.134482   100
##    3.761266   100
```

![](figure/unnamed-chunk-2-1.png) 

Conclusion
----------------
There is no doubt that growing the list as items are added is a bad idea, since this method is much slower than the other two. The differences between preallocating the list and then populating it with a `for` loop or generating it with the `lapply` function are not as large, but certainly `lapply` has the advantage.

The result should be the same while working with a vector or a data.frame, instead of a list.

$ vs [[ operator
==============
