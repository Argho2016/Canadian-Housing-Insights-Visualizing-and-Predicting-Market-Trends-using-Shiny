# 🏡 Canadian Housing Insights: Visualizing and Predicting Market Trends

Welcome to the **Canadian Housing Insights** Shiny Dashboard — an interactive R application that enables users to explore real estate trends across Canada. With the power of **data visualization**, **geolocation**, and **statistical summaries**, this app provides an intuitive interface for users to gain actionable insights about housing prices, income distribution, and city-by-city comparisons.

---

## 📌 Table of Contents

- [📚 Project Overview](#project-overview)
- [🎯 Features](#features)
- [🛠️ Technologies & Packages Used](#technologies--packages-used)
- [📁 Project Structure](#project-structure)
- [🧠 How the App Works](#how-the-app-works)
- [📊 Dataset Description](#dataset-description)
- [📦 Installation and Running the App](#installation-and-running-the-app)
- [📜 Data Dictionary and User Manual](#data-dictionary-and-user-manual)
- [📸 Screenshots](#screenshots)
- [📝 License](#license)
- [🙋‍♂️ Contact](#contact)

---

## 📚 Project Overview

This Shiny dashboard application was developed to help users—whether researchers, policy makers, or prospective home buyers—understand the Canadian housing landscape using interactive charts, maps, and tables. It allows users to:

- Filter house listings by province, city, price range, bedroom, and bathroom counts.
- Visualize price distributions, compare housing affordability between two cities.
- Explore a map-based view of property locations.
- Understand income and housing dynamics with intuitive plots.
- Review summarized statistics across cities.

The dashboard is completely dynamic, with real-time updates based on user inputs, enhancing the interactivity and user experience.

---

## 🎯 Features

- **Dynamic Input Filtering**: Select province(s), city/cities, price ranges, number of bedrooms and bathrooms.
- **City Comparison**: Compare housing prices between two cities using violin plots.
- **Map View**: Interactive Leaflet map showcasing geolocated listings with detailed popups.
- **Price Distribution**: Histogram of house prices using Plotly.
- **Boxplots & Violin Plots**: City-wise price comparison using ggplot2.
- **Summary Statistics Table**: Average, median, min, and max prices per city.
- **Household Income Visualization**: Simulated income distributions for affordability context.
- **Storytelling Buttons**: Links to data dictionary, user manual, backstory, and full project coverage.

---

## 🛠️ Technologies & Packages Used

### R Programming Language

Built entirely in R, using the **Shiny** web framework.

### 📦 R Packages

| Package        | Purpose                                                                 |
|----------------|-------------------------------------------------------------------------|
| **shiny**       | Web framework to create interactive web applications in R.              |
| **ggplot2**     | For static and layered visualizations like boxplots and violin plots.   |
| **plotly**      | Enables interactivity for ggplot objects (e.g., price distribution).    |
| **dplyr**       | Data manipulation and filtering.                                        |
| **leaflet**     | For rendering dynamic maps with geolocation markers.                    |
| **shinydashboard** | UI enhancements, layout structure, and dashboard components.         |
| **scales**      | Formatting numbers and axis labels (e.g., commas in currency).          |
| **DT**          | Render interactive and filterable data tables in the UI.                |
| **ggcorrplot**  | (Optional, for correlation visualization if added in future).           |
| **randomForest**| (Optional, placeholder for predictive modeling expansion).              |

---

## 📁 Project Structure
├── HouseListings.csv # The dataset used in the app
├── app.R # Main R Shiny app script (UI + Server)
├── README.md # Project description and documentation
├── manim_image.png # Placeholder for the Manim visualization tab
└── www/ # (Optional) For CSS, JS, or additional assets

---

## 🧠 How the App Works

### ✅ Step-by-Step Logic

1. **Data Loading & Cleaning:**
   - `HouseListings.csv` is loaded with proper encoding handling.
   - Price values are cleaned (removal of commas and converted to numeric).
   - Latitude and Longitude are parsed for mapping.
   - A simulated `Household_Income` column is added (if missing).

2. **User Interface (UI):**
   - Filters include province, city, price range, bedrooms, and bathrooms.
   - Action buttons provide access to manual, dictionary, and storytelling.

3. **Reactive Server Logic:**
   - Data is filtered based on user input selections using `reactive()` expressions.
   - Multiple outputs (`renderPlotly`, `renderPlot`, `renderLeaflet`, `renderDT`) generate:
     - Histogram of price distribution.
     - Boxplot of city-wise price.
     - Leaflet map of listings.
     - Violin plot comparing two selected cities.
     - Summary statistics data table.

4. **Visualizations:**
   - Consistent themes, formatted labels, and dynamic titles enhance readability.

5. **Validation and Notifications:**
   - Ensures exactly **two cities** are selected for comparison.
   - Filters only appear when valid inputs are provided.

---

## 📊 Dataset Description

The dataset used (`HouseListings.csv`) contains fictional or sample housing data across Canadian provinces. The columns include:

| Column Name        | Description                                 |
|--------------------|---------------------------------------------|
| `Price`            | Listing price of the house (in CAD)         |
| `City`             | City where the house is located             |
| `Province`         | Canadian province of the listing            |
| `Latitude`         | Geographical latitude for mapping           |
| `Longitude`        | Geographical longitude for mapping          |
| `Number_Beds`      | Number of bedrooms                          |
| `Number_Baths`     | Number of bathrooms                         |
| `Household_Income` | Simulated average household income (if missing) |

> 🔎 **Note**: If you want to use your own dataset, make sure it follows the same schema and formatting.

---

## 📦 Installation and Running the App

### 🧰 Prerequisites

Ensure you have **R** and **RStudio** installed. Then, install required packages (if not already installed):

```r
install.packages(c("shiny", "ggplot2", "plotly", "dplyr", "leaflet", 
                   "shinydashboard", "scales", "DT", "ggcorrplot", "randomForest"))
```

## 🌍 Why This Project Matters

The Canadian housing market has become a focal point in national discussions around **affordability**, **urban development**, and **economic inequality**. With rising property prices, evolving city demographics, and increased pressure on housing supply, gaining **transparent, data-driven insights** into the real estate landscape is more important than ever.

This project contributes meaningfully by:

- ✅ **Democratizing Access to Data**: It transforms raw housing data into a user-friendly dashboard, allowing non-technical users—including students, first-time home buyers, policymakers, and educators—to make informed decisions.

- 📉 **Uncovering Trends and Inequities**: The visualizations help identify cities or regions where housing prices significantly outpace average incomes, sparking important conversations about affordability and living standards.

- 🧠 **Enhancing Public Understanding**: Through storytelling, visual analytics, and dynamic filtering, the app turns abstract data into a clear, intuitive, and educational experience.

- 📍 **Local-Level Insight**: Most government and corporate reports focus on national or provincial averages. This project enables **granular city-level comparisons** that are often overlooked in mainstream analysis.

- 🏗️ **Scalability and Customization**: Built in R Shiny, the application is modular, open-source, and easily extendable—making it an ideal base for academic research, hackathons, or commercial tools.

In an age where data literacy is vital, this project serves as both a learning tool and a civic engagement platform—bridging the gap between **complex housing data** and **real-world decision making**.

