#install.packages("foreign")
library(foreign)

data1 <- read.dta("http://www.evens-salies.com/urgence_angristpischke.dta")
str(data1)
View(data1)

# Create two new variables from these two encoded variables in Stata
# phstat: Excellent 1, Very good 2, Good 3, Fair 4, Poor 5, Refused 7, Don't know 9
# phospyr: Yes 1, No 2, Refused 7, Don't know 9

data1$health1 <- ifelse(data1$phstat=="Excellent",1,0)
data1$health1 <- ifelse(data1$phstat=="Very good",2,data1$health1)
data1$health1 <- ifelse(data1$phstat=="Good"	 ,3,data1$health1)
data1$health1 <- ifelse(data1$phstat=="Fair"	 ,4,data1$health1)
data1$health1 <- ifelse(data1$phstat=="Poor"	 ,5,data1$health1)
data1$group <- ifelse(data1$phospyr=="Yes"	 ,0,2)
data1$group <- ifelse(data1$phospyr=="No"		 ,1,data1$group)

# Drop remaining 0 in variable "health" and remaining 2 in variable "group"
data <- data1[which(data1$health1 !=0 & data1$group !=2),]

# Recode the health variable 1->5, ..., 5->1
data$health <- 6-data$health1

# Attach labels to "group"
head(factor(data$group))
group <- factor(data$group, levels=c(0,1), labels=c("Treated","Control"))
table(group)

# T test for equal variances
mean(health[data$group==0])-mean(health[data$group==1])
t.test(data$health~data$group, mu=0, var.equal=T)