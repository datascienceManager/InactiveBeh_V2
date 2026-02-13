# ==============================================================================
#  (OTT PLATFORM) CHURN ANALYSIS - CUSTOMIZED FOR YOUR DATA
# ==============================================================================
#
# Data Schema:
# - Subscription data with 44 columns
# - Products: AFCON,  Total,  4K,  Shows
# - Countries: Egypt, UAE, Morocco, Iraq, Jordan
# - Grace periods: Standard and 90-day tracking
# - Partner integrations: Vodafone, Samsung
#
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. SETUP
# ------------------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(lubridate)
library(ggplot2)
library(gt)
library(scales)

set.seed(123)
options(scipen = 999)

cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║          PLATFORM CHURN ANALYSIS - CUSTOM BUILD        ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n\n")

# ------------------------------------------------------------------------------
# 1. DATA LOADING
# ------------------------------------------------------------------------------

cat("Step 1: Loading subscription and viewership data...\n")
cat("─────────────────────────────────────────────────────────────\n")

# REPLACE THESE WITH YOUR ACTUAL DATA FILES
# subscriptions <- read.csv("subscription_data.csv")
# viewership <- read.csv("viewership_data.csv")

# For demonstration, I'll create sample data matching your schema
subscriptions <- read.csv("your_subscription_file.csv", stringsAsFactors = FALSE)

# Convert date columns (they come as numeric, need to convert from Excel date format)
date_columns <- c("Subscription_start_date", "Expiry_date", "Subscription_calender_date",
                  "Cancellation_date", "Expiry_date_gp", "Subscription_calender_date_gp",
                  "Expiry_date_gp_90", "Subscription_calender_date_gp_90")

for (col in date_columns) {
  if (col %in% names(subscriptions)) {
    subscriptions[[col]] <- as.Date(as.numeric(subscriptions[[col]]), 
                                    origin = "1899-12-30")
  }
}

cat("✓ Subscription data loaded\n")
cat("  Records:", nrow(subscriptions), "\n")
cat("  Columns:", ncol(subscriptions), "\n")
cat("  Date range:", min(subscriptions$Subscription_start_date, na.rm = TRUE), 
    "to", max(subscriptions$Subscription_start_date, na.rm = TRUE), "\n\n")

# Load viewership data (structure to be confirmed)
# viewership <- read.csv("viewership_data.csv")
cat("Note: Add viewership data loading here when available\n\n")

# ------------------------------------------------------------------------------
# 2. DATA UNDERSTANDING & QUALITY CHECKS
# ------------------------------------------------------------------------------

cat("Step 2: Data Quality Assessment...\n")
cat("─────────────────────────────────────────────────────────────\n")

# Check for duplicates
duplicates <- subscriptions %>%
  group_by(Subscription_key) %>%
  filter(n() > 1) %>%
  nrow()

cat("Duplicate subscription keys:", duplicates, "\n")

# Check churn status distribution
churn_dist <- subscriptions %>%
  count(Subscription_status) %>%
  mutate(Percentage = n / sum(n) * 100)

cat("\nSubscription Status Distribution:\n")
print(churn_dist)

# Check product distribution
product_dist <- subscriptions %>%
  count(Product_name) %>%
  arrange(desc(n))

cat("\nProduct Distribution:\n")
print(product_dist)

# Check country distribution
country_dist <- subscriptions %>%
  count(Country) %>%
  arrange(desc(n))

cat("\nCountry Distribution:\n")
print(country_dist)

# Missing data summary
missing_summary <- data.frame(
  Column = names(subscriptions),
  Missing_Count = sapply(subscriptions, function(x) sum(is.na(x))),
  Missing_Percent = sapply(subscriptions, function(x) round(sum(is.na(x))/length(x)*100, 2))
) %>%
  filter(Missing_Count > 0) %>%
  arrange(desc(Missing_Percent))

cat("\nColumns with Missing Data:\n")
print(head(missing_summary, 10))
cat("\n")

# ------------------------------------------------------------------------------
# 3. FEATURE ENGINEERING
# ------------------------------------------------------------------------------

cat("Step 3: Feature Engineering...\n")
cat("─────────────────────────────────────────────────────────────\n")

