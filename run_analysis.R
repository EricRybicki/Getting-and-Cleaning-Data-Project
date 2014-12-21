## Read training and test data sets
# Train data
x_train <- read.table("./train/X_train.txt")
y_train <- read.table("./train/y_train.txt")
subject_train <- read.table("./train/subject_train.txt")
# Test data
x_test <- read.table("./test/X_test.txt")
y_test <- read.table("./test/y_test.txt")
subject_test <- read.table("./test/subject_test.txt")
# Merge data sets and remove old data
xData <- rbind(x_train, x_test)
yData <- rbind(y_train, y_test)
subjectData <- rbind(subject_train, subject_test)
rm(list=c("x_train", "y_train", "subject_train", "x_test", "y_test", "subject_test"))

## Extract mean and standard deviation of measurements
features <- read.table("features.txt")
meanStdev <- grep("mean\\(\\)|std\\(\\)", features[, 2])
xData <- xData[, meanStdev]
    names(xData) <- gsub("\\(\\)", "", features[meanStdev, 2]) 
    names(xData) <- gsub("mean", "Mean", names(xData)) 
    names(xData) <- gsub("std", "Std", names(xData)) 
    names(xData) <- gsub("-", "", names(xData)) 

## Apply activity labels 
activity <- read.table("activity_labels.txt")
activity[, 2] = gsub("_", "", tolower(as.character(activity[, 2])))
yData[,1] = activity[yData[,1], 2]
names(yData) <- "activity"

## Label and save new data set in text file
names(subjectData) <- "subject"
cleanedData <- cbind(subjectData, yData, xData)
write.table(cleanedData, "clean_data_set.txt", row.names=FALSE)

## Use cleaned data set to create a new data set with averages of all data.
subjectLength <- length(table(subjectData)) 
activityLength <- dim(activity)[1]
columnLength <- dim(cleanedData)[2]
result <- matrix(NA, nrow=subjectLength*activityLength, ncol=columnLength) 
result <- as.data.frame(result)
colnames(result) <- colnames(cleanedData)
row <- 1
for(i in 1:subjectLength) {
    for(j in 1:activityLength) {
        result[row, 1] <- sort(unique(subjectData)[, 1])[i]
        result[row, 2] <- activity[j, 2]
        bool1 <- i == cleanedData$subject
        bool2 <- activity[j, 2] == cleanedData$activity
        result[row, 3:columnLength] <- colMeans(cleanedData[bool1&bool2, 3:columnLength])
        row <- row + 1
    }
}

## Save tidy data set in a text file.
write.table(result, "tidy_averages_data_set.txt", row.names=FALSE)