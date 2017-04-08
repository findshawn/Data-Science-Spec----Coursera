#########################################################################
############ Step 1 - Pull Data from MySQL and Cleanse Data #############
#########################################################################
library(lubridate)  
library(data.table)
library(Hmisc)
library(stringr)
library(dplyr)
library(reshape)
library(RMySQL)
library(stringi)
Ai <- dbConnect(MySQL(), user="xdxa052", password="xxxx", dbname="google_analytics", host="127.0.0.1", port=5000, client.flag=CLIENT_MULTI_STATEMENTS,on.exit(dbDisconnect(nstrans))) 

#Record time of execution
startTime <- Sys.time()

########################################Initial Data Pull#################################
#####################Extract Data for January############################
startDate <- as.Date('2016-01-01')
daysInMonth <- monthDays(startDate)
endDate <- startDate + daysInMonth - 1
diffStart <- Sys.Date() - startDate
diffEnd <- Sys.Date() - endDate
mon <- lubridate::month(startDate, label=TRUE, abbr=TRUE)

query1 <- paste("
                 select utma, gsid, date, channel 
                 from new_visits 
                 where date between ADDDATE(CURDATE(),-",diffStart,") and ADDDATE(CURDATE(),-",diffEnd,")
                 order by date, gsid, utma", sep="")
temp1 <- dbGetQuery (Ai,query1)

query2 <- paste("
                 select utma, sales_order_number, revenue 
                 from ga_sales_orders
                 where date between ADDDATE(CURDATE(),-",diffStart,") and ADDDATE(CURDATE(),-",diffEnd,")
                 order by utma", sep="")
temp2 <- dbGetQuery (Ai,query2)

#flights2 %>% left_join(planes, by = "tailnum")

#temp3 <- merge(x=temp1, y=temp2, by="utma", all.x=TRUE)
temp3 = temp1 %>% left_join(temp2, by = "utma")
rm(temp1)
rm(temp2)

#Calculate total revenue and orders from each session - note that some rows have order number but don't have revenue (soNo cannot be found in nstrans tables)
temp3$revenue[is.na(temp3$revenue)] <- 0
temp4 <- data.table(subset(temp3, revenue>0))
temp5 <- temp4[,.(sessionRevenue=sum(revenue)),by=utma]
temp6 <- temp4[,.N,by=utma]
names(temp6) <- c("utma","sessionOrders")
#temp7 <- merge(x=temp3, y=temp5, by="utma", all.x=TRUE)
temp7 = temp3 %>% left_join(temp5, by = "utma")

#temp7 <- merge(x=temp7, y=temp6, by="utma", all.x=TRUE)
temp7 = temp7 %>% left_join(temp6, by = "utma")

rm(temp3)
rm(temp4)
rm(temp5)
rm(temp6)

#Flag converted sessions 
temp7$convertedSession <- ifelse(temp7$revenue==0,0,1)
temp7$sales_order_number <- NULL
temp7$revenue <- NULL

#Save data frame for reference
assign(paste0("attribution_allsessions_",mon), data.frame(temp7))

#Remove duplicated utma for future steps
temp8 <- subset(temp7, !duplicated(temp7[,1]))
rownames(temp8) <- NULL

#Save to monthly data frame
assign(paste0("attribution_uniquesessions_",mon), data.frame(temp8))
rm(temp8)
rm(temp7)

#Record end time
endTime <- Sys.time()
endTime-startTime  #8 min

#####################Extract Data for December############################
startDate <- as.Date('2015-12-01')
daysInMonth <- monthDays(startDate)
endDate <- startDate + daysInMonth - 1
diffStart <- Sys.Date() - startDate
diffEnd <- Sys.Date() - endDate
mon <- lubridate::month(startDate, label=TRUE, abbr=TRUE)

query1 <- paste("
                select utma, gsid, date, channel 
                from new_visits 
                where date between ADDDATE(CURDATE(),-",diffStart,") and ADDDATE(CURDATE(),-",diffEnd,")
                order by date, gsid, utma", sep="")
temp1 <- dbGetQuery (Ai,query1)

query2 <- paste("
                select utma, sales_order_number, revenue 
                from ga_sales_orders
                where date between ADDDATE(CURDATE(),-",diffStart,") and ADDDATE(CURDATE(),-",diffEnd,")
                order by utma", sep="")
temp2 <- dbGetQuery (Ai,query2)

#flights2 %>% left_join(planes, by = "tailnum")

#temp3 <- merge(x=temp1, y=temp2, by="utma", all.x=TRUE)
temp3 = temp1 %>% left_join(temp2, by = "utma")
rm(temp1)
rm(temp2)

#Calculate total revenue and orders from each session - note that some rows have order number but don't have revenue (soNo cannot be found in nstrans tables)
temp3$revenue[is.na(temp3$revenue)] <- 0
temp4 <- data.table(subset(temp3, revenue>0))
temp5 <- temp4[,.(sessionRevenue=sum(revenue)),by=utma]
temp6 <- temp4[,.N,by=utma]
names(temp6) <- c("utma","sessionOrders")
#temp7 <- merge(x=temp3, y=temp5, by="utma", all.x=TRUE)
temp7 = temp3 %>% left_join(temp5, by = "utma")

#temp7 <- merge(x=temp7, y=temp6, by="utma", all.x=TRUE)
temp7 = temp7 %>% left_join(temp6, by = "utma")

rm(temp3)
rm(temp4)
rm(temp5)
rm(temp6)

#Flag converted sessions 
temp7$convertedSession <- ifelse(temp7$revenue==0,0,1)
temp7$sales_order_number <- NULL
temp7$revenue <- NULL

#Save data frame for reference
assign(paste0("attribution_allsessions_",mon), data.frame(temp7))

#Remove duplicated utma for future steps
temp8 <- subset(temp7, !duplicated(temp7[,1]))
rownames(temp8) <- NULL

#Save to monthly data frame
assign(paste0("attribution_uniquesessions_",mon), data.frame(temp8))
rm(temp8)
rm(temp7)

#Record end time
endTime <- Sys.time()
endTime-startTime  #8 min



##########################################################################################
############# Run the code below after we get all the data we need by month ##############
##########################################################################################

#Aggregate two months' data together (b/c of 30 day lookback window)
attribution_updated <- rbind(attribution_uniquesessions_Jan, attribution_uniquesessions_Dec)

#Save data file
#save(attribution_updated,file='attribution_uniquesessions_SepOct.Rda')

#Load data file
#load('attribution_uniquesessions_SepOct.Rda')

#########################################################################
################### Step 2 - Map out Conversion Path ####################
#########################################################################
startTime <- Sys.time()

##### Sample - Aggregate 7 days of conversion paths (Google defaults to 28 days)

#Test - Aggregate all conversions paths that ended between 2014-10-05 and 2015-10-11
d <- as.Date('2016-01-01')
mon <- lubridate::month(d, label=TRUE, abbr=TRUE)
day <- lubridate::day(d)
assign(paste0("attribution_path_",mon,collapse=""), data.frame())
window <- 31

#Create progress bar
pb <- winProgressBar(title="Conversion Path Mapping Progress Bar", min=0, max=window, width=300)

for (i in 1:window){
  
  #Set the dates
  endDate <- d + i - 1
  startDate <- endDate - 30 + 1
  
  #Pull out sessions and flag conversions 
  # (convertedOnEndDate =1 if gsid converted on endDate; convertedSession =1 if gsid converted within the session)
  attribution_gsid <- attribution_updated[attribution_updated$date==endDate,c(2,7)]
  attribution_conversion <- data.table(attribution_gsid)
  attribution_conversion <- attribution_conversion[order(attribution_conversion$gsid),]
  attribution_conversion <- attribution_conversion[,.(convertedOnEndDate=max(convertedSession)), by=gsid]  #duplicated gsid are removed in this step
  attribution_lookback <- subset(attribution_updated, date>startDate-1 & date<endDate+1)
  attribution_lookback <- inner_join(attribution_lookback, attribution_conversion, by="gsid") #selected only gsid which had sessions on endDate
  
  #Extract sessionCount then sort rows (sort sessions for each gsid in revert/backward order - most recent session first)
  attribution_lookback$sessionCount <- substring(attribution_lookback$utma, 
                                                 (sapply(str_locate_all(attribution_lookback$utma, "[.]"), "[", 5, 1)+1), 
                                                 str_length(attribution_lookback$utma))
  attribution_lookback <- attribution_lookback[order(rank(attribution_lookback$gsid),
                                                     -rank(attribution_lookback$date),
                                                     -as.numeric(attribution_lookback$sessionCount)),]
  attribution_lookback$utma <- NULL
  
  #For each gsid, need to extract only the sessions resulting in the most recent order 
  # (i.e. exclude sessions that resulted in previous orders)
  #Index the data frame to give each row a row number
  attribution_lookback$index <- seq.int(nrow(attribution_lookback))
  
  #Find out the total number of conversions for each gsid
  attribution_allconversions <- data.table(attribution_lookback)
  attribution_allconversions <- attribution_allconversions[,.(totalConvertedSessions=sum(convertedSession)),by=gsid]
  attribution_lookback <- inner_join(attribution_lookback,attribution_allconversions, by="gsid")
  
  #Select those with 
  #1) more than one conversion  - 28896
  #or
  #2) only one conversion which occurred before endDate - 12810
  attribution_tofilter <- subset(attribution_lookback, totalConvertedSessions>1 | (totalConvertedSessions==1&convertedOnEndDate==0))   #Out of 38849 gsid, 1413 had conversions, 227 had more than one conversion
  row.names(attribution_tofilter) <- NULL
  
  #Store the rest in another data frame
  #1) 0 conversion
  #or
  #2) only one conversion on endDate
  attribution_filtered <- subset(attribution_lookback, totalConvertedSessions==0 | (totalConvertedSessions==1&convertedOnEndDate==1))
  row.names(attribution_filtered) <- NULL 
  
  #Create a vector to store row numbers we want to keep for gsid with conversions>1
  v <- integer()  
  for (g in unique(attribution_tofilter$gsid)){
    temp <- subset(attribution_tofilter[,c(1,6,9)], gsid==g)    #extract only gsid, convertedSession and index 
    v <- c(v,temp[1,3])   #select the first line for each gsid and store its row number
    if (nrow(temp)>1) {
      for (i in 2:nrow(temp)){      #loop starts from 2nd line for each gsid
        if (temp$convertedSession[i]==0){     
          v <- c(v,temp[i,3])   #Store the index if the session didn't convert until reaching the previous converted session
        }
        else break   #loop stops if convertedSession becomes 1 
      }
    }  
  }  
  
  #Select the rows we want to keep - only the sessions leading to the last/most recent conversion for each gsid
  attribution_tofilter <- subset(attribution_tofilter, index %in% v)   
 
  #Union back to those already filtered (i.e. conversion=0 or 1 on endDate) records
  attribution_lookback <- rbind(attribution_filtered, attribution_tofilter)
 
  #While sorted in backward order, create columns orderReverse
  attribution_lookback <- attribution_lookback %>% group_by(gsid) %>% mutate(orderReverse=sequence(n()))
  
  #keep only the first 6 rows for each gsid (i.e. the most recent 6 steps in conversion path)
  attribution_lookback6 <- subset(attribution_lookback, orderReverse<7)
  
  #Sort again in forward order
  attribution_lookback6 <- attribution_lookback6[order(rank(attribution_lookback6$gsid),
                                                       rank(attribution_lookback6$date),
                                                       as.numeric(attribution_lookback6$sessionCount)),]
  
  #Clean up 
  attribution_lookback6$index <- NULL
  attribution_lookback6$totalConvertedSessions <- NULL
  attribution_lookback6$sessionCount <- NULL
  attribution_lookback6$date <- NULL
  attribution_lookback6$orderReverse <- NULL
  
  #Order sessions by gsid 
  attribution_lookback6 <- attribution_lookback6 %>% group_by(gsid) %>% mutate(order=sequence(n()))
  
  #Analyze the length of conversion path
  #attribution_length <- data.table(attribution_lookback$gsid)
  #attribution_length <- attribution_length[,.N,by=V1]
  #setNames(attribution_length, c("gsid","length"))
  #quantile(attribution_length$length,seq(0,1,0.01)) #96% length=6 - similar conclusion to previous tests
  ######Note: after multiple tests, decided to keep only the most recent 6 steps for each conversion path - code added to the above
  
  #Map out conversion path
  attribution_path <- cast(attribution_lookback6, gsid~order, value="channel")  
  
  #Merge to get conversion flag (i.e. whether a path led to a conversion on endDate)
  attribution_path <- left_join(attribution_path,attribution_conversion, by="gsid")
  colnames(attribution_path)[2:7] <- c("step1","step2","step3","step4","step5","step6")
  
  #Concatenate conversion paths to a single column
  attribution_path$path <- paste0(attribution_path$step1,".",
                                  attribution_path$step2,".",
                                  attribution_path$step3,".",
                                  attribution_path$step4,".",
                                  attribution_path$step5,".",
                                  attribution_path$step6)
  
  #Merge to master data frame
  attribution_path_Jan <- rbind(attribution_path_Jan, attribution_path)
  
  #Clean up
  rm(attribution_gsid)
  rm(attribution_conversion)
  rm(attribution_lookback)
  rm(attribution_path)
  rm(attribution_allconversions)
  rm(attribution_filtered)
  rm(attribution_tofilter)
  gc()
  
  #Update progress bar
  setWinProgressBar(pb,i,title=paste(round(i/window*100,0),"% done"))
  
}

close(pb)

endTime <- Sys.time()
endTime-startTime   #looping 7 days takes 23 min

#########################################################################
################### Step 3 - Compute Conversion Rate ####################
#########################################################################
#Count number of rows by each path structure
attribution_temp <- data.table(attribution_path_Jan)
attribution_temp <- attribution_temp[,.N, by=path]
setnames(attribution_temp, c("path", "customerCount"))

#Sum convertedFinal
attribution_temp2 <- data.table(attribution_path_Jan)
attribution_temp2 <- attribution_temp2[,.(pathConversions=sum(convertedOnEndDate)), by=path]

#Merge to calculate conversion probabilities
attribution_convrate <- inner_join(attribution_temp, attribution_temp2, by="path")
attribution_convrate$conversionRate <- round(attribution_convrate$pathConversions/attribution_convrate$customerCount, 4)
attribution_convrate <- attribution_convrate[order(-attribution_convrate$pathConversions),]

#Define function to count the occurances of a substring in a string
countSub <- function(sub, string){
  s <- gsub(sub,"",string)
  l <- nchar(sub)
  ct <- (nchar(string) - nchar(s))/l
  return (ct)
}

#Calcualte the length of each path structure (length = 6 - # of occurances of "NA")
attribution_convrate$pathLength <- 6 - countChar("NA", attribution_convrate$path)


