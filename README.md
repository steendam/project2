project2
========

# COD analysis with R

This README file contains the explanation for use of the R codes 'COD_analysis.R' and 'test-COD_analysis.R'. The objective, materials, and working principle of the former code are described first. The test file is shortly discussed in the last section. 

### Objective.
This repository contains the second project for class MICRBIAL 610, which involves calculating the chemical oxygen demand (COD) values from inserted absorbance values. The user will have to insert his/her standard absorbance values in a text file so that the COD-values of the actual absorbance values can be calculated. These calculated COD-values are then outputted to a new text file. 

### Materials. 
The names of all text files required and their contents are explained in Table 1. This code is specifically written for analysis of three types of low-range samples (permeate 1, permeate 2, and permeate 3) and 5 types of high-range samples (concentrate, influent with concentrate, total influent, soluble influent, and soluble bioreactor). If a user wants to use this code to analyze different types of samples, he or she needs to adapt the column names in the text files, adapt the desired order of samples in the write_COD function, and finally, change the samples at the beginning of the analyze_COD function (all these functions are explained below).

***Table 1: All necessary text files are summed up together with all their information.***   

Name of the file. | Explanation of its contents. | Columns in this file. |
------------- | ------------- |-----------------|
COD_data_HR | Absorbance data of high-range COD values, inserted by the user. | Date, Sample, Absorbance_1, Absorbance_2, dilution|
COD_data_LR | Absorbance data of low-range COD values, inserted by the user. |Date, Sample, Absorbance_1, Absorbance_2, dilution |
COD_standards_HR | High-range standard data and their corresponding absorbance values, inserted by the user. | Date, Absorbance_1, Absorbance_2 |
COD_standards_LR | Low-range standard data and their corresponding absorbance values, inserted by the user. | Date, Absorbance_1, Absorbance_2 |
COD_values_HR | The calculated COD-values of the high-range samples, inserted by R. | Date, Concentrate, Influent_concentrate, Influent_total, Influent_soluble, Bioreactor_soluble |
COD_values_LR | The calculated COD-values of the low-range samples, inserted by R. | Date, P1, P2, P3|

### Working Principle. 
The code contains three sub-functions (get_slope, get_COD, and write_COD) and one uber-function (analyze_COD). These four functions are also shown in a table (Table 2), where their purpose, inputs, and outputs are explained. Most inputs are self-explanatory, but some do need further explanation. All inputs are therefore explained in a Table 3, which also gives an example for each.  This code currently runs with a specifc set of 'samples', that are defined as a set relevant for a specific research project. Users are encouraged to change this set to their needs. 

***Table 2: All functions are summed up together with all their information.***   

Name of the function. | Input(s) of the function. | Output(s) of the function.| 
------------- | ------------- |--------------- | ------------- |
get_slope     | Date, Standard | Slope of the standard on this specific date. |
get_COD       | Date, Slope, Data, Samples | The calculated COD values of this specific data. |
write_COD     | Date, COD, namefile | No output if all is correct, the calculated COD values are inserted in the text file. |
analyze_COD   | date_standard_LR, date_standard_HR, date_data, run | No output if all is correct, the calculated COD values are inserted in the text file.|


***Table 3: Explanation of inputs.***

Name of the input. | Description. | Example. |
-------| -------| ---- |
Date   | A string denoting the desired date. | "24/10/2013" |
Standard |  A (read) text file containing the standard data. | read.table(file = "COD_standards_LR.txt", header=T) |
Slope | A number corresponding to the slope of a specific calibration curve. | -0.002590494 |
Data | A (read) text file containing the actual data. | read.table(file = "COD_data_LR.txt", header=T) |
Samples | A vector containing the names of the samples to be analyzed. | c("P1", "P2", "P2") |
COD | A matrix containing the calculated COD values, with each column named as the corresponding sample. | Needs to be calculated by R: COD <- get_COD(date, slope, data, samples). |
Namefile  | A string denoting the name of the text file in which you want to insert the newly calculated COD values. | "COD_values_LR.txt" |
date_standard_LR | A string denoting the date of the low-range standard values you want to use for calibration | "26/10/2013" |
date_standard_HR |  A string denoting the date of the high-range standard values you want to use for calibration | "21/07/2013" |
date_data | A string denoting the date of the absorbance values you want to convert to COD values. | "24/10/2013" |
run | A string explaining if you want to analyze low-range, high-range, or both sample types (default is "LR"). | "both" |

Now that all functions and their inputs are explained, the working principle of the code is rather straightforward. The user can either use the uber-function 'analyze_COD' or call upon the separate functions. Examples on how to do either option, are shown below.  

*Call upon the uber-function:*

* source("COD_analysis.R")
* date_standard_LR <- "26/10/2013"
* date_standard_HR <- "21/07/2013"
* date_data <- "24/10/2013"
* analyze_COD(date_standard_LR, date_standard_HR, date_data, run = "LR")

*Call upon all functions separately:*

* source("COD_analysis.R")
* get the slope:
    + standard <- read.table(file = "COD_standards_LR.txt", header=T)
    + date <- "26/10/2013"
    + slope <- get_slope(date, standard)
* get the COD-values:
    + date <- "23/10/2013"
    + slope is calculated above
    + data <- read.table(file = "COD_data_LR.txt", header=T)
    + samples <- c("Blank", "P1", "P2", "P3")
    + COD <- get_COD(date, slope, data, samples)
* write the COD-values to the desired text file:
    + date <- "24/10/2013"
    + COD is calculated above
    + namefile <- "COD_values_LR.txt"
    + write_COD(date, COD, namefile)

### Test File. 
A test file is created and given in the repository (called test-COD_analysis.R) that uses the package *testthat*. In order to use this file, the user first needs to install this package using the following command: install.packages("testthat"). When the user makes changes to the code, it is highly recommended that he tests his newly designed code. It is important to note that the current test file is based on known output values for certain dates and absorbance values, so if the user changes these, he/she will also have to change these expected values. 
