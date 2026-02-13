#  Platform Churn Analysis - Complete Solution

**Customized churn analysis framework for your  OTT subscription data**

## 📊 Your Data Structure

### Subscription Data (44 columns)

**Products**:
-  4K (Premium)
-  Total (Standard)
-  Shows (Basic)
- AFCON (Event Pass)

**Markets**:
- Egypt, UAE, Morocco, Iraq, Jordan

**Key Features**:
- Grace period tracking (standard + 90-day)
- Partner integrations (Vodafone, Samsung)
- Multiple subscription versions
- D2C and B2B channels
- Voluntary vs Involuntary churn tracking

## 🚀 Quick Start Guide

### Step 1: Prepare Your Data

```r
# Place your CSV file in the project directory
# Update the file path in ML_data_loading.R

SUBSCRIPTION_FILE <- "your_subscription_data.csv"
```

### Step 2: Run Complete Analysis

```r
# 1. Load and validate data
source("ML_data_loading.R")

# 2. Perform churn analysis
source("ML_churn_analysis_custom.R")

# 3. Build predictive models
source("ML_churn_modeling_custom.R")

# 4. Create visualizations (optional)
source("churn_visualizations.R")
source("advanced_churn_visualizations.R")
```

### Step 3: Generate PowerPoint Report

```bash
python create_churn_presentation.py
```

## 📁 Project Files

### Core Scripts (Custom Built for Your Data)

| File | Purpose | Key Outputs |
|------|---------|-------------|
| `ML_data_loading.R` | Load & validate subscription data | Clean dataset with proper data types |
| `ML_churn_analysis_custom.R` | EDA & feature engineering | Insights, cohorts, risk scores |
| `ML_churn_modeling_custom.R` | Predictive models | Model, predictions, risk segments |

### Visualization Scripts

| File | Charts Created |
|------|----------------|
| `churn_visualizations.R` | 15 standard business charts |
| `advanced_churn_visualizations.R` | 15 advanced ggplot2 visualizations |

### Reporting

| File | Purpose |
|------|---------|
| `create_churn_presentation.py` | Generate PowerPoint with all findings |

## 🎯 What You'll Get

### Analysis Outputs

1. **Data Quality Report**
   - Missing value analysis
   - Date validation
   - Duplicate detection
   - Distribution summaries

2. **Churn Insights**
   - Overall churn rate: X%
   - Churn by product (AFC vs ML 4K vs ML Shows vs ML Total)
   - Churn by country (Egypt, UAE, Morocco, Iraq, Jordan)
   - Churn by offer period (daily, monthly, 6-months, custom)
   - Voluntary vs Involuntary breakdown
   - Winback customer performance
   - Partner vs Direct comparison
   - Payment method impact
   - Promotion effectiveness

3. **Cohort Analysis**
   - Monthly cohorts by product
   - Retention curves over time
   - Seasonal patterns

4. **Risk Scoring**
   - 4-tier risk classification (Very High, High, Medium, Low)
   - Personalized risk scores per subscription
   - Risk validation against actual churn

### Predictive Models

**Model 1: Logistic Regression**
- Interpretable baseline
- Feature coefficients and significance
- Expected accuracy: 70-75%

**Model 2: Random Forest**
- High-performance production model
- Feature importance rankings
- Expected accuracy: 80-85%

### Business Outputs

**Files Created**:
- `ML_churn_predictions.csv` - Risk scores for all subscriptions
- `ML_feature_importance.csv` - Top churn drivers
- `ML_model_comparison.csv` - Model performance metrics
- `ML_rf_churn_model.rds` - Trained model for deployment
- `churn_visuals/` - 15+ standard charts (PNG, 300 DPI)
- `advanced_visuals/` - 15+ advanced charts (PNG, 300 DPI)
- `churn_tables/` - 5 summary tables (PNG, 300 DPI)
- `Churn_Analysis_Report.pptx` - Complete presentation

## 🔍 Key Features Analyzed

### From Your Schema

**Subscription Attributes**:
- Product tier (4K, Total, Shows, AFCON)
- Offer period (daily, monthly, 6-months, custom)
- Offer type (Pass vs Subscription)
- Payment method (voucher, Card, web, iOS)
- Subscription version & latest flag

**Customer Behavior**:
- New vs Continue vs Winback
- Winback type (mid winback)
- Subscription type by grace period
- Grace period status (standard & 90-day)

**Channels**:
- Direct vs Indirect (Dir_indir)
- D2C vs B2B (D2C_B2B)
- Acquisition channel (Web, Apple)
- Source system (Partner, Web, iOS)
- Partner name (Vodafone, Samsung)