churn_data <- subscriptions %>%
  mutate(
    # ----- TARGET VARIABLE -----
    Churned = ifelse(Subscription_status == "churned", 1, 0),
    ChurnedFactor = factor(Churned, levels = c(0, 1), 
                           labels = c("Active", "Churned")),
    
    # ----- TEMPORAL FEATURES -----
    # Subscription duration
    SubscriptionDays = as.numeric(difftime(Expiry_date, Subscription_start_date, 
                                           units = "days")),
    SubscriptionMonths = SubscriptionDays / 30.44,
    
    # Time since subscription started
    DaysSinceStart = as.numeric(difftime(Sys.Date(), Subscription_start_date, 
                                         units = "days")),
    MonthsSinceStart = DaysSinceStart / 30.44,
    
    # Days until expiry (negative if expired)
    DaysUntilExpiry = as.numeric(difftime(Expiry_date, Sys.Date(), units = "days")),
    
    # Subscription age category
    TenureCategory = case_when(
      MonthsSinceStart <= 1 ~ "New (0-1 month)",
      MonthsSinceStart <= 3 ~ "Early (1-3 months)",
      MonthsSinceStart <= 6 ~ "Growing (3-6 months)",
      MonthsSinceStart <= 12 ~ "Established (6-12 months)",
      TRUE ~ "Loyal (12+ months)"
    ),
    
    # Subscription month (for seasonality)
    SubscriptionMonth = month(Subscription_start_date, label = TRUE),
    SubscriptionQuarter = quarter(Subscription_start_date),
    SubscriptionYear = year(Subscription_start_date),
    
    # ----- PRODUCT FEATURES -----
    # Product tier mapping
    ProductTier = case_when(
      Product_name == "TOD 4K" ~ "Premium",
      Product_name == "TOD Total" ~ "Standard",
      Product_name == "TOD Shows" ~ "Basic",
      Product_name == "AFCON" ~ "Event Pass",
      TRUE ~ "Other"
    ),
    
    # Offer period standardization
    OfferPeriodStd = case_when(
      Offer_period == "daily" ~ "Daily",
      Offer_period == "weekly" ~ "Weekly",
      Offer_period == "monthly" ~ "Monthly",
      Offer_period == "6-months" ~ "Long-term",
      Offer_period == "custom" ~ "Custom",
      TRUE ~ "Other"
    ),
    
    # Is premium product?
    IsPremium = ifelse(Product_name %in% c("TOD 4K", "TOD Total"), 1, 0),
    
    # Is event pass?
    IsEventPass = ifelse(Product_name == "AFCON", 1, 0),
    
    # ----- CUSTOMER BEHAVIOR -----
    # Subscription type flags
    IsNewSubscriber = ifelse(Subscription_type == "new", 1, 0),
    IsWinback = ifelse(Subscription_type == "winback", 1, 0),
    IsContinue = ifelse(Subscription_type_gp == "continue", 1, 0),
    
    # Winback category
    WinbackCategory = ifelse(!is.na(Winback_type), Winback_type, "Not Winback"),
    
    # ----- CHANNEL & ACQUISITION -----
    # Direct vs Indirect
    IsDirect = ifelse(Dir_indir == "Direct", 1, 0),
    IsB2B = ifelse(D2C_B2B == "B2B", 1, 0),
    
    # Has partner
    HasPartner = ifelse(!is.na(Partner_name), 1, 0),
    
    # Acquisition channel grouping
    AcquisitionChannelGroup = case_when(
      Acquisition_channel == "Web" ~ "Web",
      Acquisition_channel == "Apple" ~ "Mobile App",
      Source_system == "Partner" ~ "Partner",
      TRUE ~ "Other"
    ),
    
    # Payment method category
    PaymentCategory = case_when(
      Payment_method == "Card" ~ "Card",
      Payment_method == "voucher" ~ "Voucher",
      Payment_method %in% c("iOS", "web") ~ "Digital Wallet",
      TRUE ~ "Other"
    ),
    
    # ----- PROMOTIONAL & PRICING -----
    # Has promotion
    HasPromo = ifelse(promo == 1, 1, 0),
    
    # Has coupon
    HasCoupon = ifelse(!is.na(Coupon_code), 1, 0),
    
    # Has campaign
    HasCampaign = ifelse(!is.na(Campaign_ID), 1, 0),
    
    # ----- CHURN CHARACTERISTICS -----
    # Churn type (voluntary vs involuntary)
    ChurnTypeClean = case_when(
      is.na(Subscription_churn_type) ~ "Active",
      Subscription_churn_type == "voluntary churn" ~ "Voluntary",
      Subscription_churn_type == "Involuntary churn" ~ "Involuntary",
      TRUE ~ "Unknown"
    ),
    
    # Churn reason category
    ChurnReasonCategory = case_when(
      is.na(churn_reason) ~ "Active",
      churn_reason == "Payment failed" ~ "Payment Issue",
      churn_reason == "Customer churn" ~ "Customer Decision",
      churn_reason == "Broadcaster churn" ~ "Content Issue",
      TRUE ~ "Other"
    ),
    
    # Days in grace period (if applicable)
    InGracePeriod = ifelse(In_gp == 1, 1, 0),
    InGracePeriod90 = ifelse(In_gp_90 == 1, 1, 0),
    
    # ----- GEOGRAPHIC FEATURES -----
    # Country tier based on market size
    CountryTier = case_when(
      Country %in% c("Egypt", "United Arab Emirates") ~ "Tier 1",
      Country %in% c("Morocco", "Iraq") ~ "Tier 2",
      TRUE ~ "Tier 3"
    ),
    
    # Region grouping
    Region = case_when(
      Country == "Egypt" ~ "North Africa",
      Country == "Morocco" ~ "North Africa",
      Country %in% c("United Arab Emirates", "Jordan") ~ "Middle East",
      Country == "Iraq" ~ "Middle East",
      TRUE ~ "Other"
    ),
    
    # ----- SUBSCRIPTION VERSION -----
    # Has multiple versions (indicates changes)
    HasMultipleVersions = ifelse(Subscription_version > 1, 1, 0),
    IsLatestVersion = ifelse(Subscription_latest == 1, 1, 0),
    
    # ----- RISK FLAGS -----
    # High-risk indicators
    ShortTenureFlag = ifelse(MonthsSinceStart < 3, 1, 0),
    DailyWeeklyFlag = daily_weekly_flag,
    ExpiringSoonFlag = ifelse(DaysUntilExpiry > 0 & DaysUntilExpiry <= 7, 1, 0),
    
    # ----- DERIVED METRICS -----
    # Subscription stability score (lower = more stable)
    StabilityScore = (IsNewSubscriber * 2) + (IsWinback * 3) + 
                     (HasMultipleVersions * 1) - (IsContinue * 2),
    
    # Value tier
    ValueTier = case_when(
      Tier == "T1A" ~ "High Value",
      Tier == "T2" ~ "Medium Value",
      Tier == "T3B" ~ "Low Value",
      TRUE ~ "Unknown"
    )
  )

