# RBenchmarkings
R Benchmarkings

This document compares the performance in doing a task by means of different approaches in R. For doing so, the `microbenchmark` package is used, measuring the time spent by each approach. The results are shown numerically and plotting them using `ggplot2`.

The goal is to elucidate which is the best method to accomplish a certain task.

How to use
=====
Open the [`RBenchmarkings.md`](RBenchmarkings.md) file to see the tests and the results they produce.

You can run these benchmarks in your own computer by downloading the [`RBenchmarkings.Rmd`](RBenchmarkings.Rmd) file and running it. To do so, you will need R and the `knitr`, `ggplot2` and `microbenchmark` packages.
