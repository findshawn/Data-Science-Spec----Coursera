# ================================ week 1 ======================================

library(caret)
library(kernlab)
data(spam)
inTrain <- createDataPartition(y=spam$type,p=0.75,list=FALSE)
training <- spam[inTrain,]
testing <- spam[-inTrain,]
dim(training)
set.seed(32343)
fit <- train(type ~., data=training, method='glm')
fit
fit$finalModel
predictions <- predict(fit,newdata=testing)
predictions
confusionMatrix(predictions,testing$type)

# ================================== week 3 ================================

# Tree

library(caret)
data(iris)
intrain <- createDataPartition(y=iris$Species,p=0.7,list=FALSE)
training <- iris[intrain,]
testing <- iris[-intrain,]

fit <- train(Species~.,method='rpart',data=training)
fit$finalModel

plot(fit$finalModel, uniform = 1)
text(fit$finalModel, use.n=1, all=1, cex=.8)
library(rattle)
fancyRpartPlot(fit$finalModel)

predict(fit,newdata=testing)

# Random Forests

library(caret)
library(ggplot2)
data(iris)
intrain <- createDataPartition(y=iris$Species,p=0.7,list=FALSE)
training <- iris[intrain,]
testing <- iris[-intrain,]

fit <- train(Species~.,method='rf',data=training,prox=1)
fit
getTree(fit$finalModel,k=2)

pred <- predict(fit,testing)
testing$predRight <- pred==testing$Species
table(pred,testing$Species)
qplot(Petal.Width,Petal.Length,color=predRight,data=testing)

# Boosting

library(ISLR)
data(Wage)
library(caret)
library(ggplot2)
Wage <- subset(Wage,select=-c(logwage))
inTrain <- createDataPartition(y=Wage$wage,p=0.7,list=0)
training <- Wage[inTrain,]; testing <- Wage[-inTrain,]

fit <- train(wage~.,data=training,method='gbm',verbose=0)
fit

qplot(predict(fit,testing),wage,data=testing)

# Model Based (Linear Discriminative Analysis and Naive Bayes)

library(caret)
library(ggplot2)
data(iris)
intrain <- createDataPartition(y=iris$Species,p=0.7,list=FALSE)
training <- iris[intrain,]
testing <- iris[-intrain,]

fit1 <- train(Species~.,method='lda',data=training)
fit2 <- train(Species~.,method='nb',data=training)
table(predict(fit1,testing),predict(fit2,testing))

# ================================ week 4 ======================================

# Ensemble

library(ISLR)
data(Wage)
library(ggplot2)
library(caret)
Wage <- subset(Wage,select=-logwage)

inBuild <- createDataPartition(y=Wage$wage,p=0.7,list=0)
buildData <- Wage[inBuild,]
validation <- Wage[-inBuild,]
inTrain <- createDataPartition(y=buildData$wage,p=.7,list=0)
training <- buildData[inTrain,]
testing <- buildData[-inTrain,]

fit1 <- train(wage~.,data=training,method='glm')
fit2 <- train(
    wage~.,data=training,method='rf',
    trControl = trainControl(method='cv'),
    number=3
)
pred1<-predict(fit1,testing)
pred2<-predict(fit2,testing)

predDF <- data.frame(pred1,pred2,wage=testing$wage)
combFit <- train(wage~.,data=predDF,method='gam')
combPred <- predict(combFit,predDF)

sqrt(sum((pred1-testing$wage)^2))
sqrt(sum((pred2-testing$wage)^2))
sqrt(sum((combPred-testing$wage)^2))

pred1V <- predict(fit1,validation)
pred2V <- predict(fit2,validation)
predVDF <- data.frame(pred1=pred1V,pred2=pred2V,wage=validation$wage)
combPredV <- predict(combFit,newdata = predVDF)

sqrt(sum((pred1V-validation$wage)^2))
sqrt(sum((pred2V-validation$wage)^2))
sqrt(sum((combPredV-validation$wage)^2))

# Forecasting (time series)
library(quantmod)
from.dat <- as.Date('01/01/08',format='%m/%d/%y')
to.dat <- as.Date('12/31/13',format='%m/%d/%y')
getSymbols('GOOG',src='google',from=from.dat, to=to.dat) 
head(GOOG,30) # NA values

mGoog <- to.monthly(GOOG) # Error
googOpen <- to.monthly(GOOG[,1])[,1]
ts1 <- ts(googOpen,frequency=12)
plot(ts1,xlab='years+1',ylab='GOOG')
plot(decompose(ts1),xlab='years+1')

ts1Train <- window(ts1,start=1,end=5)
ts1Test <- window(ts1,start=5,end=(7-0.01))

plot(ts1Train)
library(forecast)
lines(ma(ts1Train,order=3),col='red')

ets1 <- ets(ts1Train,model='MMM')
fcast <- forecast(ets1)
plot(fcast)
lines(ts1Test,col='red')
accuracy(fcast,ts1Test)

# Unsupervised Prediction (Clustering)
library(caret)
library(ggplot2)
data(iris)
intrain <- createDataPartition(y=iris$Species,p=0.7,list=FALSE)
training <- iris[intrain,]
testing <- iris[-intrain,]

kMeans1 <- kmeans(subset(training,select=-Species),centers=3)
training$clusters <- as.factor(kMeans1$cluster)
qplot(Petal.Width,Petal.Length,colour=clusters,data=training)
table(training$clusters,training$Species)

fit <- train(clusters~.,data=subset(training,select=-Species),method='rpart')
table(predict(fit,training),training$Species)
table(predict(fit,testing),testing$Species)

