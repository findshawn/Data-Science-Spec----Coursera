# read data
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

# explore data
str(NEI)
unique(NEI$Pollutant) # PM25 only
str(SCC)

############################## Q1 ######################################################
# Have total emissions from PM2.5 decreased in the United States from 1999 to 2008? 
# Using the base plotting system, make a plot showing the total PM2.5 emission from all sources for each of the years 1999, 2002, 2005, and 2008.

# data
Q1data <- tapply(NEI$Emissions,NEI$year,sum)

# plot
barplot(Q1data, main='Total PM2.5 Emission by Year', xlab='Year', ylab='PM2.5 Emission in Tons')

# png
dev.copy(png,file = 'plot1.png',width=480,height=480)

# close png device
dev.off()

############################## Q2 ######################################################
# Have total emissions from PM2.5 decreased in the Baltimore City, Maryland (fips == "24510") from 1999 to 2008? 
# Use the base plotting system to make a plot answering this question.

# data
NEI_Baltimore <- subset(NEI,fips=='24510')
Q2data <- tapply(NEI_Baltimore$Emissions,NEI_Baltimore$year,sum)

# plot
barplot(Q2data, main='Total PM2.5 Emission by Year -- Baltimore City', xlab='Year', ylab='PM2.5 Emission in Tons')

# png
dev.copy(png,file = 'plot2.png',width=480,height=480)

# close png device
dev.off()

############################## Q3 ######################################################
# Of the four types of sources indicated by the type (point, nonpoint, onroad, nonroad) variable, 
# which of these four sources have seen decreases in emissions from 1999-2008 for Baltimore City? 
# Which have seen increases in emissions from 1999-2008? 
# Use the ggplot2 plotting system to make a plot answer this question.

library(ggplot2)
NEI_Baltimore <- subset(NEI,fips=='24510')

# plot
ggplot(NEI_Baltimore,aes(factor(year),Emissions)) +
    geom_boxplot() +
    facet_grid(.~type) +
    coord_cartesian(ylim = c(0,60)) +
    labs(title='PM2.5 Emission -- Baltimore City',x='type + year',y='PM2.5 Emission in Tons')

# png
dev.copy(png,file = 'plot3.png',width=480,height=480)

# close png device
dev.off()

############################## Q4 ######################################################
# Across the United States, how have emissions from coal combustion-related sources changed from 1999-2008?

# explore which column to use to filter 'coal combustion-related sources'
# EI.Sector
unique(SCC$EI.Sector)
SCC$EI.Sector[grep('coal',SCC$EI.Sector,ignore.case=TRUE)]
# Short.Name
unique(SCC$Short.Name)
SCC$Short.Name[grep('coal',SCC$Short.Name,ignore.case=TRUE)]
# SCC.Level.One
unique(SCC$SCC.Level.One)
grep('coal',SCC$SCC.Level.One,ignore.case=TRUE)

# use EI.Sector
SCC_coalComb <- SCC[grep('coal',SCC$EI.Sector,ignore.case=TRUE),]

# check uniqueness of SCC
length(unique(NEI$SCC)) == nrow(NEI)
length(unique(SCC$SCC)) == nrow(SCC)

# factor -> char
SCC_coalComb$SCC <- as.character(SCC_coalComb$SCC)

# merge to prepare data
Q4data <- merge(NEI,SCC_coalComb,by='SCC')

# plot
library(ggplot2)
library(gridExtra)

# overview
plot4_1 <- ggplot(Q4data,aes(factor(year),Emissions)) +
    geom_boxplot() +
    labs(title='PM2.5 Emission -- Coal Combustion-related Sources',x='Year',y='PM2.5 Emission in Tons')

# detail view
plot4_2 <- ggplot(Q4data,aes(factor(year),Emissions)) +
    geom_boxplot() +
    coord_cartesian(ylim = c(0,30)) +
    labs(title='Zoom-in View',x='Year',y='PM2.5 Emission in Tons')

# combine plots
grid.arrange(plot4_1, plot4_2, ncol=2)

# png
dev.copy(png,file = 'plot4.png',width=880,height=480)

# close png device
dev.off()

############################## Q5 ######################################################
# How have emissions from motor vehicle sources changed from 1999-2008 in Baltimore City?
NEI_Baltimore <- subset(NEI,fips=='24510')

# explore which column to use to filter 'coal combustion-related sources'
# EI.Sector
unique(SCC$EI.Sector)
SCC$EI.Sector[grep('motor',SCC$EI.Sector,ignore.case=TRUE)]
# Short.Name
unique(SCC$Short.Name)
SCC$Short.Name[grep('motor',SCC$Short.Name,ignore.case=TRUE)]
# SCC.Level.One
unique(SCC$SCC.Level.One)
grep('motor',SCC$SCC.Level.One,ignore.case=TRUE)

# use Short.Name
SCC_motor <- SCC[grep('motor',SCC$Short.Name,ignore.case=TRUE),]

# factor -> char
SCC_motor$SCC <- as.character(SCC_motor$SCC)

# merge to prepare data
Q5data <- merge(NEI,SCC_motor,by='SCC')

# plot
library(ggplot2)
library(gridExtra)

# overview
plot5_1 <- ggplot(Q5data,aes(factor(year),Emissions)) +
    geom_boxplot() +
    labs(title='PM2.5 Emission -- Motor Vehicle Sources',x='Year',y='PM2.5 Emission in Tons')

# detail view
plot5_2 <- ggplot(Q4data,aes(factor(year),Emissions)) +
    geom_boxplot() +
    coord_cartesian(ylim = c(0,25)) +
    labs(title='Zoom-in View',x='Year',y='PM2.5 Emission in Tons')

# combine plots
grid.arrange(plot5_1, plot5_2, ncol=2)

# png
dev.copy(png,file = 'plot5.png',width=880,height=480)

# close png device
dev.off()

############################## Q6 ######################################################
# Compare emissions from motor vehicle sources in Baltimore City with emissions from motor vehicle sources in Los Angeles County, California (fips == "06037"). 
# Which city has seen greater changes over time in motor vehicle emissions?

# location
NEI_Baltimore_LA <- subset(NEI,fips %in% c('24510','06037'))

# use Short.Name
SCC_motor <- SCC[grep('motor',SCC$Short.Name,ignore.case=TRUE),]

# factor -> char
SCC_motor$SCC <- as.character(SCC_motor$SCC)

# merge to prepare data
Q6data <- merge(NEI_Baltimore_LA,SCC_motor,by='SCC')

# location factor
Q6data$loc <- factor(Q6data$fips,levels=c('24510','06037'),labels=c('Baltimore','LA'))

# plot
library(ggplot2)
library(gridExtra)
library(dplyr)

# barplot data
Q6data_bar <- Q6data %>% group_by(loc,year) %>% summarize(
    Total_Emissions = sum(Emissions)
)

# barplot
plot6_bar <- ggplot(Q6data_bar,aes(x=factor(year),y=Total_Emissions)) +
    geom_bar(stat="identity") +
    facet_grid(loc~.) +
    labs(title='Total Emissions',x='Year',y='PM2.5 Emission in Tons')


# boxplot
plot6_box <- ggplot(Q6data,aes(factor(year),Emissions)) +
    geom_boxplot() +
    facet_grid(loc~.) +
    labs(title='Boxplot View',x='Year',y='PM2.5 Emission in Tons') +
    coord_cartesian(ylim = c(0,20))
    
# combine plots
grid.arrange(plot6_bar, plot6_box, ncol=2)

# png
dev.copy(png,file = 'plot6.png',width=880,height=480)

# close png device
dev.off()


# save data
save.image()