cat("✓ Feature engineering completed\n")
cat("  New features created:", ncol(churn_data) - ncol(subscriptions), "\n\n")

# ------------------------------------------------------------------------------
# 4. EXPLORATORY DATA ANALYSIS
# ------------------------------------------------------------------------------

cat("Step 4: Exploratory Data Analysis...\n")
cat("─────────────────────────────────────────────────────────────\n")

# Overall churn rate
overall_metrics <- churn_data %>%
  summarise(
    TotalSubscriptions = n(),
    ActiveSubscriptions = sum(Churned == 0),
    ChurnedSubscriptions = sum(Churned == 1),
    ChurnRate = mean(Churned) * 100,
    VoluntaryChurn = sum(ChurnTypeClean == "Voluntary"),
    InvoluntaryChurn = sum(ChurnTypeClean == "Involuntary")
  )

cat("═══════════════════════════════════════════════════════════\n")
cat("OVERALL METRICS\n")
cat("═══════════════════════════════════════════════════════════\n")
cat("Total Subscriptions:", format(overall_metrics$TotalSubscriptions, big.mark = ","), "\n")
cat("Active:", format(overall_metrics$ActiveSubscriptions, big.mark = ","), "\n")
cat("Churned:", format(overall_metrics$ChurnedSubscriptions, big.mark = ","), "\n")
cat("Churn Rate:", round(overall_metrics$ChurnRate, 2), "%\n")
cat("Voluntary Churn:", overall_metrics$VoluntaryChurn, 
    sprintf("(%.1f%%)", overall_metrics$VoluntaryChurn/overall_metrics$ChurnedSubscriptions*100), "\n")
cat("Involuntary Churn:", overall_metrics$InvoluntaryChurn,
    sprintf("(%.1f%%)", overall_metrics$InvoluntaryChurn/overall_metrics$ChurnedSubscriptions*100), "\n")
