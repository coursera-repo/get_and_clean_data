require(plyr)

uri <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
path.inside.zip.file <- "UCI HAR Dataset"
zip.file <- "dataset.zip"

# download.file(uri, destfile=zip.file, mode = "wb")                # Win
download.file(uri, destfile=zip.file, method="curl", mode = "wb")   # Mac

readZipfileData <- function (txt.file, cols) {	
	print(paste("Loading", txt.file))	
	unziped.file <- unz(zip.file, paste(path.inside.zip.file, txt.file, sep="/"))	
	return(read.table(unziped.file, sep="", stringsAsFactors=F, col.names=cols))
}

readData <- function(type, feature) {	
	print(paste("Accessing ", type, "ing datasets", sep=""))	
	s_data <- readZipfileData(paste(type, "/subject_", type, ".txt", sep=""), "id")
	y_data <- readZipfileData(paste(type, "/y_",       type, ".txt", sep=""), "activity")
	X_data <- readZipfileData(paste(type, "/X_",       type, ".txt", sep=""), feature$V2)	
	return(cbind(s_data, y_data, X_data))
}

saveTidyData <- function (data, txt.file) {	
	print(paste("Saving", txt.file))
	write.csv(data, txt.file)
}

features <- readZipfileData("features.txt")
trainset <- readData("train", features)
testset <- readData("test", features)
data <- arrange(rbind(trainset, testset), id)
act.lbl <- readZipfileData("activity_labels.txt")
data$activity <- factor(data$activity, levels=act.lbl$V1, labels=act.lbl$V2)
mean_and_stddev <- data[, c(1, 2, grep("std", colnames(data)), grep("mean", colnames(data)))]
saveTidyData(mean_and_stddev, "tidy_data_1.txt")
average <- ddply(mean_and_stddev, .(id, activity), .fun=function(x){ colMeans(x[, -c(1:2)]) })
saveTidyData(average, "tidy_data_2.txt")