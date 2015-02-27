# R Benchmarkings
Francisco Charte Ojeda  
Friday, February 27, 2015  

This document compares the performance in doing a task by means of different approaches in R. For doing so, the `microbenchmark` package is used, measuring the time spent by each approach. The results are shown numerically and plotting them using `ggplot2`.

The goal is to elucidate which is the best method to accomplish a certain task.

Generating a data.frame containing character data with and without stringAsFactors
=================

With this code I want to test the difference between using `stringAsFactors = TRUE` versus `stringAsFactors = FALSE` while creating a new data.frame.




```r
library(microbenchmark)
library(ggplot2)

numElements <- 1E6
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
