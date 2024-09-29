#################################################
#
# Frozen Pizza Data for Regression Analysis
#
#################################################


# Read the data set and some preliminary data analysis
setwd ("/Users/marcuskim/Desktop/MBAn/Fall A/MBAN553-PredictiveAnalytics/Homework1") # indicate the directory where your csv data file is located
pizza = read.csv("Frozen_pizza.csv",header=TRUE) # read the data with the variable names listed on the top row of the csv file

# For MAC users, use the following command instead. Make sure you have the data sved on your desktop.
pizza = read.csv("~/frozen_pizza.csv",header=TRUE)

# Checking and preparing your data for analysis
str(pizza)# reveal variables in frozen pizza data and the variable types 
head(pizza) # print out the first 6 rows of pizza data
names(pizza)# get the list of all variable names in the data set


######################
# Summary statistics 
######################

# Given that a lot of variables in the data set are continuous and we want to compute their
# means and st devs. It will not be efficient to use the command "mean" and "sd" for each
# variable one at a time. One way to compute descriptive statistics for continous variables 
# all at once is to use a function sapply.

sapply(pizza,mean)# apply function 'mean' to every column in pizza data
sapply(pizza,sd)# apply function 'sd' to every column in pizza data
round(sapply(pizza,mean),2) # round up means to two decimals
round(sapply(pizza,sd),2) # round up st devs to two decimals

# Often times, you want to apply descriptive statistics to only a subset of variables in 
# the data set. Let's focus on variables related to the regression analysis for Tombstone.
# "c" lists the names of variables in the pizza dataframe we want to select.
# "cbind" is a function to combine columns of values together to form a table.
# If you want to combine rows of values, use "rbind". 

varJack=c('JackSale','DiGiorPrice','TombPrice','JackPrice','JackFeature','JackDisplay')
descJack=cbind(sapply(pizza[,varTomb],length),
               sapply(pizza[,varTomb],min),
               sapply(pizza[,varTomb],max),
               sapply(pizza[,varTomb],mean),
               sapply(pizza[,varTomb],sd))
descJack # print out the table 

# What you get is a table with variables are in the rows and types of descriptive statistics are 
# in the columns. Right now, there are no column names. We can add those. 
# We can also make variable names in the rows look for professional. Remember that there cannot be any space
# in variable names in R but we can label these names more properly this way.

colnames(descJack)=c('N','Min','Max','Mean','Std.Dev') 
rownames(descJack)=c('Jack Sales','DiGiorno Price','Tombstone Price','Jack Price','Jack Feature','Jack Display')
descJack

# Plot histogram of Tombstone sales
# Here, instead of using ggplot, I can also use a simpler command
hist(pizza$JackSale, main="Jack's Sales", xlab="units", breaks=50, xlim=c(0,5000), col="darkgrey")

# Scatter plot between Tombstone sales and Tombstone price
plot(pizza$JackPrice,pizza$JackSale,main="Jack's Sales Vs. Jack's Price",xlab="Jack's Price",ylab="Jack's Sales")
abline(lm(pizza$JackSale~pizza$JackPrice), col="red") # fitting a regression line (y~x)

# Correlation analysis for all the variables in the regression analysis
pizza.Jack <- pizza[varJack] # select only variables for Tombstome regression analysis
cor.Jack <- cor(pizza.Jack)
round(cor.Jack,3)

############################################################
# Multiple linear regression analysis and model diagnostic
############################################################

# Run a multiple linear regression model with original data
# Notice that in this function, you don't need to us $ because you specify in the "lm" fucntion
# that you want to apply the regression analysis to the pizza dataframe. 
reg.Jack <- lm(JackSale ~ DiGiorPrice + TombPrice + JackPrice + JackFeature + 
               JackDisplay, data=pizza)
summary(reg.Jack)

# Model diagnostic 1: How well do we predict data?
pizza$pred.Jack <- predict(reg.Jack) # calculate predicted sales based on the regression model
head(pizza$pred.Jack) # print the first 6 observations of predicted Tombstone sales

plot(pizza$JackSale, pizza$pred.Jack, main="Actual v. Predicted Tombstone Sales",
     xlab='Actual Sales',ylab='Predicted Sales',
     xlim=c(0, 2000), ylim=c(0, 2000)) # I truncate the axis to make the plot easier to see    
abline(a=0,b=1)  

