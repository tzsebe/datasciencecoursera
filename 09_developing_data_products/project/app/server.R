library(shiny)
library(shinyjs)
library(ggplot2)

# Constants
G <- 9.8
RAD <- pi/180
HIT_DIST_THRESHOLD <- 2.5
TARGET_X_RANGE <- c(10, 90)
TARGET_Y_RANGE <- c(10, 90)
TAUNTS <- c(
    "Haa-haa you missed!",
    "Geez, are you even trying?",
    "You couldn't hit water if you fell off a boat!",
    "No no no, over HERE!",
    "Hahahahahahahaha",
    "Uh-oh, I think that broke somebody's windshield!",
    "Bwahaha is that all you've got?",
    "... Really? All the way over there?"
)

# Returns initial plot, with only the target showing.
getInitialPlot <- function(x, y, title, colour) {
    pt <- data.frame(x = x, y = y)
    g <- ggplot(pt, aes(x = x, y = y))

    # Add the target
    g <- g + geom_point(size = 10, colour = colour) +
             geom_point(size = 6, colour = "white") +
             geom_point(size = 3, colour = colour)

    # Add "you" at the origin
    g <- g + geom_point(x = 0, y = 0, size = 5, colour = colour)

    # Set the plot canvas limits
    g <- g + xlim(0, 100) + ylim(0, 100)

    # Handle text and return
    g + ggtitle(title) + theme(plot.title = element_text(colour = colour, size = 20), axis.title = element_blank())
}

# Returns the position of your projectile at time t, given initial conditions.
# Supports vectorized "t".
getTrajectoryValue <- function(angle, speed, t) {
    # Basic parabola from high school, nothing to see here.
    x = speed * cos(RAD * angle) * t
    y = speed * sin(RAD * angle) * t - (1/2) * G * t^2

    data.frame(x = x, y = y)
}

# Time t at which the projectile hits the ground after launch.
getTimeToGround <- function(angle, speed) {
    2*speed*sin(RAD*angle)/G
}

# Converts angle and velocity into a bunch of data points for plotting
getParabolicPath <- function(angle, speed) {
    t = seq(0, getTimeToGround(angle, speed), length.out = 100)

    getTrajectoryValue(angle, speed, t)
}

# Figures out the minimal distance between the trajectory and our curve
#
# We basically create a function with just one input (t), and let optimize()
# do all the hard work.
distToCurve <- function(angle, speed, px, py) {
    distFunc <- function(t) {
        traj <- getTrajectoryValue(angle, speed, t)
        sqrt((px - traj$x)^2 + (py - traj$y)^2)
    }

    minDist <- optimize(distFunc, c(0, getTimeToGround(angle, speed)))

    minDist$objective
}

# Is it a hit or a miss? Check the distance of the target to the curve against
# a constant threshold that works well with the size of the target.
isHit <- function(angle, speed, px, py) {
    distToCurve(angle, speed, px, py) < HIT_DIST_THRESHOLD
}

# Whenever we reset, we need a new random location for our target.
getRandomPoint <- function() {
    x <- runif(1, min = TARGET_X_RANGE[1], max = TARGET_X_RANGE[2])
    y <- runif(1, min = TARGET_Y_RANGE[1], max = TARGET_Y_RANGE[2])
    data.frame(x = x, y = y)
}

# Make fun of the user for missing. Because.. haaah you missed!
getTaunt <- function() {
    sample(TAUNTS, 1)
}

shinyServer(
    function(input, output) {
        # Button values can't be reset, so every time we reset the game,
        # we update these baselines, which effectively become the new "zeroes".
        fireButtonBaseline <- 0
        resetButtonBaseline <- 0

        # Declare this outside the scope of all the code below.
        pt <- data.frame(x = 0, y = 0)


        # Responds to both the 'reset' and 'fire' buttons being pressed.

        output$thePlot <- renderPlot({
            # Take a dependency on the reset button here, and reset our baseline.
            if(input$resetButton != resetButtonBaseline) {
                # When the reset button is pressed, we reset fireButtonBaseline to the
                # button's current value. This will cause the (deliberately un-isolated)
                # startup code below to execute.
                resetButtonBaseline <<- input$resetButton
                fireButtonBaseline <<- input$fireButton

                # Enable the input elements we've disabled as part of ending the last game.
                enable('angle')
                enable('speed')
                enable('fireButton')
            }

            # React to the Fire button's state.
            if(input$fireButton == fireButtonBaseline) {
                #
                # This logic executes whenever the game resets, including at startup.
                #
                pt <<- getRandomPoint()
                getInitialPlot(pt$x, pt$y, "Try to hit me, I bet you can't!", "black")
            } else {
                isolate({
                    #
                    # This logic executes whenever the fire button is actually pressed.
                    #

                    # Computation
                    flightPath <- getParabolicPath(input$angle, input$speed)
                    hit <- isHit(input$angle, input$speed, pt$x, pt$y)

                    # Infer display parameters from computation
                    tries <- input$fireButton - fireButtonBaseline
                    title <- ifelse(hit, paste("ARRRR you got me in", tries, ifelse(tries == 1, "try!", "tries!")), getTaunt())
                    colour <- ifelse(hit, "red", "black")

                    # disable our fire button if we've hit our target; the game is over.
                    if(hit) {
                        disable('fireButton')
                        disable('angle')
                        disable('speed')
                    }

                    # Generate our plot
                    g <- getInitialPlot(pt$x, pt$y, title, colour)

                    # Add our trajectory and return
                    g + geom_line(data = flightPath, aes(x = x, y = y), colour = colour)
                })
            }
        })
    }
)


