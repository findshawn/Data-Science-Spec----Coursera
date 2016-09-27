# outcome <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
# head(outcome)
# 
# outcome[, 11] <- as.numeric(outcome[, 11])
# df[, 17]
# hist(outcome[, 11])

rankhospital <- function(state, outcome, num = "best") {
    ## Read outcome data
    df <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
    
    ## Check that state and outcome are valid
    if (!(state %in% df$State)) {
        stop("invalid state")
    }
    
    if (!(outcome %in% c("heart attack","heart failure","pneumonia"))) {
        stop("invalid outcome")
    } 
    
    ## Return hospital name in that state with the given rank 30-day death rate
    df[,c(11,17,23)] <- sapply(df[,c(11,17,23)],as.numeric)
    col <- ifelse(outcome=='heart attack',11,
                  ifelse(outcome=='heart failure',17,23)
    )
    df2 <- df[!is.na(df[,col]) & df$State==state,]
    df3 <- df2[order(df2[,col],df2$Hospital.Name),]
    
    if (num == 'best') {
        return(df3$Hospital.Name[1])
    } else if (num == 'worst') {
        return(df3$Hospital.Name[nrow(df3)])
    } else if (num%%1 == 0 & num >= 1 & num <= nrow(df3)) {
        return(df3$Hospital.Name[num])
    } else if (num%%1 == 0 & num > nrow(df3)) {
        return(NA)
    } else {
        stop("invalid num value")
    }
  
}

# rankhospital("TX", "heart failure", 4)
# rankhospital("MD", "heart attack", "worst")
# rankhospital("MN", "heart attack", 5000)
