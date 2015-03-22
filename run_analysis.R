## Create one R script called run_analysis.R that does the following:
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement.
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive activity names.
## 5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

library(data.table)
library(reshape2)

# Download UCI HAR file and unzip if not available in the current working directory

if(!file.exists("./UCI HAR Dataset")){
        fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, destfile = "getdata-projectfiles-UCI HAR Dataset.zip", method = "curl")
        unzip("getdata-projectfiles-UCI HAR Dataset.zip", exdir = ".")       
}

# Load and process X_test and Y_test data.
Xtest <- read.table("./UCI HAR Dataset/test/X_test.txt")
Ytest <- read.table("./UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")

# Load and process X_train and Y_train data.
Xtrain <- read.table("./UCI HAR Dataset/train/X_train.txt")
Ytrain <- read.table("./UCI HAR Dataset/train/y_train.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")

# Get activity and feature labels
activity <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

# Extract only the measurements on the mean and standard deviation for each measurement and set lables.
extfeat <- grepl("mean|std", features)
names(Xtest) <- features
Xtest <- Xtest[,extfeat]

names(Xtrain) <- features
Xtrain <- Xtrain[,extfeat]

# Load activity and set labels
Ytest[,2] <- activity[Ytest[,1]]
names(Ytest) <- c("ID", "Activity")
names(subject_test) <- "Subject"

Ytrain[,2] = activity[Ytrain[,1]]
names(Ytrain) = c("ID", "Activity")
names(subject_train) = "Subject"

# Bind test data
test_data <- cbind(as.data.table(subject_test), Ytest, Xtest)

# Bind train data
train_data <- cbind(as.data.table(subject_train), Ytrain, Xtrain)

# Merge test and train data
ucidata <- rbind(test_data, train_data)

id_labels   <- c("Subject", "ID", "Activity")
data_labels <- setdiff(colnames(data), id_labels)
melt_data   <- melt(data, id = id_labels, measure.vars = data_labels)

# Apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, Subject + Activity ~ variable, mean)

# Write tidy data set to file "tidy_data.txt"
write.table(tidy_data, file = "./tidy_data.txt", row.name = FALSE)
