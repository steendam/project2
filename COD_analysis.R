#calculate thhe COD for both sample types + save in a new text file. To calculate the COD values, 
#you need to use a calibration curve. This curve is not made every time a COD analysis is done, 
#and therefore this information is obtained first, and the user has to input the date of the desired
#calibration.

### The UBER Function ##
#This function will run all the necessary functions for a normal 'run'. Since the calibration date
#can be different from the sample date, you need to insert the calibration dates separately.
#Furthermore, there ist the possibility to run both LR and HR, or only one of them.
# analyze_COD("18/04/2013", "21/07/2013", "22/10/2013")
#date_standard_LR <- "26/10/2013"
#date_standard_HR <- "21/07/2013"
#date_data <- "24/10/2013"
analyze_COD <- function(date_standard_LR, date_standard_HR, date_data, run = "LR"){
  #Initializing
  samples_LR <- c("Blank", "P1", "P2", "P3")
  samples_HR <- c("Blank", "Concentrate", "Influent_concentrate", 
                  "Influent_total", "Influent_soluble", "Bioreactor_soluble")
  message <- 0
  
  if (run == "LR"){
    #Read all the txt files
    standards_LR <- read.table(file = "COD_standards_LR.txt", header=T) 
    data_LR <- read.table(file = "COD_data_LR.txt", header=T)
    
    #Calculate the slopes of both standard curves at the desired date
    slope_LR <- get_slope(date_standard_LR, standards_LR)
    
    #Calculate the COD values of the new data 
    COD_LR <- get_COD(date_data, slope_LR, data_LR, samples_LR)
    
    #Write the new COD values into the table
    message <- write_COD(date_data, COD_LR, "COD_values_LR.txt")
    
  } else if (run == "both"){
    #Read all the txt files
    standards_LR <- read.table(file = "COD_standards_LR.txt", header=T) 
    data_LR <- read.table(file = "COD_data_LR.txt", header=T)
    standards_HR <- read.table(file = "COD_standards_LR.txt", header=T)
    data_HR <- read.table(file =  "COD_data_HR.txt", header=T)
    
    #Calculate the slopes of both standard curves at the desired date
    slope_LR <- get_slope(date_standard_LR, standards_LR)
    slope_HR <- get_slope(date_standard_HR, standards_HR)
    
    #Calculate the COD values of the new data 
    COD_LR <- get_COD(date_data, slope_LR, data_LR, samples_LR)
    COD_HR <- get_COD(date_data, slope_HR, data_HR, samples_HR)
    
    #Write the new COD values into the table
    message <- write_COD(date_data, COD_LR, "COD_values_LR.txt")
    message <- write_COD(date_data, COD_HR, "COD_values_HR.txt")
    
  }else{
    #Read all the txt files
    standards_HR <- read.table(file = "COD_standards_LR.txt", header=T)
    data_HR <- read.table(file =  "COD_data_HR.txt", header=T)
    
    #Calculate the slopes of both standard curves at the desired date
    slope_HR <- get_slope(date_standard_HR, standards_HR)
    
    #Calculate the COD values of the new data 
    COD_HR <- get_COD(date_data, slope_HR, data_HR, samples_HR)    
    #Write the new COD values into the table
    message <- write_COD(date_data, COD_HR, "COD_values_HR.txt")    
  }
  
  #If all goes well, print "done". However, if an error message is printed, don't print "done".
  if (is.null(message) == TRUE){
  print("       _                          _  ")
  print("      | |                        | | ")
  print("      | |         _      _____   | | ")
  print("  ----| | ------ | |___ |  ___|  | | ")
  print(" |  __  ||  __  ||  _  || |___   | | ")
  print(" | |  | || |  | || | | ||  ___|  |_| ")
  print(" | |__| || |__| || | | || |___    _  ")
  print("  ------------------ ---------|  |_| ")
  }
}


### COD FUNCTIONS ###

#A function to get the slope of the calibration curve. 
#Input: date of the desired calibration curve, in the format "18_04_2013" + the variable in which you
  #stored your standard values e.g. standards_LR.
#Ouput: the slope
# standard <- standards_LR
# date <- "26/10/2013"
get_slope <- function(date, standard){
  average <- 0
  calibration_data <- standard[standard$Date == date, ]
  
  #Calculate the average of both absorbance values. If one of them is NA, use the first absorbance
  #as average value. 
  for(i in 1:nrow(calibration_data)){
    if(is.na(calibration_data[i,4]) == FALSE){
      average[i] <- (as.numeric(calibration_data[i,3])+ as.numeric(calibration_data[i,4]))/2
    }else{
      average[i] <- as.numeric(calibration_data[i,3])
    }
  }
  
  #Calculate the slope
  x <- average
  y <- calibration_data[,2]
  lmresult <- lm(x~y)  
  return(coef(lmresult)[["y"]])
  }

