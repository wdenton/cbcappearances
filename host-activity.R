#!/usr/bin/env Rscript

suppressMessages(library(dplyr))
library(reshape)

a <- read.csv("appearances.csv")

a.melted <- melt(a, id=c("name", "fee"))

appearances <- cast(a.melted, name~fee, NROW)

appearances <- mutate(appearances, Total = Expenses + Paid + Unpaid)

appearances <- mutate(appearances, Paid.PerCent = 100 * round(Paid / Total, digits = 2))

print("Define as being 'busy' anyone who has more than this many appearances:")

busy.number <- mean(appearances$Total)
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
