# ================================= Q1 ===================================
library(ElemStatLearn)
data(vowel.train)
data(vowel.test)
vowel.train$y <- as.factor(vowel.train$y)
vowel.test$y <- as.factor(vowel.test$y)
set.seed(33833)

fit1 <- train(y~.,data=vowel.train,method='rf')
fit2 <- train(y~.,data=vowel.train,method='gbm')

pred1 <- predict(fit1,vowel.test)
sum(pred1==vowel.test$y)/nrow(vowel.test)
pred2 <- predict(fit2,vowel.test)
sum(pred2==vowel.test$y)/nrow(vowel.test)

# when two preditions agree
agree <- pred1==pred2
sum(pred1[agree] == vowel.test$y[agree]) / sum(agree)

# ================================= Q2 ===================================
library(caret)
library(gbm)
set.seed(3433)
library(AppliedPredictiveModeling)
data(AlzheimerDisease)
adData = data.frame(diagnosis,predictors)
inTrain = createDataPartition(adData$diagnosis, p = 3/4)[[1]]
training = adData[ inTrain,]
testing = adData[-inTrain,]

# train
set.seed(62433)
fit_rf <- train(diagnosis~.,data=training,method='rf')
fit_gbm <- train(diagnosis~.,data=training,method='gbm')
fit_lda <- train(diagnosis~.,data=training,method='lda')

# stacked model train
pred_rf_train <- predict(fit_rf,training)
pred_gbm_train <- predict(fit_gbm,training)
pred_lda_train <- predict(fit_lda,training)
stacked_train <- data.frame(
    diagnosis=training$diagnosis, 
    pred_rf=pred_rf_train,
    pred_gbm=pred_gbm_train,
    pred_lda=pred_lda_train
)
fit_stacked <- train(diagnosis~., data=stacked_train, method='rf')

# predict
pred_rf_test <- predict(fit_rf,testing)
pred_gbm_test <- predict(fit_gbm,testing)
pred_lda_test <- predict(fit_lda,testing)

# stacked model predict
stacked_test <- data.frame(
    diagnosis=testing$diagnosis, 
    pred_rf=pred_rf_test,
    pred_gbm=pred_gbm_test,
    pred_lda=pred_lda_test
)
pred_stacked <- predict(fit_stacked,stacked_test) 

# accuracy
sum(pred_rf_test==testing$diagnosis) / nrow(testing) # 79%
sum(pred_gbm_test==testing$diagnosis) / nrow(testing) # 79%
sum(pred_lda_test==testing$diagnosis) / nrow(testing) # 77%
sum(pred_stacked==testing$diagnosis) / nrow(testing) # 84%

# ================================= Q3 ===================================
set.seed(3523)
library(AppliedPredictiveModeling)
data(concrete)
inTrain = createDataPartition(concrete$CompressiveStrength, p = 3/4)[[1]]
training = concrete[ inTrain,]
testing = concrete[-inTrain,]

set.seed(233)
names(training)
fit <- train(CompressiveStrength~.,data=training,method='lasso')
?plot.enet
?enet
e <- enet(x=as.matrix(subset(training,select=-CompressiveStrength)), y=training$CompressiveStrength, lambda=0)
plot.enet(e)

# ================================= Q4 ===================================
library(lubridate) # For year() function below
dat = read.csv("gaData.csv")
training = dat[year(dat$date) < 2012,]
testing = dat[(year(dat$date)) > 2011,]
tstrain = ts(training$visitsTumblr)

library(forecast)
?bats
fit <- bats(tstrain)
fcast <- forecast(fit,h=nrow(testing))
fcast
names(fcast)
fcast$lower
fcast$upper
testing$visitsTumblr
sum(testing$visitsTumblr >= fcast$lower[,2] & testing$visitsTumblr <= fcast$upper[,2]) / nrow(testing)


# ================================= Q5 ===================================
set.seed(3523)
library(AppliedPredictiveModeling)
data(concrete)
library(caret)
inTrain = createDataPartition(concrete$CompressiveStrength, p = 3/4)[[1]]
training = concrete[ inTrain,]
testing = concrete[-inTrain,]

set.seed=325
library(e1071)
names(training)
fit <- svm(CompressiveStrength~.,data=training)
pred <- predict(fit,testing)
# RMSE
sqrt(sum((pred-testing$CompressiveStrength)^2)/nrow(testing))
