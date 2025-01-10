rm(list = ls())

# STAR Experiment, Krueger (1999)
# Replication, Evens SALIES, 11/2020, 11/2021

library(haven)

install.packages("summarytools")
library(summarytools)

library(dplyr)
library(ggplot2)
library(psych)

# Charger les données
url <- "http://www.evens-salies.com/webstar.dta"
data <- read_dta(url)

# Trier les données
data <- data[order(names(data))]

# Table I, p. 503, déséquilibre de la variable Free lunch
# Retrouver la P-valeur 0.09

# Une dummy par groupe en Grande Section (kindergarten)
# stark: attend STAR in kindergarten {1; 2}
# cltypek: classroom type in kindergarten {1; 2; 3}
# sesk: free lunch {1; 2}
data <- subset(data, stark == 1)
data$cltypek_bis <- ifelse(data$cltypek == 1, "small class", ifelse(data$cltypek == 2, "regular class", "regular + aide class"))

table(data$cltypek)
table(data$cltypek_bis)

freq(data$cltypek)
freq(data$cltypek_bis)

data$KG_1 <- as.factor(ifelse(data$cltypek_bis == "small class", 1, 0))
data$KG_2 <- as.factor(ifelse(data$cltypek_bis == "regular class", 1, 0))
data$KG_3 <- as.factor(ifelse(data$cltypek_bis == "regular + aide class", 1, 0))

kg_cols <- grepl("^KG_", names(data))
freq(data[, kg_cols])

###########
# Balance #
###########

# Free lunch
data$FL <- data$sesk
data$FL <- 2 - data$FL
sum(!is.na(data$FL))

# two groups (small class vs regular + aid)
summary(data$FL[data$KG_1 == 1])
mean1 <- mean(data$FL[data$KG_1 == 1], na.rm = TRUE)
sd1 <- sd(data$FL[data$KG_1 == 1], na.rm = TRUE)
sum(!is.na(data$FL[data$KG_1 == 1]))

summary(data$FL[data$KG_3 == 1])
mean0 <- mean(data$FL[data$KG_3 == 1], na.rm = TRUE)
sd0 <- sd(data$FL[data$KG_3 == 1], na.rm = TRUE)
sum(!is.na(data$FL[data$KG_3 == 1]))

meandiff <- mean1 - mean0
normdiff <- abs(meandiff / sqrt(0.5 * (sd1 + sd0)))

cat("Difference des moyennes des X: ", meandiff, "\n")
cat("Difference normalisee : ", normdiff, "\n")

# More than two groups
# Regression
# Convertir les variables KG_ en numérique
data$KG_1 <- as.numeric(levels(data$KG_1))[data$KG_1]
data$KG_2 <- as.numeric(levels(data$KG_2))[data$KG_2]
data$KG_3 <- as.numeric(levels(data$KG_3))[data$KG_3]

model1 <- lm(FL ~ 0 + KG_1 + KG_2 + KG_3, data = data)
summary(model1)

model2 <- lm(FL ~ KG_1 + KG_3, data = data) # on ne met pas KG_2 car STATA la retire automatiquement
summary(model2)

# ANOVA
anova_result <- aov(FL ~ factor(cltypek), data = data)
summary(anova_result)

# White/Asian
data <- data %>% 
  mutate(WA = ifelse(!is.na(srace) & (srace == 1 | srace == 3), 1, 0))

summary_by_group <- data %>%
  group_by(cltypek) %>%
  summarise(
    Mean_WA = ifelse(all(!is.na(WA)), mean(WA), NA),
    N = sum(!is.na(WA)),
    SD_WA = ifelse(all(!is.na(WA)), sd(WA), NA),
    Min_WA = ifelse(all(!is.na(WA)), min(WA), NA),
    Max_WA = ifelse(all(!is.na(WA)), max(WA), NA)
  )
summary_by_group

model3 <- lm(WA ~ KG_2 + KG_3, data = data) # on ne met pas KG_1 car STATA la retire automatiquement
summary(model3)

###########
# Overlap #
###########

# Free lunch
data$sesk_bis <- ifelse(data$sesk == 1, "free lunch", "non free lunch")
table(data$cltypek_bis, data$sesk_bis)

# White/Asian and more
df <- data.frame(X = data$srace, D = data$cltypek)
attr(df$X, "label") <- "Student race: 1 (white) 2 (black) 3 (asian) 4 (hispa.) 5 (india.) 6 (other)"

# order_index <- order(df$D)
# df <- df[order_index, ]
# df <- df[order(df$D, df$X), ]

cat("\014") # pour effacer la console 

result <- df %>%
  group_by(D) %>%
  arrange(D) %>%
  summarise(
    Mean_X = mean(X, na.rm = T),
    SD_X = sd(X, na.rm = T),
    Min_X = min(X, na.rm = T),
    Max_X = max(X, na.rm = T),
    Nb_obs = sum(!is.na(X))
  )
result

# Relative frequency plot
df$ONE <- 1
df$XN <- ave(!is.na(df$X), df$D, FUN = function(x) sum(x))
df$XFREQ <- ave(df$ONE, df$D, df$X, FUN = length)
df$XFRAC <- log(100 * df$XFREQ / df$XN)

result_summary <- psych::describe(df)
result_summary <- subset(result_summary, select = c(n, mean, sd, min, max))
result_summary

# plot
ggplot(data = df, aes(x = X, y = XFRAC)) +
  geom_bar(aes(fill = factor(D), width = 0.2), position = position_dodge(width = 0.2), stat = "identity") +
  scale_fill_manual(values = c("gray50", "red", "green"), labels = c("Small", "Regular", "Regular/Aide")) +
  ylab("XFRAC") +
  # **Ajouter l'échelle**
  scale_y_continuous(breaks = seq(-5, 5, by = 1)) +
  theme_bw() +
  theme(legend.position = "top", legend.title = element_blank(),
        axis.line.x = element_blank(), axis.ticks.x = element_blank())


