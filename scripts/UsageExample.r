#' @title Usage example of G2SFCA (Kim and Kwon 2022)
#' @author Kyusik Kim
#' @description Calculate G2SFCA using sample data
#' @import 
#'      data.table
#'      tidy.verse
#'      sf
#'      tmap

requiredPackages <- c("data.table", "tidyverse", "sf", "tmap")
for (p in requiredPackages) {
    if (!require(p, character.only = TRUE)) install.packages(p)
    library(p, character.only = TRUE)
}


# Set working directory if you need
# setwd()

# Read G2SFCA function
source("scripts/G2SFCA.R")

# Import data
demand_data <- fread("data/demand_data.csv")
supply_data <- fread("data/supply_data.csv")
network_data <- fread("data/OD_TravelTime.csv")

# Set parameters for G2SFCA
cost_col <- "travel_cost"
demand_id <- "demand_id"
demand_col <- "population"
supply_id <- "supply_id"
supply_col <- "physician"
catchment <- 15
impedance_beta <- 50

# Run G2SFCA
result <- Generalized2SFCA(
    network_data = network_data,
    cost_col = cost_col,
    demand_data = demand_data,
    demand_id = demand_id,
    demand_col = demand_col,
    supply_data = supply_data,
    supply_id = supply_id,
    supply_col = supply_col,
    catchment = catchment,
    impedance_beta = impedance_beta
)

# Store G2SFCA
rj_res <- result[[1]]
ai_res <- result[[2]]

# Visualize G2SFCA scores
seoul <- read_sf("data/seoul.gpkg")
seoul <- seoul %>%
    left_join(ai_res, by = c("TOT_REG_CD" = "demand_id"))

tm_shape(seoul) +
    tm_fill(col = "Ai", style = "quantile", n = 5) +
    tm_borders(col = 'gray40', lwd = .7)