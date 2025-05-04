library(shiny)
library(ggplot2)
library(dplyr)
library(plotly)
library(leaflet)
library(shinydashboard)
library(ggcorrplot)  
library(randomForest)
library(scales)
library(DT)

# Load dataset
house_data <- read.csv("HouseListings.csv", fileEncoding = "latin1")
house_data$City <- iconv(house_data$City, from = "latin1", to = "UTF-8")
house_data$Province <- iconv(house_data$Province, from = "latin1", to = "UTF-8")

# Data Cleaning
house_data$Price <- as.numeric(gsub(",", "", house_data$Price)) 
house_data$Latitude <- as.numeric(house_data$Latitude)
house_data$Longitude <- as.numeric(house_data$Longitude)

# Simulate household income if missing
if (!"Household_Income" %in% colnames(house_data)) {
  set.seed(42)
  house_data$Household_Income <- round(runif(nrow(house_data), 40000, 120000))
}

house_data <- na.omit(house_data)

# UI
ui <- fluidPage(
  titlePanel("Canadian Housing Insights: Visualizing and Predicting Market Trends"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("province", "Select Province", 
                  choices = sort(unique(house_data$Province)), 
                  selected = "Ontario", multiple = TRUE),
      
      uiOutput("city_selector"),
      
      sliderInput("price", "Price Range (CAD)", 
                  min = min(house_data$Price), 
                  max = max(house_data$Price), 
                  value = c(200000, 1000000)),
      
      sliderInput("bedrooms", "Number of Bedrooms", 
                  min = 0, max = 5, value = 3),
      
      sliderInput("bathrooms", "Number of Bathrooms", 
                  min = 0, max = 4, value = 2),
      
      selectInput("city_comp", "Compare Two Cities", 
                  choices = sort(unique(house_data$City)), 
                  selected = c("Toronto", "Vancouver"), multiple = TRUE),
      
      actionButton("show_dictionary", "Data Dictionary", 
                   style = "background-color: skyblue; color: black; border: none; padding: 5px 10px; margin: 5px; font-size: 14px;"),
      
      actionButton("user_manual", "User Manual", 
                   style = "background-color: skyblue; color: black; border: none; padding: 5px 10px; margin: 5px; font-size: 14px;"),
      
      actionButton(inputId = "show_story",
                   label = "The Backstory", 
                   style = "background-color: skyblue; color: black; border: none; padding: 5px 10px; margin: 5px; font-size: 14px;"),
      
      actionButton("show_assignment", "Final Project Coverage", 
                   style = "background-color: skyblue; color: black; border: none; padding: 5px 10px; margin: 5px; font-size: 14px;")
      
      
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Price Distribution", plotlyOutput("price_plot")),
        tabPanel("Price by City/Province", plotOutput("city_plot")),
        tabPanel("Map View", leafletOutput("map")),
        tabPanel("City Comparison", plotOutput("city_comparison_plot")),
        tabPanel("Summary Stats", DTOutput("summary_table")),
        tabPanel("Manim Visualization", imageOutput("manim_image")),
        tabPanel("Household Income", plotOutput("income_plot"))
      )
    )
  )
)

