# Wooldridge's (2009) example of Policy analysis with pooled cross sections
# 	Data: "KIELMC.raw" (Data and accompanying files : http://www.cengage.com/)
# 	from Kiel and McClain's (1995) paper, "The effect of an incinerator siting
# 	on housing appreciation rates", Journal of Urban Economics, 37, p. 311-323. 
#	Variables description in file "kielmc.des"
#
# 		Evens SALIES, v1 14/11/2017, v3 04/2025 

DATA <- read.table("kielmc.raw", header=FALSE)	
# Note: R assigne les noms V1, ...	(voir le fichier KIELMC.DES file)	

# Keep the following variables
DATA <- DATA[c("V1", "V2", "V3", "V6", "V9", "V10", "V11", "V12", "V13",
 "V17", "V22", "V23", "V24")] 

# Rename working columns from KIELMC.DES file
colnames(DATA)[colnames(DATA)=="V1"] <- "YEAR"
colnames(DATA)[colnames(DATA)=="V2"] <- "AGE"
colnames(DATA)[colnames(DATA)=="V3"] <- "AGE2"
colnames(DATA)[colnames(DATA)=="V17"] <- "Y81"
colnames(DATA)[colnames(DATA)=="V22"] <- "NEARINC"
colnames(DATA)[colnames(DATA)=="V24"] <- "RPRICE"

# Plus besoin du "chemin" DATA
attach(DATA)

# Naive estimation for 1981 and 1978
TTEST81 <- t.test(RPRICE~NEARINC, subset(DATA, YEAR==1981), mu=0, paired=F, var.equal=T)
TTEST81
TTEST81$estimate[2]-TTEST81$estimate[1]
TTEST81$stderr

TTEST78 <- t.test(RPRICE~NEARINC, subset(DATA, YEAR==1978), mu=0, paired=F, var.equal=T)
TTEST78
TTEST78$estimate[2]-TTEST78$estimate[1]
TTEST78$stderr

# Difference-in-differences estimator
TTEST81$estimate[2]-TTEST81$estimate[1]-(TTEST78$estimate[2]-TTEST78$estimate[1])

# Obtained using a regression approach (Eq. 13.7 du Wooldridge, 2009)
M2 <- lm(RPRICE ~ NEARINC + Y81 + NEARINC*Y81)
summary(M2)

# beta2
mean(RPRICE[NEARINC==1&YEAR==1978])-mean(RPRICE[NEARINC==0&YEAR==1978])

# beta3
mean(RPRICE[NEARINC==0&YEAR==1981])-mean(RPRICE[NEARINC==0&YEAR==1978])

# Get DD estimates for different models by using the regression approach
# Estimate equation 13.3 (p. 450) and 13.7 (p. 451), Eq. (13.4)
M1 <- lm(RPRICE ~ NEARINC, , YEAR == 1981)			
summary(M1)	

# p-value for M2
# help(distribution)
# N(0,1) et T(n) ont des p-value > 0,05 (on calcule la Pr. dans le lower tail)
pnorm(-1.591, mean = 0, sd = 1, lower.tail = TRUE, log.p = FALSE)
pt(-1.591, 317, lower.tail = TRUE, log.p = FALSE)
# Valeur critique dans un test unilatéral
qt(0.95, 317, lower.tail = FALSE, log.p = FALSE)	# Le quantile

# Houses near the incinerator are older: normalized difference
ybar1 <- mean(AGE[NEARINC==1&YEAR==1981])
ybar0 <- mean(AGE[NEARINC==0&YEAR==1981])
s2bar1 <- sd(AGE[NEARINC==1&YEAR==1981])
s2bar0 <- sd(AGE[NEARINC==0&YEAR==1981])
diffnorm <- (ybar1-ybar0)/sqrt((s2bar1^2+s2bar0^2)/2)
diffnorm
M3 <- lm(RPRICE ~ NEARINC + Y81 + NEARINC + NEARINC*Y81 + AGE + AGE2)	
summary(M3)								# Col. (2), Tab. 13.2

# Extra control variables (V6 to V12)
M4 <- M1 <- lm(RPRICE ~ NEARINC + Y81 + NEARINC + Y81*NEARINC + AGE + AGE2 +
 V6 + V9 + V10 + V11 + V12) 					# Col (3), Tab. 13.2
summary(M4)	# Not necessarily better
