The script starts by installing the plyr package and then sets up some environment variables to access and manipulate the zip file.

    require(plyr)

    uri <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    path.inside.zip.file <- "UCI HAR Dataset"
    zip.file <- "dataset.zip"

The following two lines of code is to download the source data. The one commented out is to work in Windows; the other one which uses the curl method should work on Mac and Linux operating systems.

    # download.file(uri, destfile=zip.file, mode = "wb")                # Win
    download.file(uri, destfile=zip.file, method="curl", mode = "wb")   # Mac

Next there are three functions.

The first one (readZipfileData) unzips the compressed source file and helps access the inner files through the given parameters.

    readZipfileData <- function (txt.file, cols) {
        print(paste("Loading", txt.file))
        unziped.file <- unz(zip.file, paste(path.inside.zip.file, txt.file, sep="/"))
        return(read.table(unziped.file, sep="", stringsAsFactors=F, col.names=cols))
    }

The second one (readData) parses the corresponding training or test sets data files according to the parameter "type" and returns a cobined data structure with cbind.

    readData <- function(type, feature) {
        print(paste("Accessing ", type, "ing datasets", sep=""))
        s_data <- readZipfileData(paste(type, "/subject_", type, ".txt", sep=""), "id")
        y_data <- readZipfileData(paste(type, "/y_",       type, ".txt", sep=""), "activity")
        X_data <- readZipfileData(paste(type, "/X_",       type, ".txt", sep=""), feature$V2)
        return(cbind(s_data, y_data, X_data))
    }

The last function (saveTidyData) outputs to disk the Tidy Data files ("tidy_data_1.txt" and "tidy_data_2.txt").

    saveTidyData <- function (data, txt.file) {
        print(paste("Saving", txt.file))
        write.csv(data, txt.file)
    }

Following the function definitions there are some subsequent calling to the functions to unpack and load the training and test data.

    features <- readZipfileData("features.txt")
    trainset <- readData("train", features)
    testset <- readData("test", features)

Both, training and test sets are combined using rbind and sorted according to the ID.

    data <- arrange(rbind(trainset, testset), id)

From the combined data are extracted the standard deviation and the mean and the result is saved into "tidy_data_1.txt".

    act.lbl <- readZipfileData("activity_labels.txt")
    data$activity <- factor(data$activity, levels=act.lbl$V1, labels=act.lbl$V2)
    mean_and_stddev <- data[, c(1, 2, grep("std", colnames(data)), grep("mean", colnames(data)))]
    saveTidyData(mean_and_stddev, "tidy_data_1.txt")

Finally, a second independent tidy data set with the average of each variable for each activity and each subject is created and saved as "tidy_data_2.txt".

    average <- ddply(mean_and_stddev, .(id, activity), .fun=function(x){ colMeans(x[, -c(1:2)]) })
    saveTidyData(average, "tidy_data_2.txt")
