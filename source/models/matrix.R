library(assertthat)
library(data.table)
library(Matrix)

args <- commandArgs(trailingOnly=TRUE)

n <- length(args)
population_file <- args[1]
outcomes_file   <- args[2]
feature_files   <- args[3:(n-4)]
out_file        <- args[n-3]
train_file      <- args[n-2]
validate_file   <- args[n-1]
test_file       <- args[n]
 
pop <- fread(population_file)

train    <- pop$SUBSET == "TRAINING"
validate <- pop$SUBSET == "VALIDATION"
test     <- pop$SUBSET == "TESTING"

y <- fread(outcomes_file)

y_train    <- y[train,]
y_validate <- y[validate,]
y_test     <- y[test,]

n <- length(feature_files)
X_train    <- vector("list", n)
X_validate <- vector("list", n)
X_test     <- vector("list", n)

for (i in 1:n) {
    print(paste0("Adding ", feature_files[[i]]))
    feature <- fread(feature_files[[i]])
    print(paste0(ncol(feature) - 1, " features"))
    gc()
    X_train[[i]]    <- Matrix(as.matrix(feature[train,    -c(1)]), sparse=TRUE)
    X_validate[[i]] <- Matrix(as.matrix(feature[validate, -c(1)]), sparse=TRUE)
    X_test[[i]]     <- Matrix(as.matrix(feature[test,     -c(1)]), sparse=TRUE)
}
gc()

X_train    <- do.call("cbind", X_train)
X_validate <- do.call("cbind", X_validate)
X_test     <- do.call("cbind", X_test)

save(X_train, X_validate, X_test,
     y_train, y_validate, y_test,
     file=out_file)

writeMM(X_train, file=train_file)
writeMM(X_validate, file=validate_file)
writeMM(X_test, file=test_file)

