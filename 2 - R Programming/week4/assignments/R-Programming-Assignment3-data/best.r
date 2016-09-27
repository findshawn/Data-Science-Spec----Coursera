# outcome <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
# head(outcome)
# 
# outcome[, 11] <- as.numeric(outcome[, 11])
# df[, 17]
# hist(outcome[, 11])

best <- function(state, outcome) {

    ## Read outcome data
    df <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
    
    ## Check that state and outcome are valid
    if (!(state %in% df$State)) {
        stop("invalid state")
    }
    
    if (!(outcome %in% c("heart attack","heart failure","pneumonia"))) {
        stop("invalid outcome")
    } 
    
    ## Return hospital name in that state with lowest 30-day death rate
    df[,c(11,17,23)] <- sapply(df[,c(11,17,23)],as.numeric)
    col <- ifelse(outcome=='heart attack',11,
                  ifelse(outcome=='heart failure',17,23)
                  )
    df2 <- df[!is.na(df[,col]) & df$State==state,]
    df3 <- df2[order(df2[,col],df2$Hospital.Name),]
    
    return(df3$Hospital.Name[1])
}

# best("TX", "heart attack")
# best("TX", "heart failure")
# best("MD", "heart attack")
# best("MD", "pneumonia")
# best("BB", "heart attack")
# best("NY", "hert attack")

