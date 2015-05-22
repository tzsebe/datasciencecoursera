## This set of functions allows the use of a matrix that caches its inverse,
## allowing efficient access without needing to recompute it every time.
##
## We use a silly two-method approach to accomplish this task:
## * makeCacheMatrix: This isolates the data (matrix and its inverse)
## * cacheSolve: This retrieves the inverse from cache if available,
##               and computes/stores it if not.

## Create a wrapper around a matrix and its inverse.
##
## Methods:
## - get: Returns the matrix
## - set: Sets the value to a new matrix
## - getInverse: Retrieves the stored inverse matrix (can be NULL)
## - setInverse: Sets the value of the inverse matrix
makeCacheMatrix <- function(x = matrix()) {
    inv <- NULL

    # Set the matrix to value y. We assign it to 'x', as shown by the example,
    # even though that's a silly way to go about it. :-)
    # Also reset the stored inverse, for obvious reasons.
    set <- function(y) {
        x <<- y
        inv <<- NULL
    }

    # Get the matrix.
    get <- function() {
        x
    }

    # Set the inverse of the matrix.
    setInverse <- function(inverse) {
        inv <<- inverse
    }

    # Get the inverse value.
    getInverse <- function() {
        inv
    }

    # Expose all these functions
    list(set = set, get = get, setInverse = setInverse, getInverse = getInverse)
}


## Given a matrix constructed through makeCacheMatrix, retrieve the inverse.
## If the inverse is not already cached, compute it and store it for future use.
cacheSolve <- function(x, ...) {
    # Retrieve from cache if possible.
    inv <- x$getInverse()
    if(!is.null(inv)) {
        message("getting cached data")
        return(inv)
    }

    # Compute from scratch.
    data <- x$get()
    inv <- solve(data, ...)
    x$setInverse(inv)
    inv
}

