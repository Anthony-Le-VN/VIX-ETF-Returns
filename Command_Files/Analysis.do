//*****************************************************************************
// ECON 467 - Econometrics II
// Prof. Marshall 
// Author: Anthony Le	
// Date: Dec 6, 2025
// Denison University – Department of Economics
//*****************************************************************************
// 							ANALYSIS DO FILE
// 
// Purpose: This script imports analysis.dta and performs all neccessary 
//			analyses for the Empirical Results Section
//*****************************************************************************

clear
set more off, permanently
capture log close _all


//*****************************************************************************
//                         DIRECTORY & LOG SETUP
//*****************************************************************************

cd "/Users/le_a4/Library/CloudStorage/GoogleDrive-le_a4@denison.edu/My Drive/ECON467/Le-Project/Data/Analysis_Data/"

* Log file
log using "../../Command_Files/Analysis.log", ///
	replace text name(analysis)


* Optional setup (uncomment if needed)
// ssc install outreg2
// ssc install aaplot
// graph set window fontface "Garamond"



//*****************************************************************************
//                          PRELIMINARY ANALYSIS
//*****************************************************************************

//==============================================
// 0. Load Processed Analysis Dataset
//==============================================

use "analysis.dta", clear


//==============================================
// 1. Summary Statistics
//==============================================

* Compact codebook for quick structure overview
codebook, compact

* Export summary statistics (log scale and regular)
outreg2 using "Regression_Output/SummaryStat.doc", ///
    replace sum(log) auto(2)
	

//===============================================
// 2. Exploratory Visualizations
//===============================================

*** a. SPX weekly closing prices & VIX levels
twoway (line SPX Date, sort yaxis(1)) ///
	(line VIX Date, sort yaxis(2)), ///
    title("SPX Weekly Closing Prices & VIX Levels, Dec. 2004 - Nov. 2025") ///
	ytitle("SPX Weekly Closing", axis(1)) ///
    ytitle("VIX Levels", axis(2)) xtitle("Date") legend(position(6)) 

graph export "Visualization/spx_vs_VIX.png", ///
	as(png) replace


*** b. SPX weekly return & VIX levels 
twoway (line spx_ret Date, sort ) ///
	(line VIX Date, sort ), ///
    title("SPX Weekly Returns & VIX Levels, Dec. 2004 - Nov. 2025") ///
	ytitle("Weekly Return (%)/VIX Level (points)") ///
	xtitle("Date") legend(position(6)) 

graph export "Visualization/spx_return_vs_VIX.png", ///
	as(png) replace

	
*** c. Correlation between S&P 500 returns and VIX levels
corr spx_ret VIX


* Scatterplot: SPX returns vs. VIX levels
twoway scatter spx_ret VIX, msize(small) ///
    title("Relationship Between VIX and S&P 500 Returns, Dec. 2004 - Nov. 2025") ///
    ytitle("SPX Weekly Return (%)") xtitle("VIX Level (points)")

graph export "Visualization/spx_ret_vs_VIX.png", ///
	as(png) replace
 

*** d. ETF-Specific Average Returns 
	
twoway (line fund_ret Date, sort )  ///
	(line VIX Date, sort ), ///
	by(Fund, style(altleg) ///
	title("ETF Weekly Returns & VIX Levels, Dec. 2004 - Nov. 2025") )  ///
	ytitle("Weekly Return (%)/VIX Level (points)") ///
	xtitle("Date") ysc(noex ) ysize(5) xsize(10)
    
graph export "Visualization/etf_specific_ret_by_VIX.png", ///
	as(png) replace	
	
	
*** e. Average ETF Returns by VIX Regime

* Generate fund_ret variables by VIX ranges
gen fund_ret_1 = fund_ret if VIX < 20
gen fund_ret_2 = fund_ret if VIX >= 20 & VIX < 40
gen fund_ret_3 = fund_ret if VIX >= 40

* Plot average returns by VIX regimes
graph bar fund_ret_1 fund_ret_2 fund_ret_3, over(Fund)  ///
    ytitle("Average Weekly Return (%)") ///
    title("ETF Average Returns Across VIX Regimes, Dec. 2004 - Nov. 2025") ///
    legend(order(1 "VIX < 20" 2 "20 ≤ VIX < 40" 3 "VIX ≥ 40") ///
           ring(0) position(5)) ///
    bar(1, color(stc3)) bar(2, color(stc1)) bar(3, color(stc2))

graph export "Visualization/etf_ret_by_VIX.png", ///
	as(png) replace

//*****************************************************************************
//                                 MAIN ANALYSIS
//*****************************************************************************

//=================================================
// 0. Reload Full Panel Dataset
//=================================================

use "analysis.dta", clear


//=================================================
// 1. Panel Setup
//=================================================

* Create panel identifier from ETF ticker
encode Fund, gen(Fund_id)

* Declare panel structure
xtset Fund_id Date, weekly


//=================================================
// 2. Full-Panel Regressions
//=================================================

* 2.1 Baseline Model: VIX only

xtreg fund_ret VIX term_spread credit_spread, fe vce(cluster Fund_id)

outreg2 using "Regression_Output/results_main.xls", ///
    replace ctitle("VIX only")  2aster ///
    dec(3) keep(VIX term_spread credit_spread)


* 2.2 Add S&P 500 Returns

xtreg fund_ret VIX spx_ret term_spread credit_spread, fe vce(cluster Fund_id)

outreg2 using "Regression_Output/results_main.xls", ///
    append ctitle("+ SPX Return")  2aster ///
    dec(3) keep(VIX spx_ret term_spread credit_spread)


* 2.3 Full Model with Interaction (VIX × SPX Return)

xtreg fund_ret VIX spx_ret vix_spx term_spread credit_spread, ///
    fe vce(cluster Fund_id)

outreg2 using "Regression_Output/results_main.xls", ///
    append ctitle("+ Interaction")  2aster ///
    dec(3) keep(VIX spx_ret vix_spx term_spread credit_spread)


* 2.4. Random Effects

xtreg fund_ret VIX spx_ret vix_spx term_spread credit_spread, ///
	vce(cluster Fund_id)

outreg2 using "Regression_Output/results_main.xls", ///
    append ctitle("Random Effects") dec(3)  2aster


//=================================================
// 3. ETF-Specific Regressions (Cross-Sectional Differences)
//=================================================

levelsof Fund, local(etfs)

capture erase "Regression_Output/etf_specific_results.xls"

capture erase "Regression_Output/etf_specific_results.txt"

foreach f of local etfs {
    
    di "-----------------------------------------------------"
    di "Running ETF-specific regression for: `f'"
    di "-----------------------------------------------------"

    reg fund_ret VIX spx_ret vix_spx term_spread credit_spread ///
        if Fund == "`f'", robust

    outreg2 using "Regression_Output/etf_specific_results.xls", ///
        append ctitle("`f'") dec(3)  2aster
}


//*****************************************************************************
//                                   THE END
//*****************************************************************************



log close analysis
exit