# Model Diagnostic 2: Do the residuals have equal variance?
pizza$res.Jack <- residuals(reg.Jack)
head(pizza$res.Tomb) # print the first 6 observations of residuals

homosked=plot(pizza$pred.Jack,pizza$res.Jack,main='Residuals vs Predicted Sales',xlab='Predicted Sales',ylab='Residuals')
abline(homosked,h=0)

# Transfrom Sales to Ln Sales
pizza$LnJackSale = log(pizza$JackSale) # take natural log of tombstome Sales
head(pizza$LnJackSale) # print the first 6 observations of Ln Tombstone Sales

# Run a log sales model
reg.LnJack <- lm(LnJackSale ~ DiGiorPrice + TombPrice + JackPrice + JackFeature 
             + JackDisplay, data = pizza)
summary(reg.LnJack)

# Model diagnostic 1: How well do we predict data?
pizza$pred.LnJack <- predict(reg.LnJack) # calculate predicted sales based on the regression model
head(pizza$pred.LnJack)

plot(pizza$JackSale, exp(pizza$pred.LnJack), main="Actual v. Predicted Jack's Sales", # need to take exponent of ln sales to get sales back
     xlab='Actual Sales',ylab='Predicted Sales',
     xlim=c(0, 2000), ylim=c(0, 2000))     
abline(a=0,b=1)   

# Model Diagnostic 2: Do the residuals have equal variance?
pizza$res.LnJack <- residuals(reg.LnJack)
head(pizza$res.LnJack)

homosked=plot(pizza$pred.LnJack,pizza$res.LnJack,main='Residuals vs Predicted Ln Sales',xlab='Predicted Ln Sales',ylab='Residuals')
abline(homosked,h=0)

exp(predict(reg.LnJack, data.frame(DiGiorPrice=5.72,TombPrice=4.06,JackPrice=3,JackFeature=1,JackDisplay=0)))

# Plot histogram of Ln Tombstone sales
hist(pizza$LnJackSale, main="Ln Jack's Sales", xlab="units", breaks=20, xlim=c(0,10), col="darkgrey")

# Scatter plot between Ln Tombstone sales and Tombstone price
plot(pizza$JackPrice,pizza$LnJackSale,main="Jack's Sales Vs. Jack's Price",xlab="Jack's Price",ylab="Ln Jack's Sales")
abline(lm(pizza$LnJackSale~pizza$JackPrice), col="red") # fitting a regression line (y~x)


######################################################################
# Multiple linear regression analysis with more advanved predictors
# It's a good idea to use different names for different resgression 
# models
######################################################################

# Regress Jack's ln sales with prices of all Kraft's brands (Q8)
pizza$LnJackSale = log(pizza$JackSale) # take natural log of tombstome Sales
reg.LnJack <- lm(LnJackSale ~ DiGiorPrice + TombPrice + JackPrice, data = pizza)
summary(reg.LnJack)

# Regress Jack's ln sales with its own price and competitor's price within the same tier (i.e., Tony's) (Q8)
reg.LnJackTony <- lm(LnJackSale ~ JackPrice + TonyPrice, data = pizza)
summary(reg.LnJackTony)

# Regress Jack's ln sales with Jack's and Tombstone prices together with month as a numeric variable (Q9)
reg.Jack3 <- lm(LnJackSale ~ TombPrice + JackPrice + month, data=pizza)
summary(reg.Jack3)

# Regress Jack's ln sales with Jack's and Tombstone prices together with month but this time you will include months
# as dummy or indicator variables(Q9)
# To do so, you will first convert month into a factor instead of an integer variable. This is an indirect way to create 
# dummy varibles (Q9)
pizza$month_ind <- as.factor(pizza$month)
reg.Jack4 <- lm(LnJackSale ~ TombPrice + JackPrice + month_ind, data=pizza)
summary(reg.Jack4)


# Run the same regression as the previous one with squared Jack's price and then add cubed Jack's price (Q10)
pizza$JackPriceSq = pizza$JackPrice**2 # compute price squared
pizza$JackPriceCu = pizza$JackPrice**3 # compute price cubed


# Run a regression model with Tombstone price, Jack's price, and Jack's feature, as well as the interaction between
# Jack's price and Jack's feature as predictors (you can simply add a term "JackPrice*JackFeature" to your regression 
# model (Q11) 




