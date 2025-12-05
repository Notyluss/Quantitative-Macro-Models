# Monetary Policy Transmission Analysis

## 📊 Project Overview

This project analyzes the transmission mechanism of monetary policy shocks in the UK economy using Vector Autoregression (VAR) methodology. By estimating the dynamic relationships between key macroeconomic variables, the analysis quantifies how monetary policy decisions propagate through the economy.

### 🎯 Key Research Question
*How do interest rate changes (monetary policy shocks) impact output and inflation in the UK?*

---

## 📈 Methodology

### Data
- **Dataset**: UK Quarterly Economic Data (1986-2019)
- **Variables**:
  - **Output**: Real GDP (log-transformed)
  - **Inflation**: Year-over-year CPI growth rate
  - **Policy Rate**: Bank of England interest rate

### Econometric Approach

1. **Vector Autoregression (VAR) Model**
   - Captures the dynamic, interdependent relationships between variables
   - Allows each variable to depend on its own lags and lags of all other variables
   
2. **Model Specification**
   - Lag length selected using Akaike Information Criterion (AIC)
   - Model includes constant and time trend
   - Stationarity verified via companion matrix eigenvalues

3. **Identification Strategy**
   - **Cholesky Decomposition**: Orthogonalized impulse responses
   - **Ordering**: Output → Inflation → Interest Rate
     - Assumes monetary policy reacts contemporaneously to output and inflation
     - Output and inflation respond to policy with a lag (standard in monetary VAR literature)

4. **Impulse Response Functions (IRFs)**
   - Trace out the dynamic effects of a one-unit shock to each variable
   - Bootstrap confidence bands (68% intervals) assess statistical significance
   - 24-quarter horizon captures medium-term transmission dynamics

---

## 🔍 Key Findings

### Monetary Policy Shock (Interest Rate ↑)
- **Output**: Contractionary effect — GDP declines gradually, consistent with monetary transmission theory
- **Inflation**: Downward pressure — prices fall as aggregate demand weakens (the "price puzzle" is minimal)
- **Persistence**: Effects fade after ~6-8 quarters, aligning with typical monetary policy lag estimates

### Inflation Shock
- **Interest Rate**: Responds positively (Taylor rule behavior)
- **Output**: Initially contracts as central bank tightens policy

### Output Shock
- **Inflation**: Moderate positive response
- **Interest Rate**: Mild tightening to stabilize economy

These results are consistent with New Keynesian macroeconomic theory and empirical central banking literature.

---

## 🖼️ Visual Results

The code generates two key visualizations:

1. **Raw Time Series**
   - 3-panel plot showing GDP, inflation, and interest rate trends over the sample period
   
2. **Impulse Response Functions (3x3 Grid)**
   - Rows: Response variables (Output, Inflation, Interest Rate)
   - Columns: Shock variables
   - See `output/IRF_Plots.png` for the final figure

---

## 🚀 How to Run

### Prerequisites
- **MATLAB** (R2018b or later recommended)
- **VAR Toolbox** (included in `code/lib/`)

### Execution
```matlab
% 1. Navigate to the code directory
cd code/

% 2. Run the analysis
run_uk_analysis

% The script will:
%  - Load and transform the data
%  - Estimate the VAR model
%  - Calculate impulse responses
%  - Generate plots
```

### Expected Output
- Two figures displayed in MATLAB:
  1. Raw macroeconomic time series
  2. 9-panel IRF grid
- Console output includes:
  - Selected lag length
  - Stationarity check results
  - Variable names confirmation

---

## 📂 Project Structure

```
/Monetary-Policy-Transmission
│
├── README.md               ← You are here! (Project documentation)
├── data/
│   └── UK_Data_86_19.xlsx  ← UK quarterly data (1986-2019)
├── code/
│   ├── run_uk_analysis.m   ← Main executable script
│   └── lib/                ← VAR Toolbox dependencies
└── output/
    └── IRF_Plots.png       ← Generated impulse response plots
```

---

## 🛠️ Technical Details

### Model Validation
- **Lag Selection**: Automated AIC minimization balances fit vs. parsimony
- **Stationarity**: All eigenvalues of companion matrix lie inside unit circle
- **Robustness**: Bootstrap-based confidence intervals account for parameter uncertainty

### Extensions (Future Work)
Potential improvements include:
- Sign restrictions or proxy-SVAR for cleaner identification
- Time-varying VAR to capture pre/post-financial crisis regime shifts
- Comparison with Euro Area or US data
- Incorporate additional variables (e.g., credit spreads, exchange rates)

---

## 📚 References

This analysis draws on standard VAR methodology developed in:

- **Sims, C. A. (1980)**. "Macroeconomics and Reality." *Econometrica*, 48(1), 1-48.
- **Christiano, L. J., Eichenbaum, M., & Evans, C. L. (1999)**. "Monetary Policy Shocks: What Have We Learned and to What End?" *Handbook of Macroeconomics*, Vol. 1A.
- **Uhlig, H. (2005)**. "What Are the Effects of Monetary Policy on Output? Results from an Agnostic Identification Procedure." *Journal of Monetary Economics*, 52(2), 381-419.

The VAR Toolbox used is based on:
- **Ambrogio Cesa-Bianchi** (2024). VAR Toolbox ([GitHub Repository](https://github.com/ambropo/VAR-Toolbox))

---

## 👤 Author

**Your Name Here**  
*MSc Quantitative Economics / Applied Macroeconomics*

Feel free to reach out for questions or collaboration!

---

## 📜 License

This project is for educational and research purposes. Data sources should be properly credited if reused.

---

### 🔗 Links
- [Full GitHub Repository](https://github.com/YOUR_USERNAME/Quantitative-Macro-Models)
- [VAR Toolbox Documentation](https://github.com/ambropo/VAR-Toolbox)

---

*"Central banks do not have divine wisdom. They try to do the best analysis they can and must be prepared to stand or fall by the quality of that analysis." – Eddie George, Former Governor of the Bank of England*
