# ==============================================================================
#  DATA LOADING TEMPLATE
# ==============================================================================
#
# This script loads and prepares your  subscription and viewership data
# based on the exact schema you provided
#
# ==============================================================================

library(dplyr)
library(lubridate)
library(readr)

cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║             DATA LOADING - CUSTOM TEMPLATE                  ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n\n")

# ------------------------------------------------------------------------------
# CONFIGURATION
# ------------------------------------------------------------------------------

# Set your file paths here
SUBSCRIPTION_FILE <- "path/to/your/subscription_data.csv"
VIEWERSHIP_FILE <- "path/to/your/viewership_data.csv"  # If available

# ------------------------------------------------------------------------------
# 1. LOAD SUBSCRIPTION DATA
# ------------------------------------------------------------------------------

cat("Loading subscription data...\n")

# Load the CSV file
subscriptions_raw <- read.csv(
  SUBSCRIPTION_FILE,
  stringsAsFactors = FALSE,
  na.strings = c("", "NA", "NULL", "null")
)

cat("Raw data loaded:", nrow(subscriptions_raw), "rows,", 
    ncol(subscriptions_raw), "columns\n\n")

# ------------------------------------------------------------------------------
# 2. DATA TYPE CONVERSIONS
# ------------------------------------------------------------------------------

cat("Converting data types...\n")

subscriptions <- subscriptions_raw %>%
  mutate(
    # ===== INTEGER COLUMNS =====
    Customer_ID = as.integer(Customer_ID),
    Subscription_ID = as.integer(Subscription_ID),
    Subscription_version = as.integer(Subscription_version),
    Subscription_latest = as.integer(Subscription_latest),
    In_gp = as.integer(In_gp),
    daily_weekly_flag = as.integer(daily_weekly_flag),
    promo = as.integer(promo),
    non_commercial = as.integer(non_commercial),
    Budget_key = as.integer(Budget_key),
    In_gp_90 = as.integer(In_gp_90),
    Campaign_ID = as.integer(Campaign_ID),
    
    # ===== NUMERIC COLUMNS =====
    Subscription_key = as.numeric(Subscription_key),
    
    # ===== DATE COLUMNS (from Excel numeric format) =====
    # Excel dates are stored as numbers (days since 1899-12-30)
    Subscription_start_date = as.Date(as.numeric(Subscription_start_date), 
                                      origin = "1899-12-30"),
    Expiry_date = as.Date(as.numeric(Expiry_date), 
                         origin = "1899-12-30"),
    Subscription_calender_date = as.Date(as.numeric(Subscription_calender_date),
                                         origin = "1899-12-30"),
    Cancellation_date = as.Date(as.numeric(Cancellation_date),
                               origin = "1899-12-30"),
    Expiry_date_gp = as.Date(as.numeric(Expiry_date_gp),
                            origin = "1899-12-30"),
    Subscription_calender_date_gp = as.Date(as.numeric(Subscription_calender_date_gp),
                                           origin = "1899-12-30"),
    Expiry_date_gp_90 = as.Date(as.numeric(Expiry_date_gp_90),
                               origin = "1899-12-30"),
    Subscription_calender_date_gp_90 = as.Date(as.numeric(Subscription_calender_date_gp_90),
                                              origin = "1899-12-30"),
    
    # ===== CHARACTER/FACTOR COLUMNS =====
    # These are automatically character, but we ensure consistency
    Customer_External_ID = as.character(Customer_External_ID),
    Country = as.character(Country),
    Dir_indir = as.character(Dir_indir),
    Offer_ID = as.character(Offer_ID),
    Product_name = as.character(Product_name),
    Offer_period = as.character(Offer_period),
    Payment_method = as.character(Payment_method),
    Offer_type = as.character(Offer_type),
    Subscription_status = as.character(Subscription_status),
    Subscription_type = as.character(Subscription_type),
    Winback_type = as.character(Winback_type),
    churn_reason = as.character(churn_reason),
    Subscription_churn_type = as.character(Subscription_churn_type),
    Acquisition_channel = as.character(Acquisition_channel),
    Coupon_code = as.character(Coupon_code),
    Source_system = as.character(Source_system),
    Partner_name = as.character(Partner_name),
    Subscription_status_gp = as.character(Subscription_status_gp),
    Subscription_type_gp = as.character(Subscription_type_gp),
    Tier = as.character(Tier),
    D2C_B2B = as.character(D2C_B2B),
    Subscription_status_gp_90 = as.character(Subscription_status_gp_90),
    Subscription_type_gp_90 = as.character(Subscription_type_gp_90)
  )

cat(" Data types converted\n\n")

