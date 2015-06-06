library(sqldf)
library(lubridate)

# Load the file and add a DateTime to the DF.
data <- read.csv.sql("household_power_consumption.txt", "select * from file where Date in ('1/2/2007', '2/2/2007')", header = TRUE, sep = ";")
data$DateTime <- dmy_hms(paste(data$Date, data$Time))

# Generate Plot
png(filename = "plot4.png", width = 480, height = 480, bg = "transparent")

# 2x2 graphs, in column order
par(mfcol = c(2, 2))

with(data, {
    # Plot 1: Global active power over time
    plot(DateTime, Global_active_power, type = "l", xlab = "", ylab = "Global Active Power")

    # Plot 2: Energy sub metering over time
    plot(DateTime, Sub_metering_1, type = "l", col = "black", xlab = "", ylab = "Energy sub metering")
    points(DateTime, Sub_metering_2, type = "l", col = "red")
    points(DateTime, Sub_metering_3, type = "l", col = "blue")
    legend("topright", legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), col = c("black", "red", "blue"), lty = 1, bty = "n")

    # Plot 3: Voltage over time
    plot(DateTime, Voltage, xlab = "datetime", type = "l")

    # Plot 4: Global reactive power over time
    plot(DateTime, Global_reactive_power, xlab = "datetime", type = "l")
})

dev.off()


