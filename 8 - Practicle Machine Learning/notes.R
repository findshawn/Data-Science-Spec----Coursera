# week 1

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
