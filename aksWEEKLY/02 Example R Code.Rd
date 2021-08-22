library("tidyverse")
install.packages("corrplot")
source("http://www.sthda.com/upload/rquery_cormat.r")
library(dplyr)
X = read.delim("Box/boxTEACH/2106 Lumiere/cohort5year1920.txt");
colnames(X)
glimpse(X)
head(X, n=5)
tail(X, n=5)

Xc = X %>% select("Met.UC.CSU.Grad.Req.s..Count.","Seal.of.Biliteracy..Count.", "Golden.State.Seal.Merit.Diploma..Count.","Non.Graduate.Completers..Count.","Transfers..Count.","Dropout..Count.")


Xcn = na.omit(Xcn)
rquery.cormat(Xcn)
 
m = 0

c = 0



L = 0.0001  # The learning Rate

epochs = 1000  # The number of iterations to perform gradient descent



n = float(len(X)) # Number of elements in X



# Performing Gradient Descent 

for i in range(epochs): 

    Y_pred = m*X + c  # The current predicted value of Y

    D_m = (-2/n) * sum(X * (Y - Y_pred))  # Derivative wrt m

    D_c = (-2/n) * sum(Y - Y_pred)  # Derivative wrt c

    m = m - L * D_m  # Update m

    c = c - L * D_c  # Update c

    

print (m, c)
