# 1
head(iris)
mean(subset(iris,Species=='virginica')$Sepal.Length)

# 2
apply(iris[,1:4],2,mean)

# 3
tapply(mtcars$mpg,mtcars$cyl,mean)
sapply(split(mtcars$mpg,mtcars$cyl),mean)
with(mtcars,tapply(mpg,cyl,mean))

# 4
test = with(mtcars,tapply(hp,cyl,mean))
abs(round(test[1] - test[3]))

