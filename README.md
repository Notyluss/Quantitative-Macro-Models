# Monetary Policy Transmission Analysis

A quantitative analysis of UK monetary policy using Vector Autoregression (VAR) to understand how interest rate changes affect GDP and inflation.

## What It Does

This project estimates the dynamic relationships between three key economic variables:
- **Output** (Real GDP)
- **Inflation** (Year-over-year CPI growth)
- **Policy Rate** (Bank of England interest rate)

Using quarterly data from 1986-2019, the model identifies how monetary policy shocks propagate through the UK economy.

## Data Sources

All data sourced from FRED (Federal Reserve Economic Data):

- **Interest Rate**: [3-Month Treasury Bill Rate (IR3TIB01GBQ156N)](https://fred.stlouisfed.org/series/IR3TIB01GBQ156N)
- **Real GDP**: [UK Real GDP at Constant Prices (CLVMNACSCAB1GQUK)](https://fred.stlouisfed.org/series/CLVMNACSCAB1GQUK)
- **CPI**: [UK Consumer Price Index (GBRCPIALLQINMEI)](https://fred.stlouisfed.org/series/GBRCPIALLQINMEI)

## Key Findings

**Monetary Policy Shock (Interest Rate ↑):**
- GDP contracts gradually over 6-8 quarters
- Inflation declines as demand weakens
- Results align with New Keynesian economic theory

## Methodology

- **Model**: Vector Autoregression (VAR) with Cholesky decomposition
- **Lag Selection**: Information criteria (AIC/BIC/HQC)
- **Impulse Responses**: 24-quarter horizon with bootstrap confidence bands
- **Identification**: Assumes monetary policy reacts contemporaneously to output and inflation

## How to Run

```matlab
cd code/
run_uk_analysis
```

**Requirements**: MATLAB (R2018b or later) — VAR Toolbox included in `code/lib/`

## Project Structure

```
/Monetary-Policy-Transmission
│
├── README.md               
├── data/
│   └── UK_Data.xlsx        
├── code/
│   ├── run_uk_analysis.m   
│   └── lib/                
└── output/
    └── IRF_Plots.png       
```
##Output
![Output Chart](output/Impulse%Response%Functions.png)
## Technical Highlights

- Automated lag selection via information criteria comparison
- Stationarity verification using companion matrix eigenvalues
- Bootstrap-based confidence intervals for robustness
- Clean, reproducible code with extensive commenting

## References

- Sims, C. A. (1980). "Macroeconomics and Reality." *Econometrica*
- Christiano et al. (1999). "Monetary Policy Shocks." *Handbook of Macroeconomics*
- VAR Toolbox by [Ambrogio Cesa-Bianchi](https://github.com/ambropo/VAR-Toolbox)

---
## Disclaimer
*This project is not a financial advice or investment strategy.*
*Built for my persponal curiosity and analysis.*
