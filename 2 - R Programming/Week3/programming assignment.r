makeCacheMatrix <- function (x = matrix()) {
    
    # check if matrix
    if(!is.matrix(x)) {
        stop("input is not a matrix!")
    }
    
    # check if square matrix
    if(nrow(x)!=ncol(x)) {
        stop("please input a square matrix! (equal number of rows and columns)")
    }
    
    inverse <- NULL
    set <- function(y) {
        x <<- y
        inverse <<- NULL
    }
    get <- function() x
    setInverse <- function(inv) inverse <<- inv
    getInverse <- function() inverse
    
    # return
    list(set = set, get = get, setInverse = setInverse, getInverse = getInverse)
}


cacheSolve <- function(t,...) {
    inverse <- t$getInverse();
    if(!is.null(inverse)) {
        message("Cache found and loading");
        return(inverse)
    }
    data <- t$get();
    inverse <- solve(data,...);
    t$setInverse(inverse);
    message("saving the following data as cache")
    return(inverse)
}

m = matrix(runif(1000000),1000,1000)
m = 1:10
t = makeCacheMatrix(m)
system.time(cacheSolve(t))

