% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/isoforest.R
\name{append.trees}
\alias{append.trees}
\title{Append isolation trees from one model into another}
\usage{
append.trees(model, other)
}
\arguments{
\item{model}{An Isolation Forest model (as returned by function \link{isolation.forest})
to which trees from `other` (another Isolation Forest model) will be appended into.
The result of this function must be reassigned to `model`, and the old `model` should
not be used any further.}

\item{other}{Another Isolation Forest model, from which trees will be appended into
`model`. It will not be modified during the call to this function.}
}
\value{
The updated `model` object, to which `model` needs to be reassigned
(i.e. you need to use it as follows: `model <- append.trees(model, other)`).
}
\description{
This function is intended for merging models \bold{that use the same hyperparameters} but
were fitted to different subsets of data.

In order for this to work, both models must have been fit to data in the same format - 
that is, same number of columns, same order of the columns, and same column types, although
not necessarily same object classes (e.g. can mix `base::matrix` and `Matrix::dgCMatrix`).

If the data has categorical variables, the models should have been built with parameter
`recode_categ=FALSE` in the call to \link{isolation.forest} (which is \bold{not} the
default), and the categorical columns passed as type `factor` with the same `levels` -
otherwise different models might be using different encodings for each categorical column,
which will not be preserved as only the trees will be appended without any associated metadata.

Note that this function will not perform any checks on the inputs, and passing two incompatible
models (e.g. fit to different numbers of columns) will result in wrong results and
potentially crashing the R process when using it.

Also be aware that the result \bold{must} be reassigned to the first input, as the first
input will no longer work correctly after appending more trees to it.

\bold{Important:} the result of this function must be reassigned to `model` in order for it
to work properly - e.g. `model <- append.trees(model, other)`.
}
\details{
Important: this function will modify the model object in-place, but this modification will only affect the R
object in the environment in which it was called. If trying to use the same model object in e.g. its parent environment,
it will lead to issues due to the C++ object being modified but the R object remaining the same, so if this method is used
inside a function, make sure to output the newly-modified R object and have it replace the old R object outside the calling
function too.

The model object can be deep copied (including the underlying C++ object) through
function \link{deepcopy.isotree}.
}
\examples{
library(isotree)

### Generate two random sets of data
m <- 100
n <- 2
set.seed(1)
X1 <- matrix(rnorm(m*n), nrow=m)
X2 <- matrix(rnorm(m*n), nrow=m)

### Fit a model to each dataset
iso1 <- isolation.forest(X1, ntrees=3, nthreads=1)
iso2 <- isolation.forest(X2, ntrees=2, nthreads=1)

### Check the terminal nodes for some observations
nodes1 <- predict(iso1, head(X1, 3), type="tree_num")
nodes2 <- predict(iso2, head(X1, 3), type="tree_num")

### Append the trees from 'iso2' into 'iso1'
iso1 <- append.trees(iso1, iso2)

### Check that it predicts the same as the two models
nodes.comb <- predict(iso1, head(X1, 3), type="tree_num")
nodes.comb$tree_num == cbind(nodes1$tree_num, nodes2$tree_num)

### The new predicted scores will be a weighted average
### (Be aware that, due to round-off, it will not match with '==')
nodes.comb$avg_depth
(3*nodes1$avg_depth + 2*nodes2$avg_depth) / 5
}
