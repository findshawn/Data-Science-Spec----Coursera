library(caret)

set.seed(123)

# =========================== Read and Explore Data =============================
pml_training <- read.csv('pml-training.csv')
pml_testing <- read.csv('pml-testing.csv')

str(pml_training)
names(pml_training)
unique(pml_training$classe)
sum(complete.cases(pml_training))
pml_training[complete.cases(pml_training),160]

# select only relevant fields
sum(complete.cases(pml_testing))
nzv <- nzv(pml_training,saveMetrics = 1)
nzv2 <- nzv(pml_training)
nzv3 <- nzv(pml_testing,saveMetrics = 1)
nzv4 <- nzv(pml_testing)
pml_testing2 <- pml_testing[,c(7:11,37:49,60:68,84:86,102,113:124,140,151:160)]
sum(names(pml_testing)==names(pml_training))
pml_training2 <- pml_training[,c(7:11,37:49,60:68,84:86,102,113:124,140,151:160)]


# =========================train/validation/test split ===========================
inTrain <- createDataPartition(y=pml_training2$classe,p=0.7,list=0)
training <- pml_training2[inTrain,]
validation <- pml_training2[-inTrain,]
testing <- pml_testing2

# ========================= PCA EDA ============================================
cor(training[,-ncol(training)])

pc <- preProcess(training[,-ncol(training)],method='pca')
pc
summary(pc)
pc$numComp

pc2 <- prcomp(scale(training[,-ncol(training)]))
summary(pc2)

# ========================= modeling ============================================
# define predict function
fit_pred <- function(fit,testSet = validation) {
    pred = predict(fit,testSet);
    confusionMatrix(pred,testSet[['classe']])
}

# set seed
set.seed(123)

# control method: cross validation
ctrl <- trainControl(method="cv", number=10)

# knn (1081 s / 82 s)
system.time(fit_knn <- train(classe~.,data = training, method = 'knn', trControl=ctrl))
fit_pred(fit_knn) # 0.92 0.90
fit_knn

# knn with pca (239 s / 29 s)
system.time(fit_knn_pca <- train(classe~.,data = training, method = 'knn', preProcess='pca',trControl=ctrl))
fit_pred(fit_knn_pca) # 0.95 0.94
fit_knn_pca

# glm (error, 2-class outcomes only)
system.time(fit_glm_pca <- train(classe~.,data = training, method = 'glm', preProcess='pca'))

# decision tree (26 s / 11 s)
system.time(fit_rpart_pca <- train(classe~.,data = training, method = 'rpart', preProcess='pca', trControl=ctrl))
fit_pred(fit_rpart_pca) # 0.39 0.20
fit_rpart_pca

# decision tree bagged (400 s / 109 s)
system.time(fit_treebag_pca <- train(classe~.,data = training, method = 'treebag', preProcess='pca', trControl=ctrl))
fit_pred(fit_treebag_pca) # 0.96 0.94
fit_treebag_pca

# random forest (2594 s / 838 s)
system.time(fit_rf_pca <- train(classe~.,data = training, method = 'rf', preProcess='pca', trControl=ctrl))
fit_pred(fit_rf_pca) # 0.97 0.97
fit_rf_pca

# random forest cv 5 (383 s)
system.time(fit_rf_pca_cv5 <- train(classe~.,data = training, method = 'rf', preProcess='pca', trControl=trainControl(method='cv',number=5)))
fit_pred(fit_rf_pca_cv5) # 0.97 0.97
fit_rf_pca_cv5

# boosted tree (1188 s / 407 s)
system.time(fit_gbm_pca <- train(classe~.,data = training, method = 'gbm', preProcess='pca',trControl=ctrl))
fit_pred(fit_gbm_pca) # 0.82 0.78
fit_gbm_pca

# linear discriminant analysis (16 s / 5 s)
system.time(fit_lda_pca <- train(classe~.,data = training, method = 'lda', preProcess='pca',trControl=ctrl))
fit_pred(fit_lda_pca) # 0.52 0.40
fit_lda_pca

# naive bayes (913 s / 98 s)
system.time(fit_nb_pca <- train(classe~.,data = training, method = 'nb', preProcess='pca',trControl=ctrl))
fit_pred(fit_nb_pca) # 0.64 0.54
fit_nb_pca

# naive bayes repeated K fold cross validation (452 s)
train_control <- trainControl(method="repeatedcv", number=10, repeats=3)
system.time(fit_nb_pca_cv_repeat <- train(classe~.,data = training, method = 'nb', preProcess='pca',trControl=train_control))
fit_pred(fit_nb_pca_cv_repeat) # 0.64 0.54
fit_nb_pca_cv_repeat

# Support Vector Machine with Linear Kernel (669 s / 221 s)
system.time(fit_svm_pca <- train(classe~.,data = training, method = 'svmLinear', preProcess='pca',trControl=ctrl))
fit_pred(fit_svm_pca) # 0.58 0.47
fit_svm_pca

# Support Vector Machine with Polynomial Kernal (7981 s)
system.time(fit_svmpoly_pca <- train(classe~.,data = training, method = 'svmPoly', preProcess='pca',trControl=ctrl))
fit_pred(fit_svmpoly_pca) # 0.98 0.98
fit_svmpoly_pca

# Neural Network (1478 s / 363 s)
system.time(fit_nnet_pca <- train(classe~.,data = training, method = 'nnet', preProcess='pca',trControl=ctrl))
fit_pred(fit_nnet_pca) # 0.60 0.50
fit_nnet_pca

# ========================= Predict ============================================
predict(fit_rf_pca,testing)
predict(fit_svmpoly_pca,testing)

# ========================= Save ============================================
getwd()
save.image()
