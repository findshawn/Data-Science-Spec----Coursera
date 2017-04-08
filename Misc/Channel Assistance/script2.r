library(RMySQL)
library(dplyr)
library(reshape2)
library(scales)
library(ggplot2)
library(lattice)

################################################## prepare data ############################################
# load Eridana's file
load('input/attribution_path_Jan 160427.Rda')
attribution_path_Jan <- subset(attribution_path_Jan,!is.na(sales_order_number))
#load('input/attribution_path_Jan 160427.Rdata')

# pull transaction and industry data from mysql
con <- dbConnect(MySQL(),user = 'xsxj045',password = 'xxxx',host = 'localhost',port = 10000)
orders <- dbGetQuery(con,"select * from nstrans.ordersTotal_so where date between '2016-01-01' and '2016-01-31'")
orders$email <- tolower(orders$email)
orders <- unique(orders)
orders <- arrange(orders,soNo)
length(unique(orders$soNo)) == nrow(orders)

# merge
path <- merge(attribution_path_Jan,orders,by.x='sales_order_number',by.y='soNo')

# clean NA
path <- subset(path,!is.na(step1))

# fix factors
for (i in 1:6) {
  name = paste0('step',i)
  path[,name] <- as.character(path[,name])
}

# extract visits
path$visits <- ifelse(!is.na(path$step6),6,
                      ifelse(!is.na(path$step5),5,
                             ifelse(!is.na(path$step4),4,
                                    ifelse(!is.na(path$step3),3,
                                           ifelse(!is.na(path$step2),2,
                                                  ifelse(!is.na(path$step1),1,NA)
                                           )
                                    )
                             )
                      )
                )
                                                         
# extract last click
path$last_step <- ifelse(!is.na(path$step6),path$step6,
                         ifelse(!is.na(path$step5),path$step5,
                                ifelse(!is.na(path$step4),path$step4,
                                       ifelse(!is.na(path$step3),path$step3,
                                              ifelse(!is.na(path$step2),path$step2,
                                                     ifelse(!is.na(path$step1),path$step1,NA)
                                              )
                                       )
                                )
                         )
                  )

# fix column name
names(path)
path <- rename(path,soNo=sales_order_number)

################################################## analyze data ############################################

# visits
visits <- path %>% group_by(visits) %>% summarise(cnt = n(),sales = sum(amount))
sum(path$visits)

# last click
last <- path %>% group_by(last_step) %>% summarise(cnt = n(),sales = sum(amount)) %>% arrange(rank(last_step))
table(path$last_step,path$visits)
round(prop.table(table(path$last_step,path$visits),1),2)

# first click
first <- path %>% group_by(step1) %>% summarise(cnt = n(),sales = sum(amount)) %>% arrange(rank(step1))
table(path$step1,path$visits)
round(prop.table(table(path$step1,path$visits),1),2)


# melt
path2 <- melt(path[,c('soNo','step1','step2','step3','step4','step5','step6')],id = 'soNo',na.rm=1, 
              variable.name = "step", 
              value.name = "channel"
              )
path2 <- arrange(path2,soNo,step)
path2 <- merge(path2,path[,c('soNo','visits')],by='soNo')
table(path2$channel)

# influencers
influencers <- path2 %>% group_by(soNo) %>% arrange(step) %>% filter(row_number()!=1 & row_number()!=n())
table(influencers$channel)

################################################## attribution model ############################################
w1 = 0
w2 = 0
w3 = 1

path$sales1 <- ifelse(path$visits>2,path$amount * w1,path$amount*w1/(w1+w3))
path$sales2 <- ifelse(path$visits>2,path$amount * w2,0)
path$sales3 <- ifelse(path$visits>2,path$amount * w3,path$amount*w3/(w1+w3))

attribution1 <- path %>% group_by(step1) %>% summarise(sales1 = sum(sales1)) %>% arrange(rank(step1))
attribution3 <- path %>% group_by(last_step) %>% summarise(sales3 = sum(sales3)) %>% arrange(rank(last_step))

influencers$sales2 <- NULL
influencers <- merge(influencers,path[,c('soNo','sales2')],by='soNo')
influencers$sales2 <- influencers$sales2/(influencers$visits-2)
attribution2 <- influencers %>% group_by(channel) %>% summarise(sales2 = sum(sales2)) %>% arrange(rank(channel))

attribution <- cbind(attribution1,attribution2,attribution3)
attribution <- mutate(attribution,sales = sales1 + sales2 + sales3)
attribution$sales_perc <- percent(attribution$sales / sum(attribution$sales))

################################################## BUS vs INDV ############################################
# download industry data from Ed's table
con <- dbConnect(MySQL(),user = 'xsxj045',password = 'xxxx',host = 'localhost',port = 10000)
master_customer <- dbGetQuery(con,"select email,derived_customer_type as type from customer_process.master_customer where derived_customer_type is not null group by 1,2 order by 1,2")

# fix table
master_customer$email <- tolower(master_customer$email) 
master_customer <- unique(master_customer)
length(unique(master_customer$email)) == nrow(master_customer)
table(master_customer$type)

