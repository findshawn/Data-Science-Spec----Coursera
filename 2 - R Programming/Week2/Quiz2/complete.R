complete <- function(directory, id = 1:332) {
    
    df <- data.frame(id = id, nobs = 0)
    
    for (i in id) {
        ichar <- formatC(i,width=3,flag="0")
        readInFilePath <- paste0(directory,"/",ichar,".csv")
        readInFile <- read.csv(readInFilePath)
        
        df$nobs[df$id==i] <- sum(complete.cases(readInFile))
    };
    
    df
}

# cc <- complete("specdata", c(6, 10, 20, 34, 100, 200, 310))
# cc <- complete("specdata", 54)
# 
# set.seed(42)
# cc <- complete("specdata", 332:1)
# use <- sample(332, 10)
# print(cc[use, "nobs"])