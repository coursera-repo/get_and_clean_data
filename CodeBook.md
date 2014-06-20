After the compressed file is unzipped, each set of data (training and test) is loaded up in turn. Each set contains three files: subject_type, X_type and y_type, the type can be either train or test, depending of the data set.

The three files of the same set are loaded into different variables and then combined toguether columnwise.

After the fusion inside each set, they will finally attach one to another.

To get the mean and standard deviation out of the mega structure the function grep is used.

To get the average, the ddply is used with the function colMeans. The -c(1:2) inside the function is to remove the first two columns from the calculation.
