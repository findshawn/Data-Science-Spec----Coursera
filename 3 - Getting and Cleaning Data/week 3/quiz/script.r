library(dplyr)
library(jpeg)
library(Hmisc)

########################################## Q1 ####################################################

download.file(
    "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv",
    "q1data.csv"
)

download.file(
    "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf",
    "q1ref.pdf"
)

# Create a logical vector that identifies the households on greater than 10 acres who sold more than $10,000 worth of agriculture products. Assign that logical vector to the variable agricultureLogical. Apply the which() function like this to identify the rows of the data frame where the logical vector is TRUE.
# which(agricultureLogical)
# What are the first 3 values that result?

q1data <- read.csv("q1data.csv")
unique(q1data$ACR) # ACR==3
unique(q1data$AGS) # AGS==6

q1data <- q1data %>% mutate(agricultureLogical = (ACR==3 & AGS==6))
which(q1data$agricultureLogical)

########################################## Q2 ####################################################

download.file(
    "https://d396qusza40orc.cloudfront.net/getdata%2Fjeff.jpg",
    "q2data.jpg"
)
q2data <- readJPEG("q2data.jpg", native = T)
quantile(q2data,seq(0,1,.1))

########################################## Q3 ####################################################
download.file(
    "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv",
    "q3data1.csv"
)
download.file(
    "https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv",
    "q3data2.csv"
)

# Match the data based on the country shortcode. How many of the IDs match? Sort the data frame in descending order by GDP rank (so United States is last). What is the 13th country in the resulting data frame?

q3data1 <- read.csv("q3data1.csv",sep=",",header=F,blank.lines.skip = TRUE,skip=5,skipNul = T)
q3data1 <- q3data1[q3data1$V1!='',]
q3data1 <- q3data1[1:(which(q3data1$V4=="World")-1),]
q3data1 <- q3data1[q3data1$V2!='',]


q3data2 <- read.csv("q3data2.csv")
head(q3data1,10)
head(q3data2,10)
str(q3data1)
str(q3data2)

q3merge <- merge(q3data1,q3data2,by.x='V1',by.y='CountryCode')
q3merge$V2 <- as.integer(as.character(q3merge$V2))
head(arrange(q3merge,desc(V2)),13)

########################################## Q4 ####################################################

# What is the average GDP ranking for the "High income: OECD" and "High income: nonOECD" group?
unique(q3merge$Income.Group)
q3merge %>%
    group_by(Income.Group) %>%
    summarise(
        mean(V2,na.rm=1)
    )

########################################## Q5 ###################################################

# Cut the GDP ranking into 5 separate quantile groups. Make a table versus Income.Group. How many countries are Lower middle income but among the 38 nations with highest GDP?
q3merge$V2_2 <- cut2(q3merge$V2,g=5)
table(q3merge$V2_2,q3merge$Income.Group)
