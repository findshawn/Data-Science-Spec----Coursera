# ========================================================================================
#                                  Download Data
# ========================================================================================

download.file(
    'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip',
    'raw.zip'
)
unzip('raw.zip')

# ========================================================================================
#                                  Read Data
# ========================================================================================
# feature names
features <- read.table("UCI HAR Dataset/features.txt")

# activity lookup table
activity_lables <- read.table("UCI HAR Dataset/activity_labels.txt")

# train/test data
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")

# subject id
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")

# ========================================================================================
# 1.Merges the training and the test sets to create one data set
# ========================================================================================

df <- rbind(X_train,X_test)

# ========================================================================================
# 2.Extracts only the measurements on the mean and standard deviation for each measurement
# ========================================================================================

# column names
names(df) <- features[[2]]

# regex match 'mean()' or 'std()'
grep('(mean|std)\\(\\)',names(df),value=T)
df <- df[,grep('(mean|std)\\(\\)',names(df))]

# ========================================================================================
# 3.Uses descriptive activity names to name the activities in the data set
# ========================================================================================

# combine y data from train and test
y <- rbind(y_train,y_test)

# add labels
y <- merge(y,activity_lables,by='V1',all.x=1)

# add to df
df$Activity <- y[[2]]


# combine subject data from train and test
subject <- rbind(subject_train,subject_test)

# add to df
df$Subject <- subject[[1]]

# ========================================================================================
# 4.Appropriately labels the data set with descriptive variable names.
# ========================================================================================
names(df)

# remove parentheses
names(df) <- gsub('\\(|\\)','',names(df))

# remove dashes
names(df) <- gsub('-','',names(df))

# first character: time domain signal v.s. frequency domain signal
names(df) <- gsub('^t','Time-',names(df))
names(df) <- gsub('^f','Frequency-',names(df))

# Body
names(df) <- gsub('Body','Body-',names(df))

# Gravity
names(df) <- gsub('Gravity','Gravity-',names(df))

# Acceleration
names(df) <- gsub('Acc','Acceleration-',names(df))

# Gyration
names(df) <- gsub('Gyro','Gyration-',names(df))

# Jerk Signals
names(df) <- gsub('Jerk','Jerk-',names(df))

# Magnitude
names(df) <- gsub('Mag','Magnitude-',names(df))

# mean, std
names(df) <- gsub('mean','mean-',names(df))
names(df) <- gsub('std','std-',names(df))
names(df) <- gsub('-$','',names(df))

# ========================================================================================
# 5.From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
# ========================================================================================
library(dplyr)

tidydf <- df %>% group_by(Subject,Activity) %>% summarise_each(funs(mean))

# output
write.table(tidydf,file='tidydf.txt',sep='\t',row.names=F)

# ========================================================================================
#                                     Save
# ========================================================================================
save.image()
