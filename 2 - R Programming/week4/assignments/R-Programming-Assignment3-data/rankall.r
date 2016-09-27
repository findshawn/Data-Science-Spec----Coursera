rankall <- function(outcome, num = "best") {
    ## Read outcome data
    df <- read.csv("outcome-of-care-measures.csv", colClasses = "character")
    
    ## Check that outcome are valid   
    if (!(outcome %in% c("heart attack","heart failure","pneumonia"))) {
        stop("invalid outcome")
    } 
    
    ## For each state, find the hospital of the given rank
    df[,c(11,17,23)] <- sapply(df[,c(11,17,23)],as.numeric)
    col <- ifelse(outcome=='heart attack',11,
                  ifelse(outcome=='heart failure',17,23)
    )
    df2 <- df[!is.na(df[,col]),]
    df3 <- df2[order(df2$State,df2[,col],df2$Hospital.Name),]
    
    if (num == 'best') {
        df4 <- as.data.frame(tapply(df3$Hospital.Name,df3$State,function(x) head(x,1)))
    } else if (num == 'worst') {
        df4 <- as.data.frame(tapply(df3$Hospital.Name,df3$State,function(x) tail(x,1)))
    } else if (num%%1 == 0 & num >= 1) {
        df4 <- as.data.frame(tapply(df3$Hospital.Name,df3$State,function(x) x[num]))
    } else {
        stop("invalid num value")
    }
    
        ## Return a data frame with the hospital names and the
    ## (abbreviated) state name
    names(df4)[1] <- 'hospital'
    df4$state <- row.names(df4)
    return(df4)
}

# head(rankall("heart attack", 20), 10)
# tail(rankall("pneumonia", "worst"), 3)
# tail(rankall("heart failure"), 10)
