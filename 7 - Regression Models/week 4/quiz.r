# Q1
library(MASS)
data(shuttle)
?shuttle
head(shuttle)
str(shuttle)
shuttle$use <- ifelse(shuttle$use=='auto',1,0)
shuttle$wind <- ifelse(shuttle$wind=='head',1,0)
fit <- glm(use ~ wind, family = 'binomial', data = shuttle)
summary(fit)
exp(fit$coefficients[2])

# Q2
fit <- glm(use ~ wind + magn, family = 'binomial', data = shuttle)
summary(fit)
exp(fit$coefficients[2])

# Q4
data("InsectSprays")
str(InsectSprays)
fit<- glm(count~factor(spray),family="poisson",data=InsectSprays)
summary(fit)
1/exp(fit$coefficients[2])
