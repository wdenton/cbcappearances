#!/usr/bin/env Rscript

suppressMessages(library(dplyr))
library(reshape2)

a <- read.csv("appearances.csv", header = TRUE)

a$date <-as.Date(a$date)

print(paste("Date range: ", min(a$date), "-", max(a$date)))

b <- a %>% select(name, fee) %>% group_by(name, fee) %>% summarise(count = n())

appearances <- dcast(b, name ~ fee, fill = 0, value.var = "count")

appearances <- mutate(appearances, Total = Expenses + Paid + Unpaid, Paid.PerCent = 100 * round(Paid / Total, digits = 2))

print("How many people are on the list?")
nrow(appearances)

print("How many appearances were made in total?")
sum(appearances$Total)

print("Define as being 'busy' anyone who has more than this many appearances:")

busy.number <- round(mean(appearances$Total) + sd(appearances$Total), 0)
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
