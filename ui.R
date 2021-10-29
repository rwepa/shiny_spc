# file     : shiny_spc
# author   : Ming-Chang Lee
# date     : 2021.11.06
# email    : alan9956@gmail.com
# RWEPA    : http://rwepa.blogspot.tw/
# GitHub   : https://github.com/rwepa
# Encoding : UTF-8
# File     : ui.R

# verify packages
# need.packages <- c("shiny", "shinythemes", "DT", "qcc", "plotly")
# verify.packages <- function(need.packages) {
#   for (x in need.packages) {
#     if (!x %in% installed.packages()[, "Package"])
#       install.packages(x)
#   }
# }
# verify.packages(need.packages)

# suppress startup message
suppressPackageStartupMessages(library("shiny"))
suppressPackageStartupMessages(library("shinythemes"))
suppressPackageStartupMessages(library("DT"))
suppressPackageStartupMessages(library("plotly"))

library(shiny)
library(shinythemes)
library(DT)
library(plotly)



# Define UI for application that draws a histogram
shinyUI(
  navbarPage(
    # Application title
    title =
      "RWEPA - shiny SPC_v21.11.06, Email:alan9956@gmail.com, Web:http://rwepa.blogspot.com/",
    
    # 1.Upload file -----
    
    # Valid themes:
    # cerulean, cosmo, cyborg, darkly, flatly
    # journal, lumen, paper, readable, sandstone,
    # simplex, slate, spacelab, superhero, united, yeti
    
    theme = shinytheme("flatly"),
    
    tabPanel("*Upload file",
             sidebarLayout(
               sidebarPanel(
                 fileInput(
                   "file1",
                   "Choose CSV File",
                   multiple = FALSE,
                   accept = c("text/csv",
                              "text/comma-separated-values,text/plain",
                              ".csv")
                 ),
                 
                 # Horizontal line ----
                 
                 tags$hr(),
                 
                 # Input: Checkbox if file has header ----
                 checkboxInput("header", "Header", TRUE),
                 
               ),
               
               mainPanel(textOutput("file_message"))
             )),
    
    # 2. Data view -----
    
    tabPanel("*Data",
             sidebarLayout(
               sidebarPanel(
                 radioButtons(
                   inputId = "disp",
                   label = "Display",
                   choices = c(All = "all", Head = "head"),
                   selected = "all"
                 )
               ),
               
               mainPanel(dataTableOutput("table"))
             )),
    
    # 3. Summary -----
    
    tabPanel("*Summary",
             verbatimTextOutput("summary")),
    
    # 4. Quality Control Chart -----
    
    tabPanel("*xbar/R Chart",
      sidebarLayout(
        sidebarPanel(
          
          # check new data
          checkboxInput(
            inputId = "checknewdata",
            label = "New Data"
          ),
          
          # select new data filter
          numericInput(
            inputId = "newdata",
            label = "Started Index for New Data",
            value = 20,
            min = 1,
            max = Inf,
            step = 1
          )
        ),
        
        mainPanel(plotOutput("qualityplot", height=700))
      )
    ),
    
    # 5. plotly chart
    tabPanel("*Interactive Chart",
             plotlyOutput("plotlygraph")),
    
    # 6. About
    tabPanel("*About", 
             pre(includeText("help/README.txt")))
  )
)
# end