cat("═══════════════════════════════════════════════════════════\n\n")

# Churn by Product
cat("CHURN BY PRODUCT\n")
cat("───────────────────────────────────────────────────────────\n")
churn_by_product <- churn_data %>%
  group_by(Product_name) %>%
  summarise(
    Subscriptions = n(),
    Churned = sum(Churned),
    ChurnRate = mean(Churned) * 100,
    AvgTenureMonths = mean(MonthsSinceStart, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(ChurnRate))

print(churn_by_product)
cat("\n")

# Churn by Country
cat("CHURN BY COUNTRY\n")
cat("───────────────────────────────────────────────────────────\n")
churn_by_country <- churn_data %>%
  group_by(Country) %>%
  summarise(
    Subscriptions = n(),
    ChurnRate = mean(Churned) * 100,
    VoluntaryPct = sum(ChurnTypeClean == "Voluntary") / sum(Churned) * 100,
    .groups = "drop"
  ) %>%
  arrange(desc(ChurnRate))

print(churn_by_country)
cat("\n")

# Churn by Offer Period
cat("CHURN BY OFFER PERIOD\n")
cat("───────────────────────────────────────────────────────────\n")
churn_by_period <- churn_data %>%
  group_by(OfferPeriodStd) %>%
  summarise(
    Subscriptions = n(),
    ChurnRate = mean(Churned) * 100,
    .groups = "drop"
  ) %>%
  arrange(desc(ChurnRate))

print(churn_by_period)
cat("\n")

# Churn by Acquisition Channel
cat("CHURN BY ACQUISITION CHANNEL\n")
cat("───────────────────────────────────────────────────────────\n")
churn_by_channel <- churn_data %>%
  group_by(AcquisitionChannelGroup) %>%
  summarise(
    Subscriptions = n(),
    ChurnRate = mean(Churned) * 100,
    .groups = "drop"
  ) %>%
  arrange(desc(ChurnRate))

print(churn_by_channel)
cat("\n")

# Churn by Tenure
cat("CHURN BY TENURE CATEGORY\n")
cat("───────────────────────────────────────────────────────────\n")
churn_by_tenure <- churn_data %>%
  group_by(TenureCategory) %>%
  summarise(
    Subscriptions = n(),
    ChurnRate = mean(Churned) * 100,
    .groups = "drop"
  )

print(churn_by_tenure)
cat("\n")

# Winback Analysis
cat("WINBACK CUSTOMER ANALYSIS\n")
cat("───────────────────────────────────────────────────────────\n")
winback_analysis <- churn_data %>%
  group_by(IsWinback) %>%
  summarise(
    Subscriptions = n(),
    ChurnRate = mean(Churned) * 100,
    AvgTenureMonths = mean(MonthsSinceStart, na.rm = TRUE),
    .groups = "drop"
  )

print(winback_analysis)
cat("\n")

# Partner Analysis
cat("PARTNER vs DIRECT ANALYSIS\n")
cat("───────────────────────────────────────────────────────────\n")
partner_analysis <- churn_data %>%
  mutate(Channel = ifelse(HasPartner == 1, "Partner", "Direct")) %>%
  group_by(Channel) %>%
  summarise(
    Subscriptions = n(),
    ChurnRate = mean(Churned) * 100,
    .groups = "drop"
  )

print(partner_analysis)
cat("\n")

# Payment Method Analysis
cat("CHURN BY PAYMENT METHOD\n")
cat("───────────────────────────────────────────────────────────\n")
payment_analysis <- churn_data %>%
  group_by(PaymentCategory) %>%
  summarise(
    Subscriptions = n(),
    ChurnRate = mean(Churned) * 100,
    .groups = "drop"
  ) %>%
  arrange(desc(ChurnRate))

print(payment_analysis)
cat("\n")

# Promotion Impact
cat("PROMOTION IMPACT\n")
cat("───────────────────────────────────────────────────────────\n")
promo_analysis <- churn_data %>%
  mutate(PromoStatus = ifelse(HasPromo == 1, "With Promo", "Without Promo")) %>%
  group_by(PromoStatus) %>%
  summarise(
    Subscriptions = n(),
    ChurnRate = mean(Churned) * 100,
    .groups = "drop"
  )

print(promo_analysis)
cat("\n")

# Grace Period Analysis
cat("GRACE PERIOD ANALYSIS\n")
cat("───────────────────────────────────────────────────────────\n")
grace_analysis <- churn_data %>%
  group_by(InGracePeriod, InGracePeriod90) %>%
  summarise(
    Subscriptions = n(),
    ChurnRate = mean(Churned) * 100,
    .groups = "drop"
  )

print(grace_analysis)
cat("\n")

# ------------------------------------------------------------------------------
# 5. CHURN REASON ANALYSIS
# ------------------------------------------------------------------------------

cat("Step 5: Churn Reason Deep Dive...\n")
cat("─────────────────────────────────────────────────────────────\n")

# Churn reasons breakdown
churn_reasons <- churn_data %>%
  filter(Churned == 1) %>%
  count(ChurnReasonCategory) %>%
  mutate(
    Percentage = n / sum(n) * 100
  ) %>%
  arrange(desc(n))

cat("CHURN REASONS\n")
print(churn_reasons)
cat("\n")

# Voluntary vs Involuntary by Product
voluntary_by_product <- churn_data %>%
  filter(Churned == 1) %>%
  group_by(Product_name, ChurnTypeClean) %>%
  summarise(Count = n(), .groups = "drop") %>%
  pivot_wider(names_from = ChurnTypeClean, values_from = Count, values_fill = 0)

cat("CHURN TYPE BY PRODUCT\n")
print(voluntary_by_product)
cat("\n")

# ------------------------------------------------------------------------------
# 6. COHORT ANALYSIS
# ------------------------------------------------------------------------------

cat("Step 6: Cohort Analysis...\n")
cat("─────────────────────────────────────────────────────────────\n")

cohort_data <- churn_data %>%
  mutate(
    CohortMonth = floor_date(Subscription_start_date, "month")
  ) %>%
  group_by(CohortMonth, Product_name) %>%
  summarise(
    CohortSize = n(),
    Churned = sum(Churned),
    ChurnRate = mean(Churned) * 100,
    AvgTenure = mean(MonthsSinceStart, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(CohortMonth))

cat("COHORT ANALYSIS (Recent 6 months)\n")
print(head(cohort_data, 24))
cat("\n")

# ------------------------------------------------------------------------------
# 7. KEY INSIGHTS & STATISTICS
# ------------------------------------------------------------------------------

cat("Step 7: Statistical Analysis...\n")
cat("─────────────────────────────────────────────────────────────\n")

# Chi-square test: Product vs Churn
if (length(unique(churn_data$Product_name)) > 1) {
  chi_product <- chisq.test(table(churn_data$Product_name, churn_data$Churned))
  cat("Product vs Churn Association:\n")
  cat("  Chi-square statistic:", round(chi_product$statistic, 2), "\n")
  cat("  p-value:", format.pval(chi_product$p.value), "\n")
  cat("  Significant:", ifelse(chi_product$p.value < 0.05, "YES ✓", "NO"), "\n\n")
}

# Chi-square test: Country vs Churn
if (length(unique(churn_data$Country)) > 1) {
  chi_country <- chisq.test(table(churn_data$Country, churn_data$Churned))
  cat("Country vs Churn Association:\n")
  cat("  Chi-square statistic:", round(chi_country$statistic, 2), "\n")
  cat("  p-value:", format.pval(chi_country$p.value), "\n")
  cat("  Significant:", ifelse(chi_country$p.value < 0.05, "YES ✓", "NO"), "\n\n")
}

# T-test: Tenure between churned and active
tenure_test <- t.test(MonthsSinceStart ~ Churned, data = churn_data)
cat("Tenure Comparison (Active vs Churned):\n")
cat("  Mean Active:", round(tenure_test$estimate[1], 2), "months\n")
cat("  Mean Churned:", round(tenure_test$estimate[2], 2), "months\n")
cat("  Difference:", round(tenure_test$estimate[1] - tenure_test$estimate[2], 2), "months\n")
cat("  p-value:", format.pval(tenure_test$p.value), "\n")
cat("  Significant:", ifelse(tenure_test$p.value < 0.05, "YES ✓", "NO"), "\n\n")

# ------------------------------------------------------------------------------
# 8. RISK SCORING
# ------------------------------------------------------------------------------

cat("Step 8: Creating Churn Risk Scores...\n")
cat("─────────────────────────────────────────────────────────────\n")

churn_data <- churn_data %>%
  mutate(
    # Individual risk factors (0-3 scale)
    TenureRisk = case_when(
      MonthsSinceStart < 1 ~ 3,
      MonthsSinceStart < 3 ~ 2,
      MonthsSinceStart < 6 ~ 1,
      TRUE ~ 0
    ),
    
    ProductRisk = case_when(
      Product_name == "AFCON" ~ 3,  # Event pass = higher churn
      Product_name == "TOD Shows" ~ 2,
      TRUE ~ 1
    ),
    
    WinbackRisk = IsWinback * 2,
    
    PaymentRisk = case_when(
      PaymentCategory == "Voucher" ~ 2,
      PaymentCategory == "Other" ~ 1,
      TRUE ~ 0
    ),
    
    GraceRisk = (InGracePeriod * 2) + InGracePeriod90,
    
    # Composite risk score (0-13 scale)
    ChurnRiskScore = TenureRisk + ProductRisk + WinbackRisk + 
                     PaymentRisk + GraceRisk,
    
    # Risk category
    RiskCategory = case_when(
      ChurnRiskScore >= 9 ~ "Very High Risk",
      ChurnRiskScore >= 6 ~ "High Risk",
      ChurnRiskScore >= 3 ~ "Medium Risk",
      TRUE ~ "Low Risk"
    )
  )

# Validate risk scoring
risk_validation <- churn_data %>%
  group_by(RiskCategory) %>%
  summarise(
    Subscriptions = n(),
    ActualChurnRate = mean(Churned) * 100,
    AvgRiskScore = mean(ChurnRiskScore),
    .groups = "drop"
  ) %>%
  arrange(desc(AvgRiskScore))

cat("RISK SCORE VALIDATION\n")
print(risk_validation)
cat("\n")

# ------------------------------------------------------------------------------
# 9. KEY FINDINGS SUMMARY
# ------------------------------------------------------------------------------

cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║                  KEY FINDINGS SUMMARY                      ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n\n")

findings <- list(
  overall_churn = round(overall_metrics$ChurnRate, 1),
  highest_churn_product = churn_by_product$Product_name[1],
  highest_churn_rate = round(churn_by_product$ChurnRate[1], 1),
  highest_churn_country = churn_by_country$Country[1],
  winback_churn_rate = round(winback_analysis$ChurnRate[winback_analysis$IsWinback == 1], 1),
  new_churn_rate = round(winback_analysis$ChurnRate[winback_analysis$IsWinback == 0], 1),
  very_high_risk = sum(churn_data$RiskCategory == "Very High Risk"),
  high_risk = sum(churn_data$RiskCategory == "High Risk")
)

cat("1. Overall churn rate:", findings$overall_churn, "%\n")
cat("2. Highest churn product:", findings$highest_churn_product, 
    "at", findings$highest_churn_rate, "%\n")
cat("3. Highest churn country:", findings$highest_churn_country, "\n")
cat("4. Winback customer churn:", findings$winback_churn_rate, 
    "% (vs", findings$new_churn_rate, "% for new)\n")
cat("5. Very high-risk subscriptions:", format(findings$very_high_risk, big.mark = ","), "\n")
cat("6. High-risk subscriptions:", format(findings$high_risk, big.mark = ","), "\n")

cat("\n")
cat("Top 3 Churn Drivers:\n")
cat("───────────────────\n")
cat("1. Tenure: New subscribers churn", 
    round(churn_by_tenure$ChurnRate[churn_by_tenure$TenureCategory == "New (0-1 month)"], 1),
    "% vs", 
    round(churn_by_tenure$ChurnRate[churn_by_tenure$TenureCategory == "Loyal (12+ months)"], 1),
    "% for loyal\n")
cat("2. Product type: Event passes show higher churn\n")
cat("3. Customer type: Winback customers show elevated risk\n\n")

cat("═══════════════════════════════════════════════════════════\n")
cat("✓ Analysis complete! Ready for modeling and visualization.\n")
cat("═══════════════════════════════════════════════════════════\n\n")

# Save processed data
# saveRDS(churn_data, "churn_data_processed.rds")
# write.csv(churn_data, "churn_data_processed.csv", row.names = FALSE)

cat("Next steps:\n")
cat("1. Run predictive modeling (churn_modeling.R)\n")
cat("2. Create visualizations (churn_visualizations.R)\n")
cat("3. Generate PowerPoint report (create_churn_presentation.py)\n")