# ------------------------------------------------------------------------------
# 3. DATA VALIDATION & QUALITY CHECKS
# ------------------------------------------------------------------------------

cat("Running data quality checks...\n")
cat("─────────────────────────────────────────────────────────────\n")

# Check 1: Required columns exist
required_cols <- c(
  "Customer_ID", "Subscription_ID", "Product_name", "Subscription_status",
  "Subscription_start_date", "Country"
)

missing_cols <- setdiff(required_cols, names(subscriptions))
if (length(missing_cols) > 0) {
  cat("WARNING: Missing required columns:", paste(missing_cols, collapse = ", "), "\n")
} else {
  cat("All required columns present\n")
}

# Check 2: Date validity
invalid_dates <- subscriptions %>%
  filter(
    is.na(Subscription_start_date) |
    is.na(Expiry_date) |
    Subscription_start_date > Expiry_date
  ) %>%
  nrow()

cat("Invalid/missing dates:", invalid_dates, "records\n")

# Check 3: Duplicates
duplicate_keys <- subscriptions %>%
  group_by(Subscription_key) %>%
  filter(n() > 1) %>%
  ungroup() %>%
  nrow()

cat("Duplicate subscription keys:", duplicate_keys, "records\n")

# Check 4: Missing key fields
missing_summary <- subscriptions %>%
  summarise(
    Missing_Customer_ID = sum(is.na(Customer_ID)),
    Missing_Product = sum(is.na(Product_name)),
    Missing_Status = sum(is.na(Subscription_status)),
    Missing_Country = sum(is.na(Country))
  )

cat("\nMissing Key Fields:\n")
print(missing_summary)

# Check 5: Value distributions
cat("\nValue Distributions:\n")
cat("Countries:", n_distinct(subscriptions$Country), "unique\n")
cat("Products:", n_distinct(subscriptions$Product_name), "unique\n")
cat("Subscription Status:", 
    paste(unique(subscriptions$Subscription_status), collapse = ", "), "\n")

cat("\n")

# ------------------------------------------------------------------------------
# 4. CLEAN DATA (OPTIONAL FILTERING)
# ------------------------------------------------------------------------------

cat("Cleaning data...\n")

subscriptions_clean <- subscriptions %>%
  # Remove invalid records (customize as needed)
  filter(
    !is.na(Customer_ID),
    !is.na(Subscription_start_date),
    !is.na(Product_name),
    !is.na(Subscription_status)
  ) %>%
  # Remove future subscriptions (if any)
  filter(Subscription_start_date <= Sys.Date()) %>%
  # Keep only latest version if multiple exist
  group_by(Subscription_ID) %>%
  filter(Subscription_version == max(Subscription_version)) %>%
  ungroup()

removed_records <- nrow(subscriptions) - nrow(subscriptions_clean)
cat(" Removed", removed_records, "invalid records\n")
cat("Clean dataset:", nrow(subscriptions_clean), "records\n\n")

# ------------------------------------------------------------------------------
# 5. LOAD VIEWERSHIP DATA (IF AVAILABLE)
# ------------------------------------------------------------------------------

cat("Loading viewership data...\n")

# EXAMPLE STRUCTURE - Adjust based on your actual viewership schema
# viewership_raw <- read.csv(
#   VIEWERSHIP_FILE,
#   stringsAsFactors = FALSE
# )
# 
# viewership <- viewership_raw %>%
#   mutate(
#     Customer_ID = as.integer(Customer_ID),
#     View_date = as.Date(View_date),
#     Minutes_viewed = as.numeric(Minutes_viewed),
#     Content_type = as.character(Content_type)
#   )
# 
# cat("✓ Viewership data loaded:", nrow(viewership), "records\n\n")

cat("Note: Add viewership loading code when file is available\n\n")

# ------------------------------------------------------------------------------
# 6. DATA SUMMARY
# ------------------------------------------------------------------------------

cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║                    DATA SUMMARY                            ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n\n")

summary_stats <- list(
  total_records = nrow(subscriptions_clean),
  unique_customers = n_distinct(subscriptions_clean$Customer_ID),
  unique_subscriptions = n_distinct(subscriptions_clean$Subscription_ID),
  date_range_start = min(subscriptions_clean$Subscription_start_date, na.rm = TRUE),
  date_range_end = max(subscriptions_clean$Subscription_start_date, na.rm = TRUE),
  active_count = sum(subscriptions_clean$Subscription_status == "active"),
  churned_count = sum(subscriptions_clean$Subscription_status == "churned"),
  churn_rate = mean(subscriptions_clean$Subscription_status == "churned") * 100
)

