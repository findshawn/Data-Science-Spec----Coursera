#===========================================================================
#                               Q1
#===========================================================================

# The American Community Survey distributes downloadable data about United States communities. Download the 2006 microdata survey about housing for the state of Idaho using download.file() from here:
#     
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv
# 
# and load the data into R. The code book, describing the variable names is here:
#     
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FPUMSDataDict06.pdf
# 
# Apply strsplit() to split all the names of the data frame on the characters "wgtp". What is the value of the 123 element of the resulting list?

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2Fss06hid.csv","q1data.csv")
q1data <- read.csv("q1data.csv")
names(q1data)
strsplit(names(q1data),"wgtp")[[123]]

#===========================================================================
#                               Q2
#===========================================================================

# Load the Gross Domestic Product data for the 190 ranked countries in this data set:
#     
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv
# 
# Remove the commas from the GDP numbers in millions of dollars and average them. What is the average?
# 
# Original data sources:
#     
#     http://data.worldbank.org/data-catalog/GDP-ranking-table

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv","q2data.csv")
q2data <- read.csv("q2data.csv")
names(q2data)[2] <- 'ranking'
q2data <- subset(q2data,ranking!='')
q2data$ranking <- as.integer(as.character(q2data$ranking))
q2data <- subset(q2data,!is.na(ranking))

q2data$X.3 <- as.character(q2data$X.3)
q2data$X.3 <- gsub(" |,","",q2data$X.3)
q2data$X.3 <- as.numeric(q2data$X.3)
mean(q2data$X.3)

#===========================================================================
#                               Q3
#===========================================================================
# In the data set from Question 2 what is a regular expression that would allow you to count the number of countries whose name begins with "United"? Assume that the variable with the country names in it is named countryNames. How many countries begin with United?
grep("^United",q2data$X.2)

#===========================================================================
#                               Q4
#===========================================================================

# Load the Gross Domestic Product data for the 190 ranked countries in this data set:
#     
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FGDP.csv
# 
# Load the educational data from this data set:
#     
#     https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv
# 
# Match the data based on the country shortcode. Of the countries for which the end of the fiscal year is available, how many end in June?
# 
# Original data sources:
#     
#     http://data.worldbank.org/data-catalog/GDP-ranking-table
# 
#     http://data.worldbank.org/data-catalog/ed-stats

download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fdata%2FEDSTATS_Country.csv","q4data.csv")
q4data <- read.csv("q4data.csv")
q4data <- subset(q4data,Income.Group!='')

q4merge <- merge(q2data,q4data,by.x='X',by.y='CountryCode')
unique(q4merge$Special.Notes)
grep("June",q4merge$Special.Notes,value=T)
# sum(grepl("June",q4merge$Special.Notes))


#===========================================================================
#                               Q5
#===========================================================================

# You can use the quantmod (http://www.quantmod.com/) package to get historical stock prices for publicly traded companies on the NASDAQ and NYSE. Use the following code to download data on Amazon's stock price and get the times the data was sampled.
# 
#     library(quantmod)
#     amzn = getSymbols("AMZN",auto.assign=FALSE)
#     sampleTimes = index(amzn)
# 
# How many values were collected in 2012? How many values were collected on Mondays in 2012?

library(quantmod)
amzn = getSymbols("AMZN",auto.assign=FALSE)
sampleTimes = index(amzn)

library(lubridate)
sum(year(sampleTimes)==2012)
sum(wday(sampleTimes,label=T)=='Mon' & year(sampleTimes)==2012)
