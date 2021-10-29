# file     : shiny_spc
# author   : Ming-Chang Lee
# date     : 2021.11.06
# email    : alan9956@gmail.com
# RWEPA    : http://rwepa.blogspot.tw/
# GitHub   : https://github.com/rwepa
# Encoding : UTF-8
# File     : server.R

# Download demo data -----
# spc_wafer_with_header.csv
# https://github.com/rwepa/DataDemo/blob/master/spc_wafer_with_header.csv

# spc_pistonrings_without_header.csv
# https://github.com/rwepa/DataDemo/blob/master/spc_pistonrings_without_header.csv

# suppress startup message
suppressPackageStartupMessages(library("qcc"))
suppressPackageStartupMessages(library("shiny"))
suppressPackageStartupMessages(library("DT"))
suppressPackageStartupMessages(library("plotly"))

library(shiny)
library(DT)
library(qcc)
library(plotly)

progShow <- function(showLabels="Data processing ... ") {
  
  withProgress(message = showLabels, value = 0, {
    n <- 100
    for (i in 1:n) {
      incProgress(1/n, detail = paste0(i, "%"))
      Sys.sleep(0.01)
    }
  })
  
}


# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  mydfshow <- reactive({
    df <- read.csv(input$file1$datapath, header = input$header)
    
    if(input$disp == "head") {
      return(head(df))
    }
    else {
      return(df)
    }
  })
  
  mydf <- reactive({
    df <- read.csv(input$file1$datapath, header = input$header)
    return(df)
  })
  
  # 1. Upload message -----
  output$file_message <- renderText({
    
    req(input$file1)
    progShow()
    return("Upload is complete, please select the Data.")
    
  })
  
  # 2. Data view  -----
  output$table <- DT::renderDataTable({
    
    req(input$file1)
    df <- mydfshow()
    datatable(data=df, options=list(searching=FALSE))
    
  })
  
  # 3. Summary ----
  output$summary <- renderPrint({
    
    req(input$file1)
    summary(mydf())
    
  })
  
  # 4. Quality Control Chart -----
  output$qualityplot <- renderPlot({
    
    req(input$file1)
    
    myfile <- input$file1
    
    op <- par(mfrow=c(2,1))
    
    df <- mydf()
    
    if (input$checknewdata == FALSE) {
      
      qa <- qcc(df,
                type="xbar",
                title="X_bar Chart",
                data.name=myfile$name,
                plot=FALSE)
      
      qb <- qcc(df,
                type="R",
                title="R chart",
                data.name=myfile$name,
                plot=FALSE)
      
      plot(qa, restore.par=FALSE)
      plot(qb)
      
    } else {
      
      qa <- qcc(df[1:(input$newdata-1),],
                type = "xbar",
                newdata=df[input$newdata: nrow(df),],
                title="X_bar Chart",
                data.name=myfile$name,
                newdata.name = "New data",
                plot=FALSE)
      
      qb <- qcc(df[1:(input$newdata-1),],
                type = "R",
                newdata=df[input$newdata: nrow(df),],
                title="R chart",
                data.name=myfile$name,
                newdata.name = "New data",
                plot=FALSE)
      
      plot(qa, restore.par=FALSE)
      plot(qb)
    }
    
  })
  
  # 5. plotly chart
  
  output$plotlygraph <- renderPlotly({
    
    req(input$file1)
    
    df <- mydf()
    
    myqcc <- qcc(df, type="xbar")
    
    data <- data.frame(x=1:length(myqcc$statistics), value=myqcc$statistics)
    
    fig <- plot_ly(data, x = ~x, y = ~value, 
                   type = 'scatter', 
                   mode = 'lines+markers')
    
    centerline <- list(
      x = length(myqcc$statistics),
      y = myqcc$center,
      xanchor = 'left',
      yanchor = 'middle',
      text = ~paste('CL=', round(myqcc$center,3)),
      showarrow = FALSE)
    
    UCLline <- list(
      x = length(myqcc$statistics),
      y = myqcc$limits[2],
      xanchor = 'left',
      yanchor = 'middle',
      text = ~paste('UCL=', round(myqcc$limits[2],3)),
      showarrow = FALSE)
    
    LCLline <- list(
      x = length(myqcc$statistics),
      y = myqcc$limits[1],
      xanchor = 'left',
      yanchor = 'middle',
      text = ~paste('UCL=', round(myqcc$limits[1],3)),
      showarrow = FALSE)
    
    fig %>%
      layout(xaxis = list(showgrid = FALSE)) %>%
      # CL
      add_segments(x = 0, xend = length(myqcc$statistics), 
                   y = myqcc$center, yend = myqcc$center, 
                   color = I("darkgray"),
                   hoverinfo="text",
                   text=paste0("Center=", myqcc$center)) %>%
      # UCL
      add_segments(x = 0, xend = length(myqcc$statistics), 
                   y = myqcc$limits[2], yend = myqcc$limits[2], 
                   color = I("black"),
                   hoverinfo="text",
                   text=paste0("UCL=", myqcc$limits[2]),
                   line = list(dash = "dash")) %>%
      # LCL
      add_segments(x = 0, xend = length(myqcc$statistics), 
                   y = myqcc$limits[1], yend = myqcc$limits[1], 
                   color = I("black"),
                   hoverinfo="text",
                   text=paste0("LCL=", myqcc$limits[1]),
                   line = list(dash = "dash")) %>%
      layout(title = 'Xbar Chart',
             xaxis = list(title = 'Groups'),
             yaxis = list (title = 'Groups summary statistics')) %>%
      layout(annotations = centerline, showlegend = FALSE) %>%
      layout(annotations = UCLline, showlegend = FALSE) %>%
      layout(annotations = LCLline, showlegend = FALSE)
  })
  
})
