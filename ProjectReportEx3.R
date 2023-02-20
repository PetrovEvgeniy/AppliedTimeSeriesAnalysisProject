#Exercise 3

#Definition that we are using the following libraries 

library(readxl)
library(fBasics)

#Since we considered Varta to be more riskier,
#we would choose to gamble a bit and expect increasing prices
#on the safer stock alternative - Nestle

#Load the raw price data from the Nestle stock prices
nestle_raw = read.csv("C:/TimeDataSerriesProjects/ProjectReport/Nestle.csv")


#We would be again using close prices

nestle = as.numeric(nestle_raw$Close)

#although we already we did that in the previous exercise
#we are going check for missing values (NAs)

nestle_missing_values_exist = sum(is.na(nestle)) != 0

#Conclusion: no NAs

#Plot Nestle stock prices
plot(nestle,type="l",col="blue")

#Lets check out the returns, again we use log function because we are using stock prices data
returns_nestle = diff(log(nestle))

#Plot to see how the non-filtered "outlier" data looks
plot(returns_nestle,type="l",col="blue")

#We see that there again there are as expected outliers that we have to "kick out"

#Outlier elimination

#Calculate standard deviation
standard_dev_nestle = sd(returns_nestle) #0.01127

#Find boundary (Since we don't want to be so strict about outliers we are going to choose the constant 3 instead of 2.5)
boundary_nestle = 3.0*standard_dev_nestle

#Number of outliers
nestle_outliers_count = sum(abs(returns_nestle) > boundary_nestle)

filtered_nestle_returns = returns_nestle[abs(returns_nestle) < boundary_nestle]

returns = filtered_nestle_returns

sdv = sd(returns)

#Plot the filtered data 
plot(returns,type="l",col="blue")


#Get the df (degrees of freedom) by Fiting Student T distribution
df = tFit(returns/sd(returns))@fit$estimate


#Then we use the ACF and PACF
acf(returns) #-> as expected we see no significant values
pacf_v = pacf(returns) #-> only one significant lag value (3) therefore we choose to use AR(1) model



k = 60 
sims = numeric(k+3) #the number of simulations should equal k + 3 lag days
prices = numeric(k)


#We get the third phi value (as we saw it is the single most significant one) 
phi3 = pacf_v$acf[3]


#AR(1) process
for(i in (4:length(sims))){
  sims[i] = phi3*sims[i-3] + rt(returns, df) * sdv
}

#Then we plot the simulated data -> we notice 3 day lag
plot(sims,type="l")

#Then  data is trimmed (remove 3 day lag)
sims_trimmed = sims[4:length(sims)]

#set the first predicted price to be equal to the last element of the nestle prices (most actual price)
prices[1] = nestle[length((nestle))]


#Generate the corresponding prices prediction according to the given formula
for(i in (2:length(prices))){
  
  #Get the k-th price by using the exp and log function according to the given formula
  current_price = exp(log(prices[i-1]) - sims_trimmed[i-1])
  
  prices[i] = current_price
  
}


#Plot the simulated prices
plot(prices,type="l")



#Set the strike price S to be equlal to first starting price + 10 percent increase (multiply by 1.1)
S = prices[1] * 1.1 


#set the option value to be equal to the
#difference between the the last simulated price and the strike price S
#we use the max function to filter out when we have a downward trend (negative value)
option = max(prices[k] - S, 0)


#Conclusion: as we continuously generate simulations we can say that:
#When the option value is 0 -> we have a down trend (loss or profit < 10%)
#When the option value is > 0 -> there has been an up trend >= 10% (profit >= 10%)











