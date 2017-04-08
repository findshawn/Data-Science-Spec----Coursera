# Q1
data(mtcars)
?mtcars
summary(lm(mpg ~ factor(cyl) + wt, data = mtcars))

# Q2
summary(lm(mpg ~ factor(cyl) + wt, data = mtcars))
summary(lm(mpg ~ factor(cyl), data = mtcars))

# Q3
fit1 = lm(mpg ~ factor(cyl) + wt, data = mtcars)
fit2 = lm(mpg ~ factor(cyl) * wt, data = mtcars)
anova(fit1,fit2)

# Q4
lm(mpg ~ I(wt * 0.5) + factor(cyl), data = mtcars)

# Q5
x <- c(0.586, 0.166, -0.042, -0.614, 11.72)
y <- c(0.549, -0.026, -0.127, -0.751, 1.344)
hatvalues(lm(y~x))

# Q6
x <- c(0.586, 0.166, -0.042, -0.614, 11.72)
y <- c(0.549, -0.026, -0.127, -0.751, 1.344)
hatvalues(lm(y~x))
influence.measures(lm(y~x))
