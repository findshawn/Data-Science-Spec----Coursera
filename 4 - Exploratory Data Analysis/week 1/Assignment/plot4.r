
# ==================================================================
#                      Read Data
# ==================================================================

# read data
raw <- read.csv('household_power_consumption.txt',sep=';',stringsAsFactors = 0)
str(raw)

# filter data by date
df <- subset(raw,Date %in% c('1/2/2007','2/2/2007'))
    
# save df file
# write.csv(df,file='data.csv',row.names=F)
# df <- read.csv('data.csv',stringsAsFactors = 0)

# ==================================================================
#                      Prepare Data
# ==================================================================
str(df)
# date
df$Date <- as.Date(df$Date,format='%d/%m/%Y')

# datetime
df$dt <- strptime(paste(df$Date,df$Time),format="%Y-%m-%d %H:%M:%S")

# chr to num
df$Global_active_power <- as.numeric(df$Global_active_power)
df$Global_reactive_power <- as.numeric(df$Global_reactive_power)
df$Voltage <- as.numeric(df$Voltage)
df$Global_intensity <- as.numeric(df$Global_intensity)
df$Sub_metering_1 <- as.numeric(df$Sub_metering_1)
df$Sub_metering_2 <- as.numeric(df$Sub_metering_2)

# ==================================================================
#                      Plots
# ==================================================================
par(mfcol=c(2,2))

# plot 1
plot(y=df$Global_active_power,x=df$dt,type='l',main='',xlab='',ylab='Global Active Power')

# plot 2
plot(y=df$Global_active_power,x=df$dt,type='n',main='',xlab='',ylab='Energy sub metering',ylim=c(0,38))
lines(y=df$Sub_metering_1,x=df$dt,type='l')
lines(y=df$Sub_metering_2,x=df$dt,type='l',col='red')
lines(y=df$Sub_metering_3,x=df$dt,type='l',col='blue')
legend('topright',legend=c('Sub_metering_1','Sub_metering_2','Sub_metering_3'),lwd=1,col=c(1,2,4),y.intersp=0.8,seg.len=1.5,bty='n',cex=0.8)

# plot 3
plot(y=df$Voltage,x=df$dt,type='l',main='',xlab='datetime',ylab='Voltage')

# plot 4
plot(y=df$Global_reactive_power,x=df$dt,type='l',main='',xlab='datetime',ylab='Global_reactive_power')

# create graph file
dev.copy(png,file = 'plot4.png',width=480,height=480)

# close png device
dev.off()
