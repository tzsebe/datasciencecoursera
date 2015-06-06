library(sqldf)

# Load the file
data <- read.csv.sql("household_power_consumption.txt", "select * from file where Date in ('1/2/2007', '2/2/2007')", header = TRUE, sep = ";")

# Generate Plot
png(filename = "plot1.png", width = 480, height = 480, bg = "transparent")
hist(data$Global_active_power, col = "red", xlab = "Global Active Power (kilowatts)", main = "Global Active Power")
dev.off()
