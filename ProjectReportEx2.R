#Exercise 2


#Load the both data sets to R 

library(readxl)
varta_raw = read.csv("C:/TimeDataSerriesProjects/ProjectReport/Varta.csv")
nestle_raw = read.csv("C:/TimeDataSerriesProjects/ProjectReport/Nestle.csv")


#We’re using the "close" prices
varta = as.numeric(varta_raw$Close)
nestle = as.numeric(nestle_raw$Close)



#Check for missing values (NAs) -> FALSE means NO missing values
varta_missing_values_exist = sum(is.na(varta)) != 0
nestle_missing_values_exist = sum(is.na(nestle)) != 0
#Conclusion: There are no NAs in the both data sets


#Plot both stock prices
plot(varta,type="l",col="blue")
lines(nestle, col="red")

#Conclusion: Initially just by visually analysing this first plot
#            we can say that Varta stock prices are more fluctuative
#            and appear to be riskier then the ones of Nestle
#            But we will prove that using our advanced skills of 
#            time serries data analysis 



#Detrend both data sets by computing the log-differences
returns_varta = diff(log(varta))
returns_nestle = diff(log(nestle))

#Plot to see how the non-filtered outlier data looks
plot(returns_varta,type="l",col="blue")
lines(returns_nestle,col="red")
#Conclusion ->  outliers are important and they have to be removed

##Outlier elimination

#Calculate standard deviation for both data sets
standard_dev_varta = sd(returns_varta) #0.03436
standard_dev_nestle = sd(returns_nestle) #0.01127
#Conclusion -> before filtering the outliers we can say that
#Varta has a higher deviation therefore higher likelihood of up/down deviation,
#but we can not say anything further since we still have not removed the outliers


#Find boundary (Since we don't want to be so strict about outliers we are going to choose the constant 3 instead of 2.5)
boundary_varta = 3*standard_dev_varta
boundary_nestle = 3*standard_dev_nestle



#Number of outliers
varta_outliers_count = sum(abs(returns_varta) > boundary_varta)
nestle_outliers_count = sum(abs(returns_nestle) > boundary_nestle)

filtered_nestle = returns_nestle[abs(returns_nestle) < boundary_nestle]
filtered_varta = returns_varta[abs(returns_varta) < boundary_varta]


#Plot both filtered data 
plot(filtered_varta,type="l",col="blue")
lines(filtered_nestle,col="red")
#Conclusion: As we can see, the Varta data is more volatile when it comes to returns,
#than the returns of nestle. In other words Varta initially appears to be more riskier than Nestle



# Test if a data sets are Gaussian distributed
##VARTA
qqnorm(filtered_varta)
qqline(filtered_varta)
##S shape ⇒ leptokurtic distribution -> Student T Distribution


##NESTLE
qqnorm(filtered_nestle)
qqline(filtered_nestle)
##weak S shape -> still not as close to Gaussian Distribution, but we will still use Student T Distribution


library(fBasics)

#Plot Student-T Parameters Estimations
tFit(filtered_varta/standard_dev_varta)
tFit(filtered_nestle/standard_dev_nestle)


#Then we plot a histogram of the returns for the nestle and Varta stock
hist(filtered_nestle,40)
hist(filtered_varta,40)
#Conclusion: We see that it the histogram of Nestle is less wide-spread then
#the histogram of Varta and it values stay coloser to zero (less risky)


#RE-Calculate standard deviation after removal of outliers
standard_dev_varta = sd(filtered_varta) 
standard_dev_nestle = sd(filtered_nestle) 

#Conclusion -> Varta has a higher deviation therefore higher likelihood of up/down deviation (more risky)

#Therefore we are going to compute the VaR (Value at Risk) for Varta = 5% quantile
#Since Varta is more riskier we expect it to have a higher value at risk

VaR_emperical = quantile(filtered_varta,0.05)
#we get output -0.0473 which means we can expect roughly around 4.73% profit
#if we stay with Varta

#using the theoretical 
degf = tFit(filtered_varta/standard_dev_varta)@fit$estimate

VaR_theory = qt(0.05,degf)*standard_dev_varta

#Test the phi -> check formost significant lag coefficients (25,26 are most significant)
phis = pacf(filtered_varta)

#VARTA SIMULAION FOR 4 MONTHS
# Fitting AR(2) process

filtered_varta_mean = mean(filtered_varta)

#Define number of simulatated further values
nSims = 157 #4 months(around 125 days) + 27 lag days

ar2 = numeric(nSims) 


# AR process

phi25 = phis$acf[25]
phi26 = phis$acf[26]


#AR(2) process
for (k in 27:length(ar2))
{
  ar2[k] = phi25*ar2[k-25] + phi26*ar2[k-26]+ rt(filtered_varta,degf) * standard_dev_varta
}



#We plot our simulated values along with ACF and PACF
plot(ar2,type="l") #we notice that there is lag



#Since there is a lag we have to cut if off
varta_sim = ar2[27:length(ar2)]
plot(varta_sim,type="l")


#We use the PACF again to try to prove that we have used AR(2) 
pacf(ar2)
#However since the number of simuated values is TOO LOW we can not see our used lag coefficients (25,26)
#A quick fix would be to increase the number of simulated values (nSims) by a factor of 1000


#Then we have to compute the Value at Risk (VaR) for the simulation of Varta (5% quantile)
standard_dev_varta_sim = sd(varta_sim)


VaR_emperical_sim = quantile(varta_sim,0.05)
#we get output -0.04814 which means roughly 4.814% profit 

library(fBasics)
#using the theoretical 
df = tFit(varta_sim/standard_dev_varta_sim)@fit$estimate

VaR_theory = qt(0.05,df)*standard_dev_varta_sim
#We get output -0.04652 which means roughly 4.652% profit 


#What happens when we use the Gaussian quantile...
mu = mean(varta_sim)
VaR_norm_sim = qnorm(0.05,mu,standard_dev_varta_sim)

#Expected shortfall for BASF data given 95% VaR

#First step: we need 5% smallest returns

x = varta_sim[varta_sim < VaR_emperical_sim]

#Expected Shortfall (ES) = average (-0.06241)
#Conditional Value at Risk (CVaR), also known as the expected shortfall, 
#a risk assessment measure that quantifies the amount of tail risk an investment portfolio has.
ES = mean(x)