**Temporal**:
- Subscription start date
- Expiry date
- Cancellation date
- Subscription calendar dates (standard & 90-day GP)

**Promotions**:
- Promo flag
- Coupon code
- Campaign ID
- Budget key

**Value Tiers**:
- Tier (T1A, T2, T3B)
- Commercial vs Non-commercial
- Daily/weekly flag

## 📊 Custom Analyses for ML

### 1. Product-Specific Insights

**AFCON Pass Analysis**:
- Event-based subscription churn patterns
- Post-event retention rates
- Conversion to ongoing subscriptions

**ML 4K Analysis**:
- Premium customer behavior
- Price sensitivity
- Feature utilization

**ML Shows vs ML Total**:
- Content consumption differences
- Upgrade/downgrade patterns

### 2. Geographic Analysis

**Country-Level**:
- Egypt market dynamics
- UAE premium segment
- Morocco growth patterns
- Iraq market challenges
- Jordan opportunity sizing

**Regional Grouping**:
- North Africa (Egypt, Morocco)
- Middle East (UAE, Iraq, Jordan)

### 3. Partner Channel Analysis

**Partner Performance**:
- Vodafone subscriber quality
- Samsung device integration impact
- Partner vs Direct churn comparison

**Channel Mix**:
- Web vs Mobile app
- iOS vs Web payment
- Direct vs Indirect acquisition

### 4. Grace Period Effectiveness

**Standard GP Analysis**:
- Subscribers in grace period
- Recovery rates
- Payment retry success

**90-Day GP Analysis**:
- Extended grace impact
- Long-term retention
- Revenue recovery

### 5. Winback Campaign Performance

**Winback Types**:
- Mid winback effectiveness
- Time-to-winback analysis
- Winback vs new subscriber LTV

## 🎨 Visualizations Created

### Standard Business Charts (15)

1. Overall churn rate (pie)
2. Churn by product (bar)
3. Churn by tenure (bar)
4. Engagement distribution (histogram)
5. Churn type breakdown (pie)
6. Churn by channel (bar)
7. Cohort retention curves (line)
8. RFM segmentation (bar)
9. Content preferences (grouped bar)
10. Risk score distribution (histogram)
11. ROC curves (line)
12. Feature importance (horizontal bar)
13. Calibration plot (scatter)
14. Risk validation (bar)
15. Business metrics dashboard (multi-panel)

### Advanced Visualizations (15)

1. **Bump charts** - Product ranking changes over time
2. **Ridge plots** - Engagement distributions by segment
3. **Alluvial diagrams** - Customer journey flows
4. **Heatmaps** - Feature correlations
5. **Treemaps** - Revenue at risk by segment
6. **Waterfall charts** - Churn contribution analysis
7. **Survival curves** - Time-to-churn by product
8. **Violin plots** - Distribution comparisons
9. **Lollipop charts** - Clean feature rankings
10. **Dumbbell plots** - Before/after comparisons
11. **Stream graphs** - Churn evolution over time
12. **Faceted plots** - Cohort comparisons
13. **2D density plots** - Customer clustering
14. **Slope charts** - Month-over-month changes
15. **Combined dashboards** - Executive summaries

## 📈 Expected Results

### Model Performance

| Metric | Logistic Regression | Random Forest |
|--------|---------------------|---------------|
| Accuracy | 70-75% | 80-85% |
| Precision | 65-75% | 75-85% |
| Recall | 60-70% | 70-80% |
| AUC | 0.75-0.82 | 0.83-0.90 |

### Business Impact

**Baseline Scenario**:
- Current churn rate: ~25-30% (industry average)
- Identified high-risk customers: 15-20% of base
- Potential churn reduction: 15-20% through interventions

**ROI Calculation**:
```
High-risk customers: 10,000
Intervention success rate: 20%
Customers saved: 2,000
Avg customer LTV: $150
Revenue saved: $300,000
Intervention cost: $50,000
Net benefit: $250,000
ROI: 5x
```

## 🔧 Customization Guide

### Adjusting Risk Scores

Edit `ML_churn_analysis_custom.R`:

```r
# Modify risk factor weights
ChurnRiskScore = (TenureRisk * 1.5) +     # Increase tenure impact
                 (ProductRisk * 2.0) +     # Product matters more
                 (WinbackRisk * 1.0) +     # Reduce winback penalty
                 (PaymentRisk * 1.5) +
                 (GraceRisk * 2.5)         # Grace period critical
```

