# Q1

library(AppliedPredictiveModeling)
data(AlzheimerDisease)
adData = data.frame(diagnosis,predictors)
trainIndex = createDataPartition(diagnosis, p = 0.50,list=FALSE)
training = adData[trainIndex,]
testing = adData[-trainIndex,]


# Q2

library(AppliedPredictiveModeling)
data(concrete)
library(caret)
set.seed(1000)
inTrain = createDataPartition(mixtures$CompressiveStrength, p = 3/4)[[1]]
training = mixtures[ inTrain,]
testing = mixtures[-inTrain,]
library(ggplot2)
library(Hmisc)
training$index <- row.names(training)
qplot(x=index,y=CompressiveStrength,data=training)
qplot(x=index,y=CompressiveStrength,data=training,color=cut2(FlyAsh,g=4))
qplot(x=index,y=CompressiveStrength,data=training,color=cut2(Age,g=4))

# Q3

hist(training$Superplasticizer)

# Q4
library(caret)
library(AppliedPredictiveModeling)
set.seed(3433)
data(AlzheimerDisease)
adData = data.frame(diagnosis,predictors)
inTrain = createDataPartition(adData$diagnosis, p = 3/4)[[1]]
training = adData[ inTrain,]
testing = adData[-inTrain,]

str(training)
vars <- training[,grepl('^IL',names(training))]
pc <- preProcess(vars,method='pca',thresh = 0.8)
pc
pc2 <- prcomp(scale(vars))
summary(pc2)

# Q5
training2 <- data.frame(training$diagnosis,vars)
names(training2)[1] <- 'diagnosis'
fit1 <- train(diagnosis ~ ., method='glm', data=training2)
fit2 <- train(diagnosis ~ ., method='glm', data=training2, preProcess='pca',trControl=trainControl(preProcOptions=list(thresh = 0.8)))
confusionMatrix(testing$diagnosis,predict(fit1,testing))
confusionMatrix(testing$diagnosis,predict(fit2,testing))