#A function to convert the absorbances to COD values (mg/l). 
#Input: the date the samples were made (format:"22/10/2013"), the slope of your calibration curve, 
  #the absorbance data (variable that refers to a txt file), and a vector containing all samples
  #to be converted. Be sure to always insert a "Blank" as the first sample.
#Output: a matrix with the samples as column names and the calculated COD values as seats.
# data <- data_LR
# slope <- coef(lmresult)[["y"]]
# samples <- c("Blank", "P1", "P2", "P3")
# date <- "23/10/2013"
get_COD <- function(date, slope, data, samples){
  #Initialization
  average <- 0
  COD <- 0
  #Find the desired values at the given data
  segment_data <- data[data$Date == date, ]  
    #go over all samples from which you want to analyze the COD
    for(i in 1:length(samples)){
      #go over all samples taken on this date, to see what sample corresponds to the one you want
      for(j in 1:nrow(segment_data)){
        if(samples[i] == segment_data[j,2]){
         #Calculate the average of of both absorbances of all wanted COD's. If one of them is 
         #NA, use the first absorbance as average value. 
         #For some strange reason, the third column is read as a factor and the fourth not. Thus:
          if(is.na(segment_data[i,4]) == FALSE){
            options(warn=-4)
            all_levels <- as.numeric(levels(segment_data[j,3]))
            this_level <- as.numeric(segment_data[j,3])
            average[i] <- (all_levels[this_level] + as.numeric(segment_data[j,4]))/2
          }else{
            options(warn=-4)
            all_levels <- as.numeric(levels(segment_data[j,3]))
            this_level <- as.numeric(segment_data[j,3])
            average[i] <- all_levels[this_level]
          }          
         #Calculate the COD values for all samples except the Blank: average - blank / slope * dilution 
         if(i > 1){
            COD[i-1]<- (average[i]- average[1])/slope*as.numeric(segment_data[segment_data$Sample == samples[i],5])
          }      
        }
      }
    }
  #Save the COD values in different columns with the column names denoting the corresponding sample
  COD <- t(COD)
  colnames(COD) <- samples[2:length(samples)]
  return(COD)  
}

#A function to write the calculated COD values into the correct txt file.
#Input: date (format:"22/10/2013"), a vector containing the COD values of your samples, and the
  #name of the file you want to write the COD values into.
#Output: the file will be adapted. There is no direct output. 
#namefile <- "COD_values_LR.txt"
write_COD <- function(date, COD, namefile){
  #We want to add the new COD values to the COD_data.txt file (LR or HR).
  #Columns in file: Date, P1, P2, P3 or Date, Concentrate, Influent_concentrate
  #Influent_total, Influent_soluble, Bioreactor_soluble
  is_there <- 0
  file <- read.table(file = namefile, header=T)
  #See if this date is already in table, if already there: give an error message.
  for(i in 1:nrow(file)){
    if(file[i, 1] == date){is_there <- 1}
  }
  
  if(is_there  == 1){
    print("The date you are trying to enter is already present in the file. Please adjust manually if necessary.")
  }else{
  #If the date is not yet there, add the new COD values to the txt file. Generate a warning if the 
  #values are not in the right order (and will thus be placed wrongly).
    if(colnames(COD) == c("P1", "P2", "P3") || colnames(COD) == c("Concentrate", 
          "Influent_concentrate", "Influent_total", "Influent_soluble", "Bioreactor_soluble")){
      #get rid of columnnames
      colnames(COD) <- NULL
      write.table(t(c(date, COD)), file = namefile, append = TRUE, 
                  quote = FALSE, sep = "\t", col.names = FALSE, row.names = FALSE) 
    }else{
      print("The order of your COD values does not match up with the order of the samples in the file.")
    }
  }
}



### EXTRAS ###
# #A function to read the desired file(s). 
# #Input:either one or a conbination of the following files: "COD_data_LR.txt", "COD_standards_LR.txt", 
#   #"COD_data_HR.txt", "COD_standards_HR.txt."
# #Output:
# read_file <- function(file){
#   #Initializing
#   files <- 0
#   #Go over all files to be read
#   for (i in 1:length(file)){
#   if(file[i] == "COD_data_LR.txt"){
#     #open text file with LR samples
#     data_LR <- read.table(file= file[i], header=T)
#     files[i] <- list(data_LR)
#   }else if (file[i] == "COD_standards_LR.txt"){
#     #open text file with LR Standards
#     standards_LR <- read.table(file= file[i], header=T)
#     files[i] <- list(standards_LR)
#   }else if(file[i] == "COD_data_HR.txt"){
#     #open text file with HR samples
#     data_HR <- read.table(file= file[i], header=T)
#     files[i] <- list(data_HR)
#   }else{
#     #open text file with HR Standards
#     standards_HR <- read.table(file= file, header=T)
#     files[i] <- list(standards_HR)
#   }
#   }
#   return(files)
# }
