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

set.seed(123)

# knn (1081 s)
system.time(fit_knn <- train(classe~.,data = training, method = 'knn'))
fit_pred(fit_knn) # 0.92 0.90

# knn with pca (239 s)
system.time(fit_knn_pca <- train(classe~.,data = training, method = 'knn', preProcess='pca'))
fit_pred(fit_knn_pca) # 0.95 0.94

# glm (error)
system.time(fit_glm_pca <- train(classe~.,data = training, method = 'glm', preProcess='pca'))

# decision tree (26 s)
system.time(fit_rpart_pca <- train(classe~.,data = training, method = 'rpart', preProcess='pca'))
fit_pred(fit_rpart_pca) # 0.39 0.20

# decision tree bagged (400 s ?)
system.time(fit_treebag_pca <- train(classe~.,data = training, method = 'treebag', preProcess='pca'))
fit_pred(fit_treebag_pca) # 0.96 0.94

# random forest (2594 s)
system.time(fit_rf_pca <- train(classe~.,data = training, method = 'rf', preProcess='pca'))
fit_pred(fit_rf_pca) # 0.97 0.97

# boosted tree (1188 s)
system.time(fit_gbm_pca <- train(classe~.,data = training, method = 'gbm', preProcess='pca'))
fit_pred(fit_gbm_pca) # 0.82 0.78

# linear discriminant analysis (16 s)
system.time(fit_lda_pca <- train(classe~.,data = training, method = 'lda', preProcess='pca'))
fit_pred(fit_lda_pca) # 0.52 0.40

# naive bayes (913 s)
system.time(fit_nb_pca <- train(classe~.,data = training, method = 'nb', preProcess='pca'))
fit_pred(fit_nb_pca) # 0.64 0.54

# naive bayes bootstrap (509 s or 4802 s)
train_control <- trainControl(method="boot", number=10)
system.time(fit_nb_pca_boot <- train(classe~.,data = training, method = 'nb', preProcess='pca',trControl=train_control))
fit_pred(fit_nb_pca_boot) # 0.64 0.54

# naive bayes K fold cross validation
train_control <- trainControl(method="cv", number=10)
grid <- expand.grid(.fL=c(0), .usekernel=c(FALSE))
system.time(fit_nb_pca_cv <- train(classe~.,data = training, method = 'nb', preProcess='pca',trControl=train_control,tuneGrid=grid))

# naive bayes repeated K fold cross validation (452 s)
train_control <- trainControl(method="repeatedcv", number=10, repeats=3)
system.time(fit_nb_pca_cv_repeat <- train(classe~.,data = training, method = 'nb', preProcess='pca',trControl=train_control))
fit_pred(fit_nb_pca_cv_repeat) # 0.64 0.54

# Support Vector Machine with Linear Kernel (669 s)
system.time(fit_svm_pca <- train(classe~.,data = training, method = 'svmLinear', preProcess='pca'))
fit_pred(fit_svm_pca) # 0.58 0.47

# Neural Network (1478 s)
system.time(fit_nnet_pca <- train(classe~.,data = training, method = 'nnet', preProcess='pca'))
fit_pred(fit_nnet_pca) # 0.60 0.50

# ========================= Predict ============================================
predict(fit_rf_pca,testing)
# ========================= Save ============================================
getwd()
save.image()
