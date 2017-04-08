# Q1
x <- c(0.61, 0.93, 0.83, 0.35, 0.54, 0.16, 0.91, 0.62, 0.62)
y <- c(0.67, 0.84, 0.6, 0.18, 0.85, 0.47, 1.1, 0.65, 0.36)
fit <- lm(y~x)
summary(fit)

# Q3
data(mtcars)
fit <- lm(mpg~wt,data=mtcars)
summary(fit)
predict(fit,newdata = data.frame(wt=mean(mtcars$wt)),interval = 'confidence')
predict(fit,newdata = data.frame(wt=mean(mtcars$wt)),interval = 'prediction')

# Q5
predict(fit,newdata = data.frame(wt=3),interval = 'prediction')

# Q6
fit <- lm(mpg~I(wt/2),data=mtcars)
confint(fit)

# Q9
fit <- lm(mpg~wt,data=mtcars)
summary(fit)