# merge to add customer type
path <- merge(path,master_customer,by = 'email',all.x=1)
table(path$type)
sum(is.na(path$type))

path2 <- merge(path2,path[,c('soNo','type')],by='soNo',all.x = 1)
sum(is.na(path2$type))

############################################### BUS vs INDV data
table(path2$channel,path2$type)

table(path$step1,path$type)

table(path$last_step,path$type)

influencers <- merge(influencers,path[,c('soNo','type')],by='soNo')
table(influencers$channel,influencers$type)


####################################### Acquisition vs Repeat order / customers ########################################


# seperate first orders from repeat orders 
path$new_order <- ifelse(path$freq==1,1,2)
table(path$new_order)
sum(is.na(path$new_order))

path2 <- merge(path2,path[,c('soNo','new_order')],by='soNo',all.x = 1)
sum(is.na(path2$new_order))

influencers <- merge(influencers,path[,c('soNo','new_order')],by='soNo')

# seperate new from repeat customers
cus_orders <- orders %>% group_by(email) %>% summarize(orders=max(freq))
cus_orders$new_cus <- ifelse(cus_orders$orders==1,1,2)

path <- merge(path,cus_orders[,c('email','new_cus')],by='email')
path2 <- merge(path2,path[,c('soNo','new_cus')],by='soNo',all.x = 1)

influencers <- merge(influencers,path[,c('soNo','new_cus')],by='soNo')

# first orders from repeat cus
table(path$new_order,path$new_cus)

path$order_type <- ifelse(path$new_cus==1,1,
                          ifelse(path$new_cus==2 & path$new_order==1,2,3)
                          )

path2$order_type <- ifelse(path2$new_cus==1,1,
                          ifelse(path2$new_cus==2 & path2$new_order==1,2,3)
)

influencers$order_type <- ifelse(influencers$new_cus==1,1,
                           ifelse(influencers$new_cus==2 & influencers$new_order==1,2,3)
)

############################################### New vs Repeat data
table(path2$channel,path2$order_type)
table(path$step1,path$order_type)
table(path$last_step,path$order_type)
table(influencers$channel,influencers$order_type)

table(path$visits,path$order_type)
table(path$order_type)



###################################################################################################################################
################################################### Most Common Conversion Paths ##################################################
###################################################################################################################################
path$profit <- path$amount - path$cost

common_paths <- as.data.frame(
  path %>% group_by(path) %>% summarize(
    visits = mean(visits),
    conversions = n_distinct(soNo),
    revenue = sum(amount),
    profit = sum(profit),
    revenue_per_order = sum(amount)/n_distinct(soNo),
    profit_per_order = sum(profit)/n_distinct(soNo),
    profit_rate = sum(profit)/sum(amount)
  )
)
write.csv(common_paths,file='../output/common paths.csv',row.names=FALSE)

head(common_paths[order(-common_paths$conversions),],100)
common_paths[order(-common_paths$),]

############################################# segment by new customers vs repeat customers ###############################
# new cus
common_paths_new <- as.data.frame(
  path %>% filter(new_cus==1) %>% group_by(path) %>% summarize(
    visits = mean(visits),
    conversions = n_distinct(soNo),
    revenue = sum(amount),
    profit = sum(profit),
    revenue_per_order = sum(amount)/n_distinct(soNo),
    profit_per_order = sum(profit)/n_distinct(soNo),
    profit_rate = sum(profit)/sum(amount)
  )
)
write.csv(common_paths_new,file='../output/common paths new.csv',row.names=FALSE)

# repeat cus
common_paths_repeat <- as.data.frame(
  path %>% filter(new_cus==2) %>% group_by(path) %>% summarize(
    visits = mean(visits),
    conversions = n_distinct(soNo),
    revenue = sum(amount),
    profit = sum(profit),
    revenue_per_order = sum(amount)/n_distinct(soNo),
    profit_per_order = sum(profit)/n_distinct(soNo),
    profit_rate = sum(profit)/sum(amount)
  )
)
write.csv(common_paths_repeat,file='../output/common paths repeat.csv',row.names=FALSE)

######################################################################################################
###################################### assisted vs unassisted paths ##################################
######################################################################################################

# clean NA's in steps
sapply(path,function(x) sum(is.na(x)))
for (i in 1:6) {
  path[,paste0('step',i)] <- ifelse(is.na(path[,paste0('step',i)]),'',path[,paste0('step',i)])
}

# channel flag
channels <- unique(attribution$step1)
for (i in channels) {
  path[,i] <- ifelse(path$step1==i | path$step2==i | path$step3==i | path$step4==i | path$step5==i | path$step6==i,1,0)
}

# unique channels
path$channels <- 0
for (i in channels) {
  path$channels <- path$channels + path[,i]
}

# assistance flag
path$assisted <- ifelse(path$channels>1,1,0)