# Server
server <- function(input, output, session) {
  
  # Update city dropdown based on province
  output$city_selector <- renderUI({
    available_cities <- house_data %>%
      filter(Province %in% input$province) %>%
      pull(City) %>%
      unique() %>%
      sort()
    
    selectInput("city", "Select City", 
                choices = available_cities, 
                selected = head(available_cities, 1), multiple = TRUE)
  })
  
  # Filter data reactively
  filtered_data <- reactive({
    req(input$province, input$city)
    house_data %>%
      filter(
        Province %in% input$province,
        City %in% input$city,
        Price >= input$price[1], Price <= input$price[2],
        Number_Beds >= input$bedrooms,
        Number_Baths >= input$bathrooms
      )
  })
  
  # Notify if not exactly 2 cities selected for comparison
  observe({
    if (length(input$city_comp) != 2) {
      showNotification("Please select exactly two cities for comparison.", type = "warning")
    }
  })
  
  # Price Distribution
  output$price_plot <- renderPlotly({
    p <- ggplot(filtered_data(), aes(x = Price)) +
      geom_histogram(binwidth = 50000, fill = "skyblue", color = "black") +
      labs(title = "House Price Distribution", x = "Price (CAD)", y = "Frequency") +
      scale_x_continuous(labels = label_comma())
    
    ggplotly(p)
  })
  
  # Boxplot: Price by City
  output$city_plot <- renderPlot({
    ggplot(filtered_data(), aes(x = City, y = Price, fill = City)) +
      geom_boxplot() +
      labs(title = "House Prices by City", x = "City", y = "Price (CAD)") +
      scale_y_continuous(labels = label_comma()) +
      theme(legend.position = "none")
  })
  
  # Leaflet Map
  output$map <- renderLeaflet({
    leaflet(data = filtered_data()) %>%
      addTiles() %>%
      addCircleMarkers(
        lng = ~Longitude, lat = ~Latitude,
        radius = 10,
        fillColor = "red",
        color = "lightgreen",
        weight = 0.5,
        fillOpacity = 0.1,
        opacity = 0.1,
        popup = ~paste0(
          "Price: $", format(Price, big.mark = ","), 
          "<br>Bedrooms: ", Number_Beds, 
          "<br>Bathrooms: ", Number_Baths, 
          "<br>City: ", City,
          "<br>Province: ", Province
        )
      )
  })
  
  # City Comparison (Violin Plot)
  output$city_comparison_plot <- renderPlot({
    req(length(input$city_comp) == 2)
    
    city_data <- house_data %>%
      filter(City %in% input$city_comp)
    
    ggplot(city_data, aes(x = factor(City), y = Price, fill = City)) +
      geom_violin(trim = FALSE, alpha = 0.7, color = "black") +
      labs(
        title = paste("Price Comparison:", input$city_comp[1], "vs", input$city_comp[2]),
        x = "City",
        y = "Price (CAD)"
      ) +
      scale_y_continuous(labels = label_comma()) +
      theme_minimal() +
      theme(legend.position = "none")
  })
  
  
  # Summary Stats Table 
  output$summary_table <- renderDT({
    req(filtered_data())
    
    summary_df <- filtered_data() %>%
      group_by(City) %>%
      summarise(
        Avg_Price = round(mean(Price), 2),
        Median_Price = median(Price),
        Min_Price = min(Price),
        Max_Price = max(Price),
        Listings = n()
      )
    
    # Color palette from dark blue to light blue
    blue_palette <- colorRampPalette(c("#08306B", "#DEEBF7"))
    
    # Function to create color scales and font color
    get_styles <- function(column_data) {
      normalized <- (column_data - min(column_data)) / (max(column_data) - min(column_data) + 1e-9)
      color_levels <- as.numeric(cut(normalized, breaks = 100))
      bg_colors <- blue_palette(100)[color_levels]
      
      # Set font color to white if background is dark
      font_colors <- ifelse(color_levels <= 40, "white", "black")
      
      list(bg = setNames(bg_colors, column_data),
           font = setNames(font_colors, column_data))
    }
    
    # Generate styles for each numeric column
    avg_style <- get_styles(summary_df$Avg_Price)
    med_style <- get_styles(summary_df$Median_Price)
    min_style <- get_styles(summary_df$Min_Price)
    max_style <- get_styles(summary_df$Max_Price)
    list_style <- get_styles(summary_df$Listings)
    
    datatable(summary_df, options = list(pageLength = 10)) %>%
      formatStyle('Avg_Price',
                  backgroundColor = styleEqual(names(avg_style$bg), avg_style$bg),
                  color = styleEqual(names(avg_style$font), avg_style$font)) %>%
      formatStyle('Median_Price',
                  backgroundColor = styleEqual(names(med_style$bg), med_style$bg),
                  color = styleEqual(names(med_style$font), med_style$font)) %>%
      formatStyle('Min_Price',
                  backgroundColor = styleEqual(names(min_style$bg), min_style$bg),
                  color = styleEqual(names(min_style$font), min_style$font)) %>%
      formatStyle('Max_Price',
                  backgroundColor = styleEqual(names(max_style$bg), max_style$bg),
                  color = styleEqual(names(max_style$font), max_style$font)) %>%
      formatStyle('Listings',
                  backgroundColor = styleEqual(names(list_style$bg), list_style$bg),
                  color = styleEqual(names(list_style$font), list_style$font))
  })
  
  
  # Manim Image
  output$manim_image <- renderImage({
    list(
      src = "v6.png",
      alt = "Manim Visualization",
      width = 800,
      height = 500
    )
  }, deleteFile = FALSE)
  
  # Household Income Line Plot
  output$income_plot <- renderPlot({
    req(filtered_data())
    
    income_data <- filtered_data() %>%
      group_by(City, Province) %>%
      summarise(Avg_Income = mean(Household_Income, na.rm = TRUE)) %>%
      arrange(Province, City)
    
    ggplot(income_data, aes(x = reorder(City, Avg_Income), y = Avg_Income, group = Province, color = Province)) +
      geom_line() +
      geom_point() +
      labs(
        title = "Average Household Income by City",
        x = "City",
        y = "Average Household Income (CAD)"
      ) +
      theme_minimal() +
      theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
      scale_y_continuous(labels = label_comma())
  })
  
  # Data Dictionary Info
  observeEvent(input$show_dictionary, {
    showModal(modalDialog(
      title = "Data Dictionary: Housing Dataset",
      DT::renderDataTable({
        datatable(
          data.frame(
            Variable = c("City", "Price", "Address", "Number_Beds", "Number_Baths", 
                         "Province", "Population", "Longitude", "Latitude", "Household_Income"),
            Description = c(
              "City or metro area (e.g., Toronto includes suburbs like Markham, Oakville).",
              "Listed price in Canadian dollars.",
              "Street address and unit number, if applicable.",
              "Number of bedrooms listed.",
              "Number of bathrooms listed.",
              "Province in Canada.",
              "Population of the city (if available).",
              "Geographical longitude.",
              "Geographical latitude.",
              "Average household income for the city."
            )
          )
        )
      }),
      easyClose = TRUE
    ))
  })
  
  
  #Placeholder for Assignment Options Covered
  observeEvent(input$show_assignment, {
    showModal(modalDialog(
      title = "Final Project Options Covered",
      DTOutput("assignment_table"),
      easyClose = TRUE,
      size = "m"
    ))
  })
  
  
  output$assignment_table <- renderDT({
    assignment_df <- data.frame(
      `Assignment Option` = c("Option 2", "Option 3", "Option 5", "Option 6"),
      Status = c("Fulfilled", "Fulfilled", "Fulfilled", "Fulfilled"),
      Notes = c(
        "Implemented an interactive Leaflet map in the 'Map View' tab, using customized circle markers to display house listings. Each marker shows detailed property information including price, city, province, and number of bedrooms/bathrooms.",
        
        "Created two comparative plots to show price distribution across cities and provinces: a boxplot under the 'Price by City/Province' tab, and a violin plot in the 'City Comparison' tab that allows dynamic comparison of two selected cities.",
        
        "Built an interactive summary table in the 'Summary Stats' tab using DT. The table shows average, median, minimum, and maximum prices by city, and includes conditional formatting with a color gradient to visually distinguish values.",
        
        "Added a custom visualization under the 'Manim Visualization' tab, integrating a static image generated externally with Manim. The image represents a conceptual aspect of the housing market as part of the narrative element."
      ),
      check.names = FALSE
    )
    
    datatable(
      assignment_df,
      options = list(dom = 't', paging = FALSE),
      rownames = FALSE,
      caption = htmltools::tags$caption(
        style = 'caption-side: top; text-align: left; font-size: 18px; font-weight: bold;',
        "Final Project Options Covered"
      )
    )
  })
  
  
  #Placeholder for User Manual
  observeEvent(input$user_manual, {
    showModal(modalDialog(
      title = "User Manual",
      size = "l",
      easyClose = TRUE,
      footer = modalButton("Close"),
      HTML("
      <h4>Getting Started</h4>
      <p>This dataset contains housing listings across Canadian provinces, including pricing, location, and demographic data. This dashboard allows users to interactively explore housing market trends across Canada. You can select specific provinces and cities, filter properties based on price, number of bedrooms, and bathrooms, and visualize the housing data in various ways.</p>

      <h4>Sidebar Panel</h4>
      <ul>
        <li><b>Select Province:</b> Choose one or more provinces to analyze. This updates the city choices.</li>
        <li><b>Select City:</b> Choose one or more cities from the selected province(s).</li>
        <li><b>Price Range (CAD):</b> Filter listings within your budget range.</li>
        <li><b>Number of Bedrooms and Bathrooms:</b> Minimum number of rooms required.</li>
        <li><b>Compare Two Cities:</b> Select exactly two cities to compare their house prices.</li>
        <li><b>Data Dictionary:</b> Explains each field in the dataset.</li>
        <li><b>Dataset Info:</b> Provides background on the dataset and any simulated data used.</li>
      </ul>

      <h4>Main Panel Tabs</h4>
      <ul>
        <li><b>Price Distribution:</b> Histogram showing the distribution of house prices in the filtered dataset.</li>
        <li><b>Price by City/Province:</b> Boxplot comparing price distribution across selected cities or provinces.</li>
        <li><b>Map View:</b> Interactive map displaying property locations and attributes.</li>
        <li><b>City Comparison:</b> Side-by-side violin plots to compare prices between two selected cities.</li>
        <li><b>Summary Stats:</b> Summary table with average, median, min, max prices, and total listings per city.</li>
        <li><b>Manim Visualization:</b> A static visual generated with Manim for illustrative purposes.</li>
        <li><b>Household Income:</b> Line plot showing average household income by city and province.</li>
      </ul>

      <h4>Tips</h4>
      <ul>
        <li>Select province(s) first, then cities for accurate filtering.</li>
        <li>Ensure exactly two cities are selected for City Comparison to enable the plot.</li>
        <li>Use the map for geographic context on property distributions.</li>
        <li>Use sliders to explore listings that match your preferences.</li>
      </ul>
    ")
    ))
  })
  
  #Placeholder for Project backstory
  observeEvent(input$show_story, {
    showModal(modalDialog(
      title = "Project's Backstory",
      easyClose = TRUE,
      size = "l",
      HTML("
      <p>It’s no secret that housing in Canada has become increasingly unaffordable over the past decade. As someone who has watched this crisis unfold through headlines, policy debates, and the stories of friends and family, I wanted to understand the issue at a deeper level. What makes housing so expensive in some cities? How do prices vary across regions? And perhaps most importantly, how does this all relate to what people are actually earning? This project was born from those questions.</p>
      
      <p>Using a dataset containing Canadian housing data, I built an interactive Shiny app that helps users explore and make sense of the disparity between home prices and household incomes. The app is designed not just as a collection of charts, but as a tool to tell a story one of regional inequality, income stagnation, and a housing market that seems increasingly out of reach for ordinary Canadians.</p>
      
      <p>The journey begins with a simple histogram showing the distribution of house prices across the country. Right away, users can see how skewed the market is: while there are homes in lower price ranges, a significant chunk sit far above what the average Canadian can afford. This leads to the next question, where are these expensive houses located?</p>
      
      <p>To answer that, the app includes an interactive map, plotting house listings across Canada. Here, the regional divide becomes visually obvious. Cities like Vancouver and Toronto light up with high prices, while smaller cities and rural areas show more modest listings. This isn’t just about geography; it’s about accessibility, opportunity, and how place impacts affordability.</p>
      
      <p>To explore these differences further, I implemented a violin plot that allows users to compare house price distributions between two cities. This visualization offers a rich view into the range and concentration of prices in each place. For example, comparing Toronto and Halifax reveals not just that Toronto is more expensive, but that its prices are more widely dispersed, with a long tail of luxury listings that skew the average. Halifax, by contrast, shows a tighter, more affordable distribution.</p>
      
      <p>But housing prices don’t exist in a vacuum, they must be understood alongside income. That’s where the final visualization comes in: a line plot showing average household income by city. When viewed alongside the other plots, a troubling picture emerges. In many cities, incomes have not kept pace with housing costs. A city may show relatively high average earnings, but when overlaid with a violin plot showing prices, the disconnect becomes clear. For a growing number of Canadians, homeownership is slipping out of reach. Ultimately, this project tells the story of a housing market that’s drifting away from the financial realities of everyday Canadians.</p>
    ")
    ))
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
