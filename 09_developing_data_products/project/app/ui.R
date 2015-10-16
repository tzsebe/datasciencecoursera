library(shiny)
library(shinyjs)

MIN_ANGLE_DEG <- 1
MAX_ANGLE_DEG <- 89
MIN_SPEED <- 1
MAX_SPEED <- 50

shinyUI(fluidPage(
    useShinyjs(),
    headerPanel(h2("Hit The Monkey!", align = "center")),
    tabsetPanel(
        tabPanel("Game",
            sidebarPanel(
                sliderInput('angle', "Angle", min = MIN_ANGLE_DEG, max = MAX_ANGLE_DEG, value = 1, step = 1),
                sliderInput('speed', "Speed", min = MIN_SPEED, max = MAX_SPEED, value = 1),
                actionButton('fireButton', "Fire!"),
                actionButton('resetButton', "Reset")
            ),
            mainPanel(
                plotOutput('thePlot')
            )
        ),
        tabPanel("Instructions",
            # Meh I know I should setup an html file for this, but don't feel like it. :-)
            h3("What's all this, then?"),
            p(tags$i("Hit The Monkey"), "is a simple parabolic trajectory target practice game. An obnoxious monkey is up in a tree, making fun of passers-by! It's YOUR job to get him to leave... by throwing coconuts at him (how else?)"),
            h3("Instructions for use:"),
            tags$ol(
                tags$li("You are at the origin (0, 0)."),
                tags$li("The monkey is at a random position, denoted by a target symbol."),
                tags$li("Select the angle at which you want to launch your coconut."),
                tags$li("Select the speed at which you want to launch your coconut."),
                tags$li("Hit the 'Fire!' button to launch your coconut at the monkey."),
                tags$li("Don't let his mockery get to you. Hit the monkey!"),
                tags$li("Hit the 'Reset' button to start over/replay.")
            )
        )
    )
))
