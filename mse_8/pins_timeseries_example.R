# Using the pins package for versioning and sharing time series data
# Compatible with RATS (Regression Analysis of Time Series) workflow
#
# The pins package allows you to publish, version, and share data/models
# This is useful for time series analysis where data is frequently updated
#
# Evens SALIES, 10/2025

# Install pins if not already installed
# install.packages("pins")

library(pins)
library(dplyr)

# ============================================================================
# Example 1: Creating a local board and pinning time series data
# ============================================================================

# Create a local board (directory) to store pins
board <- board_folder(path = "~/pins_data", versioned = TRUE)

# Load the Kiel-McClain incinerator data (same as dd_incinerator.R)
DATA <- read.table("http://www.evens-salies.com/KIELMC.raw", header=FALSE)

# Keep and rename relevant variables
DATA <- DATA[c("V1", "V2", "V3", "V6", "V9", "V10", "V11", "V12", "V13",
               "V17", "V22", "V23", "V24")] 

colnames(DATA)[colnames(DATA)=="V1"] <- "YEAR"
colnames(DATA)[colnames(DATA)=="V2"] <- "AGE"
colnames(DATA)[colnames(DATA)=="V3"] <- "AGE2"
colnames(DATA)[colnames(DATA)=="V17"] <- "Y81"
colnames(DATA)[colnames(DATA)=="V22"] <- "NEARINC"
colnames(DATA)[colnames(DATA)=="V24"] <- "RPRICE"

# Pin the dataset with metadata
board %>% 
  pin_write(
    DATA, 
    name = "kielmc_housing",
    type = "rds",
    title = "Kiel-McClain Housing Data (1978-1981)",
    description = "Panel data on housing prices near incinerator site. 
                   Compatible with time series analysis in RATS or R.",
    metadata = list(
      source = "Kiel and McClain (1995)",
      years = c(1978, 1981),
      variables = c("YEAR", "AGE", "AGE2", "Y81", "NEARINC", "RPRICE"),
      citation = "Kiel, K.A. and McClain, K.T. (1995). The effect of an 
                  incinerator siting on housing appreciation rates. 
                  Journal of Urban Economics, 37, 311-323."
    )
  )

# ============================================================================
# Example 2: Reading a pinned dataset
# ============================================================================

# Read the pinned data (always gets the latest version)
data_latest <- board %>% pin_read("kielmc_housing")

# View metadata
board %>% pin_meta("kielmc_housing")

# View all versions
board %>% pin_versions("kielmc_housing")

# ============================================================================
# Example 3: Creating derived datasets and pinning them
# ============================================================================

# Create a time series summary by year
ts_summary <- data_latest %>%
  group_by(YEAR, NEARINC) %>%
  summarise(
    n = n(),
    mean_price = mean(RPRICE, na.rm = TRUE),
    sd_price = sd(RPRICE, na.rm = TRUE),
    mean_age = mean(AGE, na.rm = TRUE),
    .groups = "drop"
  )

# Pin the summary statistics
board %>% 
  pin_write(
    ts_summary,
    name = "kielmc_summary_stats",
    type = "rds",
    title = "Summary Statistics by Year and Proximity",
    description = "Time series summary of housing prices"
  )

# ============================================================================
# Example 4: Exporting data for use in RATS
# ============================================================================

# RATS typically uses text files with specific formats
# Export the data in a RATS-friendly format (space-delimited)

rats_data <- data_latest %>%
  select(YEAR, RPRICE, NEARINC, AGE, Y81)

# Create a temporary file for RATS export
rats_file <- tempfile(fileext = ".dat")
write.table(rats_data, 
            file = rats_file,
            row.names = FALSE,
            col.names = TRUE,
            sep = " ",
            quote = FALSE)

# Pin the RATS-formatted data
board %>%
  pin_upload(
    paths = rats_file,
    name = "kielmc_rats_format",
    title = "Kiel-McClain Data in RATS Format",
    description = "Space-delimited text file suitable for import into RATS"
  )

# Clean up temporary file
unlink(rats_file)

# ============================================================================
# Example 5: Time series transformations for econometric analysis
# ============================================================================

# Create first differences (common in time series analysis)
ts_analysis <- data_latest %>%
  arrange(YEAR) %>%
  group_by(NEARINC) %>%
  mutate(
    price_diff = RPRICE - lag(RPRICE),
    pct_change = (RPRICE - lag(RPRICE)) / lag(RPRICE) * 100
  ) %>%
  ungroup()

# Pin the transformed data
board %>%
  pin_write(
    ts_analysis,
    name = "kielmc_differenced",
    type = "rds",
    title = "Differenced Housing Prices",
    description = "First differences and percentage changes for time series analysis"
  )

# ============================================================================
# Example 6: Listing all available pins
# ============================================================================

# See all pins on the board
board %>% pin_list()

# Search for specific pins
board %>% pin_search("kielmc")

# ============================================================================
# Example 7: Sharing pins (using different boards)
# ============================================================================

# Note: For collaboration, you can use different board types:
#
# 1. board_folder() - Local filesystem (shown above)
# 2. board_url() - Read-only pins from a URL
# 3. board_connect() - RStudio Connect (for enterprise)
# 4. board_s3() - Amazon S3 bucket
# 5. board_gcs() - Google Cloud Storage
# 6. board_azure() - Azure storage
#
# Example for sharing via URL (read-only):
# board_public <- board_url(c(
#   kielmc = "https://example.com/data/kielmc_housing.rds"
# ))
#
# Example for GitHub-based sharing (using board_folder with git):
# Store pins in a git repository and share via URL

# ============================================================================
# Clean up (optional)
# ============================================================================

# To delete a pin:
# board %>% pin_delete("kielmc_housing")

# ============================================================================
# Summary
# ============================================================================
# 
# Benefits of using pins for RATS-compatible time series analysis:
# 1. Version control for datasets
# 2. Easy sharing across projects and collaborators
# 3. Metadata tracking (source, citation, variables)
# 4. Multiple export formats (R, RATS, CSV, etc.)
# 5. Reproducible research workflow
#
# For RATS users:
# - Export pins to space-delimited .dat or .txt files
# - Use pin metadata to track variable definitions
# - Version datasets as they are updated
# - Share data reproducibly across R and RATS workflows
