# Project Report**

# Applied Time Series Analysis**

![](media/image1.jpg){width="3.3046609798775153in"
height="2.0298501749781277in"}

**Participants**

Name, Surname: **Evgeniy Petrov**

Name, Surname: **Jonas Bezler**

Submission Date: **05.12.2022**

**Exercise Descriptions**
=========================

**Exercise 1**

In the csv file dataset&lt;your group number&gt;.csv you have saved a
data set, but you forgot the theoretic process you’ve used for
generating it. Can you reproduce the formula using your advanced time
series skills?

**Exercise 2**

You’ll also find two stock price data

a.  Load the data sets to R and perform an adequate preprocessing. Test
    for missing values and outliers. We’re using the close prices.

b.  Which of the two stock prices would you consider as riskier? And
    why? Elaborate!

c.  Choose one of the stocks (any preferences?), and compute the 95% VaR
    for 4 months in advance. How reliable is this number? Any criticism?
    Any possible solutions?

**Exercise 3**

Again choose one of the two stock price data. We intend to gamble a bit
and expect increasing prices. A European call option would be the right
tool for it. We’ve briefly discussed the option during the lecture. Let
me please define it again. Let’s assume a strike price **S** which is
10% above the last noted price **P.** Let’s denote the last observed
price by $P_{T}$. Then the European Call option value for a so called
time-to-maturity of **k** is given as

$$E(max(\left( P_{T + k} - S \right);0)$$

Please estimate the option value using price simulations for a k of 60.

*Hint: You need a simulation of the absolute prices, but you probably
simulate the differences or log-differences. How to reconstruct the
absolute prices from them?. Simply consider if*
$r_{t}\ : = logX_{t + 1} - logX_{t}$ *then* $X_{t + 1} = X_{t}e^{r_{t}}$
*. So if you have simulations for the returns you can reconstruct
simulations for the absolute prices.*

# Exercise Solutions

Check out the uploaded .dox file 🙂

