# Export Analysis and Visualization

This project provides tools to analyze and visualize export data, focusing on the FOB (Free On Board) values and volumes. The project processes raw data, performs various aggregations, and generates insightful plots, including maps, bar charts, and combined line-bar visualizations.

---

## Features
- **Data Cleaning**: Handles missing values and converts data for analysis.
- **Aggregations**: Summarizes data by country, exporter, and year.
- **Visualizations**:
  - World map showing FOB values by country.
  - Bar charts for top countries and exporters.
  - Combined line-bar plots for annual export volumes and FOB values.

---

## Requirements
The script uses the following R libraries:
- `ggplot2`
- `dplyr`
- `scales`
- `rnaturalearth`
- `rnaturalearthdata`
- `viridis`
- `countrycode`
- `sf`
- `gridExtra`
- `cowplot`

Install any missing libraries automatically by running the script.

---

## Usage

1. **Prepare the Data**:
   - Place the cleaned dataset file (`Dados_Bovinos_completos_Limpos.csv`) in the working directory.
   - Ensure it contains columns like `country_of_destination`, `valor_fob`, `exportador`, `volume`, and `ano`.

2. **Run the Script**:
   - Execute the script in R or RStudio.
   - The script:
     - Reads and cleans the data.
     - Generates multiple visualizations.
     - Outputs maps and charts for analysis.

3. **Outputs**:
   - **Map**: Displays FOB values by destination country in millions of USD.
   - **Top 10 Countries & Exporters**: Bar charts of the highest FOB values.
   - **Annual Trends**: Line and bar charts for volumes and FOB values over time.

---

## Sample Visualizations
### 1. World Map of FOB Values
Displays FOB values in millions of dollars for each destination country.

### 2. Top 10 Countries by FOB Values
A bar chart of the top destinations.

### 3. Annual Trends
Combined line-bar charts for annual volumes and FOB values.

---

## Customization
You can adjust the script to:
- Use a different dataset.
- Add or modify visualizations.

---

## License
This project is open-source and free to use under the MIT License.

---

## Acknowledgments
- Data source: Custom dataset of export information.
- Built with [R](https://www.r-project.org/).