### Adding Custom Features

```r
# Add in feature engineering section
churn_data <- churn_data %>%
  mutate(
    # Your custom feature
    IsPremiumMarket = ifelse(Country %in% c("UAE", "Egypt"), 1, 0),
    
    # Interaction features
    PremiumProductInTier1 = IsPremium * (CountryTier == "Tier 1"),
    
    # Time-based
    DaysSinceLastPayment = ...,
    
    # Add more as needed
  )
```

### Filtering Data

Edit `ML_data_loading.R`:

```r
subscriptions_clean <- subscriptions %>%
  filter(
    # Remove test accounts
    !grepl("test|demo", Customer_External_ID, ignore.case = TRUE),
    
    # Focus on specific products
    Product_name %in% c("ML 4K", "ML Total"),
    
    # Specific time period
    Subscription_start_date >= "2024-01-01",
    
    # Active countries only
    Country %in% c("Egypt", "UAE", "Morocco")
  )
```

## 🎯 Business Recommendations

### Immediate Actions (Week 1-2)

1. **Score All Active Subscriptions**
   ```r
   # Run predictions on current active base
   active_subs <- subscriptions %>% filter(Subscription_status == "active")
   predictions <- predict(rf_model, active_subs, type = "prob")
   ```

2. **Target Very High-Risk Segment**
   - AFCON pass holders nearing expiry
   - First-month subscribers
   - Grace period customers
   - Previous winbacks

3. **Geographic Priority**
   - Focus on highest churn country first
   - Localize retention messaging
   - Country-specific offers

### Product Improvements (Month 1)

1. **AFCON Pass Strategy**
   - Auto-upgrade to ML Total post-event
   - Bundle with ongoing subscription
   - Loyalty rewards for renewals

2. **Premium Tier Enhancement**
   - Exclusive 4K content library
   - Early access to new releases
   - Premium customer support

3. **Content Recommendations**
   - Personalized based on viewing history
   - Improve discovery for Shows tier
   - Cross-sell to appropriate tier

### Channel Optimization (Month 2-3)

1. **Partner Channel**
   - Vodafone integration improvements
   - Samsung TV app enhancements
   - Partner-exclusive content

2. **Payment Methods**
   - Reduce payment failures
   - Multiple retry attempts
   - Alternative payment options
   - Voucher code simplification

3. **Acquisition Quality**
   - Review Web vs Mobile performance
   - Optimize onboarding flow
   - Source system attribution

### Monitoring & Iteration (Ongoing)

1. **Weekly**
   - Score all active subscriptions
   - Flag new high-risk customers
   - Monitor intervention success

2. **Monthly**
   - Retrain model with new data
   - Update risk thresholds
   - Review cohort performance
   - A/B test retention campaigns

3. **Quarterly**
   - Full model audit
   - Feature importance changes
   - Market-specific strategies
   - ROI assessment

## 📞 Implementation Support

### Common Issues & Solutions

**Issue**: Dates not loading correctly
```r
# Solution: Adjust Excel date origin
Subscription_start_date = as.Date(as.numeric(Subscription_start_date), 
                                  origin = "1899-12-30")
```

**Issue**: Too many missing values
```r
# Solution: Impute or create flags
churn_data <- churn_data %>%
  mutate(
    Partner_name = replace_na(Partner_name, "No Partner"),
    HasPartner = ifelse(is.na(Partner_name), 0, 1)
  )
```

**Issue**: Imbalanced classes
```r
# Solution: Use SMOTE or adjust class weights
library(ROSE)
balanced_data <- ROSE(Churned ~ ., data = train_data)$data
```

**Issue**: Model overfitting
```r
# Solution: Reduce tree depth and features
rf_model <- randomForest(
  Churned ~ .,
  data = train_data,
  ntree = 300,     # Reduce trees
  mtry = 3,        # Reduce features per split
  maxnodes = 50    # Limit tree depth
)
```

## 📚 Resources

### Documentation
- [dplyr cheat sheet](https://dplyr.tidyverse.org/)
- [ggplot2 documentation](https://ggplot2.tidyverse.org/)
- [Random Forest guide](https://www.stat.berkeley.edu/~breiman/RandomForests/)

### Next Steps
1. Review generated insights
2. Validate model predictions
3. Design retention campaigns
4. Implement scoring pipeline
5. Monitor business impact

---

**Version**: 1.0 - Customized for ML Platform  
**Last Updated**: 2024  
**Support**: Review README sections or code comments for guidance
