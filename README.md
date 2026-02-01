# 📊 Market Sentiment and ETF Returns  
**ECON 467 – Advanced Econometrics Final Project**

**Author:** Anthony Le  
**Date:** December 2025  

## Overview

This repository contains the full replication package for my ECON 467 final project:

> **“How does market sentiment, proxied by the VIX, affect the returns of major ETFs representing different equity market segments?”**

Using weekly data from **December 2004 to November 2025**, this project studies how changes in the VIX influence returns across nine major ETFs representing broad market, style, sectoral, and international equity segments. The analysis employs fixed-effects panel regressions and ETF-specific models to document **heterogeneity and asymmetry** in volatility sensitivity.

All tables, figures, and empirical results in the final paper are fully reproducible from the code in this repository.

---

## Key Findings

- A one-standard-deviation increase in VIX reduces average ETF weekly returns by **~1.36 percentage points**
- Volatility sensitivity varies substantially across market segments  
  - **Financials (XLF)** and **small caps (IWM)** are the most sensitive  
  - **Value stocks (VTV)** are the least sensitive
- Volatility effects are **asymmetric**  
  - “Good volatility” during market rallies is significantly less harmful than volatility during downturns

---

## Repository Structure

Le-Project/
│
├── Final Paper – Le.pdf
│
├── Command_Files/
│ ├── Processing&Construction.do
│ ├── Processing&Construction.log
│ ├── Analysis.do
│ └── Analysis.log
│
├── Data/
│ ├── Original_Data/
│ │ ├── bloomberg_raw.xlsx
│ │ ├── bloomberg_importable.xlsx
│ │ ├── bloomberg_final.dta
│ │ └── Metadata/
│ │ └── Codebook.docx
│ │
│ ├── Analysis_Data/
│ │ └── analysis.dta
│ │
│ ├── Regression_Output/
│ │ ├── results_main.xls
│ │ ├── results_main.txt
│ │ ├── etf_specific_results.xls
│ │ ├── etf_specific_results.txt
│ │ ├── SummaryStat.doc
│ │ └── SummaryStat.txt
│ │
│ └── Visualization/
│ ├── etf_ret_by_VIX.png
│ ├── etf_specific_ret_by_VIX.png
│ ├── spx_ret_vs_VIX.png
│ └── spx_vs_VIX.png
│
├── Documents/
│ ├── Final Paper – Le.docx
│ └── Read Me – Le.docx
│
└── Read Me – Le.pdf



---

## Data Description

- **ETFs (9):** SPY, QQQ, IWM, VUG, VTV, EFA, EEM, XLF, XLK  
- **Sentiment Proxy:** CBOE Volatility Index (VIX)  
- **Market Controls:**  
  - S&P 500 returns  
  - Term spread (10Y – 3M Treasury)  
  - Credit spread (Moody’s Baa – Aaa)  
- **Frequency:** Weekly  
- **Observations:** 9 ETFs × ~1,140 weeks = 10,260 ETF-week observations  

Data were sourced from **Bloomberg Terminal** and processed in Stata.

---

## Replication Instructions

### Software Requirements

- **Stata BE, Version 18**
- Stata package: `outreg2`

### Steps to Replicate

1. **Set working directory**
   ```stata
   cd "path/to/Le-Project"
   ```

2. **Run data processing**
   ```stata
   do Command_Files/Processing&Construction.do
   ```

   This script:
   - Imports Bloomberg data  
   - Constructs weekly ETF log returns  
   - Constructs S&P 500 weekly returns  
   - Creates the VIX–SPX interaction term  
   - Constructs term and credit spreads  
   - Reshapes ETF price data from wide to long format  
   - Saves the final analysis dataset as `Data/Analysis_Data/analysis.dta`

3. **Run empirical analysis**
   ```stata
   do Command_Files/Analysis.do
   ```

   This script:
   - Loads `analysis.dta`
   - Produces summary statistics
   - Generates descriptive visualizations
   - Estimates fixed-effects panel regressions
   - Estimates ETF-specific regressions
   - Exports regression tables and figures to:
     - `Data/Regression_Output/`
     - `Data/Visualization/`

---

## Expected Output

Successful replication will reproduce:

- `analysis.dta`
- Summary statistics tables
- Regression output files
- All figures reported in the paper
- Stata log files documenting execution

---

## Notes

- All tables and figures in the final paper are generated **entirely** from `Analysis.do`
- Log files are included to ensure full transparency and reproducibility
- The repository is organized to follow best practices for empirical replication

---

## Citation

If you reference this work, please cite:

> Le, Anthony (2025). *How does market sentiment, proxied by the VIX, affect the returns of major ETFs representing different equity market segments?* ECON 467 Final Paper.
