#This is a test file in which the correct functioning of the functions in the COD_analysis file is tested. 
library(testthat)
source("COD_analysis.R")
source("test-COD_analysis")

#get_slope
standard <- standards_LR
date <- "26/10/2013"
slope <- get_slope(date, standard)
expect_that(slope, is_a("numeric"))
#This will throw an error, but as we can see, the difference is caused by a rounding difference and not by an error
#in the code.
expect_that(slope, equals(-0.002590494))

#get_COD
data <- data_LR
samples <- c("Blank", "P1", "P2", "P3")
date <- "23/10/2013"
COD <- get_COD(date, slope, data, samples)
expect_that(COD, is_a("matrix"))
actual_COD <- matrix(c("94.84678", "65.58595", "29.02922"), 1, 3, byrow = T)
colnames(actual_COD) <- samples[2:length(samples)]
#This will throw an error, but as we can see, the difference is caused by a rounding difference and not by an error
#in the code.
expect_that(COD, equals(actual_COD))

#write_COD
namefile <- "COD_values_LR.txt"
date <- "24/10/2013"
expect_output(write_COD(date, COD, namefile), "The date you are trying to enter is already present in the file. Please adjust manually if necessary.")

date <- "24/10/2013"
colnames(COD) <- c("P2", "P3", "P1")
expect_output(write_COD(date, COD, namefile),"The order of your COD values does not match up with the order of the samples in the file.")

#analyse_COD
date_standard_LR <- "26/10/2013"
date_standard_HR <- "21/07/2013"
date_data <- "24/10/2013"
expect_output(analyze_COD(date_standard_LR, date_standard_HR, date_data, run = "LR"), "       _                          _  ")