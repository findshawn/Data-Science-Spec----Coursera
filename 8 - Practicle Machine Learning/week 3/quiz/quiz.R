# ======================================= Q1 ===================================
library(AppliedPredictiveModeling)
data(segmentationOriginal)
library(caret)
training <- subset(segmentationOriginal,Case=='Train',select=-Case)
testing <- subset(segmentationOriginal,Case=='Test',select=-Case)

set.seed(125)
fit <- train(Class~.,data=training,method='rpart')
library(rattle)
fancyRpartPlot(fit$finalModel)

# ======================================= Q3 ===================================
library(pgmm)
data(olive)
olive = olive[,-1]
library(caret)

fit <- train(Area~.,data=olive,method='rpart')
newdata = as.data.frame(t(colMeans(olive)))
pred <- predict(fit,newdata)

# ======================================= Q4 ===================================
library(ElemStatLearn)
data(SAheart)
set.seed(8484)
train = sample(1:dim(SAheart)[1],size=dim(SAheart)[1]/2,replace=F)
trainSA = SAheart[train,]
testSA = SAheart[-train,]

set.seed(13234)
str(trainSA)
trainSA$chd <- as.factor(trainSA$chd)
testSA$chd <- as.factor(testSA$chd)
fit <- train(chd~age+alcohol+obesity+tobacco+typea+ldl,data=trainSA,method='glm',family='binomial')
missClass = function(values,prediction){sum(((prediction > 0.5)*1) != values)/length(values)}
missClass(testSA$chd,predict(fit,testSA,type='prob')[,2])
missClass(trainSA$chd,predict(fit,trainSA,type='prob')[,2])

# ======================================= Q5 ===================================
library(ElemStatLearn)
data(vowel.train)
data(vowel.test)
vowel.train$y <- as.factor(vowel.train$y)
vowel.test$y <- as.factor(vowel.test$y)
set.seed(33833)
fit <- train(y~.,data=vowel.train,method='rf')
fit2 <- train(y~.,data=vowel.train,method='rf',prox=1)
varImp(fit)
varImp(fit2)
