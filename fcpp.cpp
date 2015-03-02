#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
void fcpp(NumericVector v, NumericVector t) {
  for(int i = 0; i < v.size(); i++)
     v[i] = v[i] > t[i] ? 0 : v[i];
}