cat("Total Records:", format(summary_stats$total_records, big.mark = ","), "\n")
cat("Unique Customers:", format(summary_stats$unique_customers, big.mark = ","), "\n")
cat("Unique Subscriptions:", format(summary_stats$unique_subscriptions, big.mark = ","), "\n")
cat("Date Range:", summary_stats$date_range_start, "to", summary_stats$date_range_end, "\n")
cat("Active Subscriptions:", format(summary_stats$active_count, big.mark = ","), "\n")
cat("Churned Subscriptions:", format(summary_stats$churned_count, big.mark = ","), "\n")
cat("Overall Churn Rate:", round(summary_stats$churn_rate, 2), "%\n\n")

# Product breakdown
cat("Product Distribution:\n")
product_summary <- subscriptions_clean %>%
  count(Product_name, Subscription_status) %>%
  pivot_wider(names_from = Subscription_status, values_from = n, values_fill = 0) %>%
  mutate(
    Total = active + churned,
    ChurnRate = round(churned / Total * 100, 1)
  )
print(product_summary)
cat("\n")

# Country breakdown
cat("Country Distribution:\n")
country_summary <- subscriptions_clean %>%
  count(Country, Subscription_status) %>%
  pivot_wider(names_from = Subscription_status, values_from = n, values_fill = 0) %>%
  mutate(
    Total = active + churned,
    ChurnRate = round(churned / Total * 100, 1)
  ) %>%
  arrange(desc(Total))
print(country_summary)
cat("\n")

# ------------------------------------------------------------------------------
# 7. SAVE PROCESSED DATA
# ------------------------------------------------------------------------------

cat("Saving processed data...\n")

# Save as RDS (R native format, preserves data types)
saveRDS(subscriptions_clean, "ML_subscriptions_processed.rds")
cat("Saved: ML_subscriptions_processed.rds\n")

# Save as CSV (for sharing/backup)
write.csv(subscriptions_clean, "ML_subscriptions_processed.csv", row.names = FALSE)
cat("Saved: ML_subscriptions_processed.csv\n\n")

# ------------------------------------------------------------------------------
# 8. EXPORT FOR ANALYSIS
# ------------------------------------------------------------------------------

cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║                  DATA READY FOR ANALYSIS!                  ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n\n")


cat("Next steps:\n")
cat("1. Use 'subscriptions_clean' dataframe for analysis\n")
cat("2. Run: source('ML_churn_analysis_custom.R')\n")
cat("3. Then: source('ML_churn_modeling_custom.R')\n\n")

# Make data available in global environment
assign("subscriptions", subscriptions_clean, envir = .GlobalEnv)

cat("✓ Data loaded into 'subscriptions' variable\n")
cat("✓ Ready to proceed with churn analysis!\n")

# ------------------------------------------------------------------------------
# COLUMN REFERENCE GUIDE
# ------------------------------------------------------------------------------

cat("\n")
cat("═══════════════════════════════════════════════════════════\n")
cat("COLUMN REFERENCE GUIDE\n")
cat("═══════════════════════════════════════════════════════════\n\n")

column_guide <- data.frame(
  Column = names(subscriptions_clean),
  Type = sapply(subscriptions_clean, class),
  row.names = NULL
) %>%
  mutate(
    Category = case_when(
      Column %in% c("Customer_ID", "Customer_External_ID", "Subscription_ID", 
                    "Subscription_key") ~ "Identifiers",
      Column %in% c("Product_name", "Offer_ID", "Offer_type", "Offer_period",
                    "Tier") ~ "Product Info",
      Column %in% c("Country", "Region") ~ "Geographic",
      Column %in% c("Subscription_status", "Subscription_type", "Subscription_churn_type",
                    "churn_reason") ~ "Churn Info",
      Column %in% c("Subscription_start_date", "Expiry_date", "Cancellation_date") ~ "Dates",
      Column %in% c("Dir_indir", "D2C_B2B", "Acquisition_channel", "Source_system",
                    "Partner_name") ~ "Channel",
      Column %in% c("Payment_method", "promo", "Coupon_code", "Campaign_ID") ~ "Payment/Promo",
      Column %in% c("In_gp", "In_gp_90") ~ "Grace Period",
      TRUE ~ "Other"
    )
  )

cat("Total Columns:", nrow(column_guide), "\n\n")

for (category in unique(column_guide$Category)) {
  cat(category, ":\n")
  cols_in_category <- column_guide %>%
    filter(Category == category) %>%
    pull(Column)
  cat("  ", paste(cols_in_category, collapse = ", "), "\n\n")
}

cat("═══════════════════════════════════════════════════════════\n")
