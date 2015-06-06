library(sqldf)
library(lubridate)

# Load the file and add a DateTime to the DF.
data <- read.csv.sql("household_power_consumption.txt", "select * from file where Date in ('1/2/2007', '2/2/2007')", header = TRUE, sep = ";")
data$DateTime <- dmy_hms(paste(data$Date, data$Time))

# Generate Plot
png(filename = "plot2.png", width = 480, height = 480, bg = "transparent")
plot(data$DateTime, data$Global_active_power, type = "l", xlab = "", ylab = "Global Active Power (kilowatts)")
dev.off()

