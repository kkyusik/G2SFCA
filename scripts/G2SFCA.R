#' @title G2SFCA function
#' @author Kyusik Kim
#' @import data.table
#' @param 
#'      network_data
#'      cost_col
#'      demand_data
#'      demand_id
#'      demand_col
#'      supply_data
#'      supply_id
#'      supply_col
#'      catchment
#'      impedance_beta
#' @usage  
#'      result <- Generalized2SFCA()
#'      rj <- result[[1]]
#'      ai <- result[[2]]

requiredPackages = c("data.table")
for (p in requiredPackages) {
    if (!require(p, character.only = TRUE)) install.packages(p)
    library(p, character.only = TRUE)
}

# G2SFCA with gravity function
#' This method was developed by Dai (2010), but the Gaussian function is replaced by e^{-d{ij}^2 / beta}

Generalized2SFCA <- function(network_data,
                             cost_col,
                             demand_data,
                             demand_id,
                             demand_col,
                             supply_data,
                             supply_id,
                             supply_col,
                             catchment = 30,
                             impedance_beta) {

    # threshold is travel length (distance or time)

    #' Argument description
    #'      network_data: data that has OD cost matrix (data.frame)
    #'      demand_data: data that includes demand, such as population (data.frame)
    #'      supply_data: data that is supply location such as clinics (data.frame)
    #'      catchment: the range of travel length (numeric)
    #'      capacity: information that is considered as supply such as number of physicians, beds, or something others
    #'      demand_id: define spatial unit such as ZIP, census tract, or county (join key of demand_data)
    #'      demand_col: demand_col means column name of population
    #'      cost_col: The name of cost column
    #'      supply_id: identifier of supply location or facility
    #'      impedance_beta: beta value for Gaussian decay function

    #' Return
    #' This function returns Rj and Ai as list
    #' Usage:
    #'      result <- Generalized2SFCA()
    #'      rj_result <- result[[1]]
    #'      ai_result <- result[[2]]


    gauss_w <- function(dij, beta) {
        #' Gaussian distance decay function
        #' W = e^(-d^2/a)
        exp(-dij^2 / beta)
    }

    cat("Procedure started for", demand_col)
    cat("\n")
    # Data preparation
    ## Convert id to character
    network_data[[demand_id]] <- as.character(network_data[[demand_id]])
    network_data[[supply_id]] <- as.character(network_data[[supply_id]])
    demand_data[[demand_id]] <- as.character(demand_data[[demand_id]])
    supply_data[[supply_id]] <- as.character(supply_data[[supply_id]])

    ## Convert DT
    network_data <- as.data.table(network_data)
    demand_data <- as.data.table(demand_data)
    supply_data <- as.data.table(supply_data)

    ## Set demand data
    vars <- c(demand_id, demand_col)
    demand_data <- demand_data[, ..vars]

    ## Set supply data
    vars <- c(supply_id, supply_col)
    supply_data <- supply_data[, ..vars]

    ## Join demand and supply to network data
    network_data <- merge(network_data, demand_data, all.x = T, by = demand_id)
    network_data <- merge(network_data, supply_data, all.x = T, by = supply_id)
    network_data <- network_data[get(cost_col) <= catchment] # Filtering demand and supply within the catchment area threshold.
    # network_data[[cost_col]][network_data[[cost_col]] == 0] <- 0.001 # 0 to 0.001

    ## Drop rows with no demand or supply information
    network_data <- network_data[!is.na(get(supply_col)), ]
    network_data <- network_data[!is.na(get(demand_col)), ]

    # First step for supply Rj
    ## Set weights
    temp <- network_data
    W.values <- gauss_w(temp[[cost_col]], beta = impedance_beta)
    temp$W <- W.values

    supply_result <- temp[, .(w = sum(get(demand_col) * W)), by = supply_id] # Compute W

    supply_data <- merge(supply_data, supply_result, all.x = T, by = supply_id)
    supply_data[, Rj := get(supply_col) / w] # Compute Rj
    supply_data[, w := NULL]
    supply_data[is.infinite(Rj), "Rj"] <- 0

    vars <- c(supply_id, "Rj")
    network_data <- merge(network_data, supply_data[, ..vars], all.x = T, by = supply_id)

    ### Second step for Ai
    temp <- network_data
    W.values <- gauss_w(temp[[cost_col]], beta = impedance_beta)
    temp$W <- W.values

    ai_result <- temp[, .(sumRj = sum(Rj * W)), by = demand_id] # Sum Rj based on demand location

    demand_data <- merge(demand_data, ai_result, all.x = T, by = demand_id)
    demand_data[is.na(demand_data$sumRj), "sumRj"] <- 0
    demand_data[, "Ai" := sumRj]
    demand_data[, sumRj := NULL]

    cat("Procedure finished for", demand_col, "\n")

    return(list(supply_data, demand_data))
}


cat("G2SFCA function is successfully loaded\n")
cat("This code has been updated 9/28/2021. \n")
cat("Before execution of G2SFCA, travel time should be computed in advance.")
