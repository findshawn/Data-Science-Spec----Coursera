#source("complete.R")
corr <- function(directory, threshold = 0) {
    
    v <- c();
    
    df_cnt <- complete(directory)
    
    for (i in 1:332) {
        if (df_cnt$nobs[df_cnt$id==i]>threshold) {
            
            ichar <- formatC(i,width=3,flag="0")
            readInFilePath <- paste0(directory,"/",ichar,".csv")
            readInFile <- read.csv(readInFilePath)
            
            cor_val <- cor(readInFile$sulfate,readInFile$nitrate,use = "complete.obs")
            v <- append(v,cor_val)
        }
    }
    
    return(v)
}

# cr <- corr("specdata")                
# cr <- sort(cr)                
# set.seed(868)                
# out <- round(cr[sample(length(cr), 5)], 4)
# print(out)
# 
# cr <- corr("specdata", 129)                
# cr <- sort(cr)                
# n <- length(cr)                
# set.seed(197)                
# out <- c(n, round(cr[sample(n, 5)], 4))
# print(out)
# 
# cr <- corr("specdata", 2000)                
# n <- length(cr)                
# cr <- corr("specdata", 1000)                
# cr <- sort(cr)
# print(c(n, round(cr, 4)))
