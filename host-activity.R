#!/usr/bin/env Rscript

library(dplyr)
library(reshape2)

cbc <- read.csv("appearances.csv", header = TRUE, stringsAsFactors = TRUE)

cbc$date <- as.Date(cbc$date)

print(paste("Date range: ", min(cbc$date), "-", max(cbc$date)))

b <- cbc %>% select(name, fee) %>% group_by(name, fee) %>% summarise(count = n())

appearances <- dcast(b, name ~ fee, fill = 0, value.var = "count")

appearances <- mutate(appearances, Total = Expenses + Paid + Unpaid, Paid.PerCent = 100 * round(Paid / Total, digits = 2))

print("How many people are on the list?")
nrow(appearances)

print("How many appearances were made in total?")
sum(appearances$Total)

print("Define as being 'busy' anyone in the third quartile; minimum appearances:")

busy.number <- quantile(appearances$Total)[[4]]
busy.number

print("Who is busy?")
busy <- subset(appearances, Total >= busy.number)
busy %>% arrange(desc(Total))

print("Of busy people, who has only done paid appearances?")
subset(busy, Paid.PerCent == 100) %>% arrange(desc(Total))

print("Of busy people, who has never done a paid appearance?")
subset(busy, Paid.PerCent == 0) %>% arrange(desc(Total))

print("Of the other busy people, who has some paid and some unpaid appearances?")
subset(busy, Paid.PerCent > 0 & Paid.PerCent < 100) %>% arrange(desc(Total))
