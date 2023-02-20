#Project Report Exercise 1

#Read the data set

library(readxl)
data_set = read.csv("C:/TimeDataSerriesProjects/ProjectReport/dataSet8.csv")

x = data_set$x

#check for NAs -> there are no such
sum(is.na(x))

plot(x,type = "l")

qqnorm(x)
qqline(x)
jbTest(x)
### --> Gaussian Distributed

mean(x) # = 4.335771
sd(x) # = 5.722942


#Fit a sine function to the data because it appears that function is periodic
#standardize  data

sd_dataset = sd(x)
std_data = x/sd_dataset


#Function
idx = 1:length(std_data)

#Data looks like annual trend --> divide with 365.25

sineFun <- function(param) # function of a parameter vector param
{
  fun = param[1] + param[2]*sin(((idx - param[3])*2*pi)/365.25)
  #error 
  epsilon = std_data - fun
  return(epsilon)
}

library(pracma)

#Parameter guess
param0 = c(0,0,8,0)
paramOptimal = lsqnonlin(sineFun,param0)

trend = paramOptimal$x[1] + paramOptimal$x[2]*sin(((idx - paramOptimal$x[3])*2*pi)/365.25)
trend = trend*sd_dataset

plot(x,type="l")
lines(trend,col="red")


#Using the sine function we cannot see an precise fitting because there is too frequently changing amplitude 

#Detrend --> epsilon = temperature - trend
epsilon = x - trend
#This doesn`t look like a perfect i.i.d. model


acf(epsilon)
pacf(epsilon) #more than 5 significant values, but we will go with AR(5) 


#Let's go with an AR(5) model
#Compute LSE
X = matrix(0,nrow= (length(epsilon)-5) , ncol=6)
X[,1] = 1
X[,2] = epsilon[5:(length(epsilon)-1)]
X[,3] = epsilon[4:(length(epsilon)-2)]
X[,4] = epsilon[3:(length(epsilon)-3)]
X[,5] = epsilon[2:(length(epsilon)-4)]
X[,6] = epsilon[1:(length(epsilon)-5)]
y = epsilon[6:length(epsilon)]

par6 = solve(t(X)%*%X)%*%t(X)%*%y
#We can ignore the first component of the parameter vector

#Residuals are always the difference between reality and model
residuals = y - X%*%par6
sd_residuals = sd(residuals)
#the MEAN should be zero anyway


#Calculation of the future trend
mu = 0;
sd_epsilon = sd(epsilon)
idx_future = (length(x)+1):(length(x)+365)
trend_future = paramOptimal$x[1] + paramOptimal$x[2]*sin(((idx_future - paramOptimal$x[3])*2*pi)/365.25)
trend_future = trend_future*sd_dataset

sim = numeric(length(x)+6)

#We have our AR(5) process here
for (k in 6:length(sim))
{
  sim[k] = par6[2]*sim[k-1] + par6[3]*sim[k-2]+ par6[4]*sim[k-3]+ par6[5]*sim[k-4]+ par6[6]*sim[k-5] + rnorm(806,0,sd_residuals) 
}


#plot(x,type="l")
#lines(sim,type="l",col="red")

#Then we have to add the seasonal trend to each column
for (k in 1:length(sim))
{
  sim[k] = sim[k] + trend_future
}


#We cut the 5 day lag
x = x[6:length(x)]

#We plot our simulation
plot(x,type="l")
lines(sim,type="l", col="red")





