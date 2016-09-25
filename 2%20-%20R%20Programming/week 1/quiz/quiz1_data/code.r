df <- read.csv("hw1_data.csv")

df[1:2,]

tail(df,2)

df[47,"Ozone"]

df2 <- subset(df, Ozone>31 & Temp > 90)
mean(df2$Solar.R)

mean(df$Temp[df$Month==6])

max(df$Ozone[df$Month==5],na.rm=1)