# summary
path %>% group_by(assisted) %>% summarize(
  conversions = n_distinct(soNo),
  avg_length = mean(visits),
  revenue = sum(amount),
  profit = sum(profit),
  gp_rate = sum(profit)/sum(amount)
) # assisted vs unassisted ~= 1:2

# assisted by last click
last_assist <- as.data.frame(
  path %>% group_by(assisted,last_step) %>% summarize(
    conversions = n_distinct(soNo),
    avg_length = mean(visits),
    revenue = sum(amount),
    profit = sum(profit),
    gp_rate = sum(profit)/sum(amount)
  )
)

write.csv(last_assist,file='../output/last_assist.csv')

############################################### break assisted paths by free & paid channels ##########################
path$paid_channels <- path$Affiliate + path$Branding + path$CSE + path$Display + path$LT + path$PLA + path$PPC + path$RLSA_LT + path$RLSA_Other + path$RLSA_PLA + path$RLSA_Torso + path$Torso
path$free_channels <- path$Direct + path$Email + path$Organic + path$Referral

path$assisted_channel_type <- ifelse(path$assisted == 0, 'none', 
                                     ifelse(path$last_step %in% c('Direct','Email','Organic','Referral'),
                                            ifelse(path$free_channels > 1 & path$paid_channels == 0,'free',
                                                   ifelse(path$free_channels == 1 & path$paid_channels > 0,'paid','both')
                                                   )
                                            ,ifelse(path$free_channels > 0 & path$paid_channels == 1,'free',
                                                    ifelse(path$free_channels == 0 & path$paid_channels > 1,'paid','both')
                                                    )
                                            )
                                     )

last_assist_2 <- as.data.frame(
  path %>% 
    group_by(last_step,assisted_channel_type) %>% 
      summarize(
        revenue = sum(amount)
      )
  )

last_assist_cast <- dcast(last_assist_2,last_step~assisted_channel_type,value.var='revenue')
last_assist_cast[is.na(last_assist_cast)] <- 0


# visualization
barchart(none+paid+free+both~last_step,data=last_assist_cast,stack=1)

last_assist_2 <- last_assist_2[order(last_assist_2$last_step,match(last_assist_2$assisted_channel_type,c('none','paid','free','both'))),]
ggplot(data = last_assist_2,aes(x=last_step,y=revenue,fill = assisted_channel_type)) +
  geom_bar(stat='identity',position = "fill")

write.csv(last_assist_cast,file='../output/last_assist_2.csv')

############################################## break down by new vs repeat, then assisted by free & paid

last_assist_3 <- as.data.frame(
  path %>% 
    group_by(new_order,last_step,assisted_channel_type) %>% 
    summarize(
      revenue = sum(amount)
    )
)

last_assist_cast_new <- dcast(subset(last_assist_3,new_order==1),last_step~assisted_channel_type,value.var='revenue')
last_assist_cast_repeat <- dcast(subset(last_assist_3,new_order==2),last_step~assisted_channel_type,value.var='revenue')

last_assist_cast_new[is.na(last_assist_cast_new)] <- 0
last_assist_cast_repeat[is.na(last_assist_cast_repeat)] <- 0

write.csv(last_assist_cast_new,file='../output/last_assist_2_new.csv')
write.csv(last_assist_cast_repeat,file='../output/last_assist_2_repeat.csv')


#################################################################################################################
###################################### graphs for deck -- high level breakdown ##################################
#################################################################################################################

# check line data
con <- dbConnect(MySQL(),user = 'xsxj045',password = 'xxxx',host = 'localhost',port = 10000)
order_info <- dbGetQuery(con,"
  select
    soNo,
  	count(distinct zoroNo) as line,
  	sum(qty) as qty,
  	sum(salesAmount) / sum(qty) as avg_item_price
  from nstrans.nsTrans_base
  where date between '2016-1-1' and '2016-1-31'
  and zoroNo like 'G%'
  group by 1               
")
path <- merge(path,order_info,by='soNo')

# output
write.csv(
  path %>% 
    group_by(ifelse(visits==1,'1-visit','multi-visits'),assisted) %>% 
    summarize(conversions = n_distinct(soNo),
              avg_length = mean(visits),
              sales = sum(amount),
              profit = sum(profit),
              AOS = mean(amount),
              lines = mean(line),
              avg_qty_per_line = sum(qty)/sum(line),
              avg_price = sum(amount)/sum(qty)       
    ),
  file = '../output/raw/high level breakdown.csv',
  row.names=F
)

# output -- by new vs repeat
write.csv(
  path %>% 
    group_by(new_order,ifelse(visits==1,'1-visit','multi-visits'),assisted) %>% 
    summarize(conversions = n_distinct(soNo),
              avg_length = mean(visits),
              sales = sum(amount),
              profit = sum(profit),
              AOS = mean(amount),
              lines = mean(line),
              avg_qty_per_line = sum(qty)/sum(line),
              avg_price = sum(amount)/sum(qty)       
    ),
  file = '../output/raw/high level breakdown2.csv',
  row.names=F
)

################################################## save data ############################################
save.image()

################################################### miscellaneous #######################################


