pollutantmean <- function(directory, pollutant, id = 1:332) {
    
    df <- data.frame();
    
    for (i in id) {
        ichar <- formatC(i,width=3,flag="0")
        readInFilePath <- paste0(directory,"/",ichar,".csv")
        readInFile <- read.csv(readInFilePath)
        df <- rbind(df,readInFile)
    };
    
    mean(df[[pollutant]],na.rm=1);
}


# pollutantmean("specdata", "sulfate", 1:10)
# pollutantmean("specdata", "nitrate", 70:72)
# pollutantmean("specdata", "sulfate", 34)
# pollutantmean("specdata", "nitrate")