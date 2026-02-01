//*****************************************************************************
// ECON 467 - Econometrics II
// Prof. Marshall 
// Author: Anthony Le	
// Date: Oct 23, 2025
// Denison University – Department of Economics
//*****************************************************************************
// 					PROCESSING & CONSTRUCTION DO FILE
// 
// Purpose: This script processes Bloomberg ETF and macro data into a 
//          panel dataset suitable for econometric analysis.
//          Final variables: Date, Fund, fund_ret, VIX, spx_ret, vix_spx, 
//          term_spread, credit_spread, price, SPX, US10YR, US3M, CBAA, CAAA
//*****************************************************************************

clear
set more off, permanently
capture log close _all


//*****************************************************************************
//                           DIRECTORY & LOG SETUP
//*****************************************************************************

cd "/Users/le_a4/Library/CloudStorage/GoogleDrive-le_a4@denison.edu/My Drive/ECON467/Le-Project"

* Log file
log using "Command_Files/Processing&Construction.log", ///
	replace text name(processing)


* Optional setup (uncomment if needed)
// ssc install outreg2
// ssc install aaplot
// graph set window fontface "Garamond"


//*****************************************************************************
//                         		CONSTRUCTION
//*****************************************************************************

* Import data
import excel using "Data/Original_Data/bloomberg_importable.xlsx", ///
    firstrow clear


//=============================================================================
// 1. Create sentiment & macro variables
//=============================================================================

* Compute weekly S&P 500 log returns
gen spx_ret = 100 * (ln(SPX[_n])-ln(SPX[_n-1]))

* Interaction term
gen vix_spx = VIX * spx_ret

* Compute yield spreads (term and credit)
gen term_spread   = 100 * (US10YR - US3M)
gen credit_spread = 100 * (CBAA   - CAAA)

* Save dataset with new variables 
save "Data/Original_Data/bloomberg_final.dta", replace

//=============================================================================
// 2. Reshape price data to long format
//=============================================================================

* Rename price variables to prepare for reshaping
rename SPY price1
rename QQQ price2
rename IWM price3
rename VUG price4
rename VTV price5
rename EFA price6
rename EEM price7
rename XLF price8
rename XLK price9

* Reshape from wide to long form
reshape long price, i(Date) j(Fund)

* Convert Fund codes (1–9) into ETF ticker labels
tostring Fund, replace
replace Fund = "SPY" if Fund == "1"
replace Fund = "QQQ" if Fund == "2"
replace Fund = "IWM" if Fund == "3"
replace Fund = "VUG" if Fund == "4"
replace Fund = "VTV" if Fund == "5"
replace Fund = "EFA" if Fund == "6"
replace Fund = "EEM" if Fund == "7"
replace Fund = "XLF" if Fund == "8"
replace Fund = "XLK" if Fund == "9"

* Sort by fund and date to ensure correct return calculations
sort Fund Date


//=============================================================================
// 3. Calculate und returns
//=============================================================================

* Calculate weekly log returns for each ETF
bysort Fund (Date): gen fund_ret = 100 * (ln(price[_n])-ln(price[_n-1]))


//=============================================================================
// 4. Label Variables 
//=============================================================================

label variable Date	  "Week Ending Date (Friday close)"
label variable Fund	  "ETF Identifier (Ticker)"
label variable price  "ETF Adjusted Close Price (USD)"
label variable VIX	  "CBOE Volatility Index (VIX) - Market Sentiment Indicator"
label variable SPX    "S&P 500 Index Level"

label variable US10YR  "U.S. 10-Year Treasury Yield (%)"
label variable US3M    "U.S. 3-Month Treasury Yield (%)"
label variable CBAA    "Moody's Baa Corporate Bond Yield (%)"
label variable CAAA    "Moody's Aaa Corporate Bond Yield (%)"

label variable vix_spx    "Interaction Term between VIX and SPX Returns"
label variable fund_ret   "ETF Weekly Log Return (%)"
label variable spx_ret    "S&P 500 Weekly Log Return (%)"

label variable term_spread   ///
	"Term Spread (10-Year minus 3-Month US Treasury, basis points)"
label variable credit_spread ///
	"Credit Spread (Baa minus Aaa Corporate Bond Yield, basis points)"



//=============================================================================
// 5. Save data
//=============================================================================

order Date Fund price fund_ret VIX spx_ret vix_spx term_spread credit_spread SPX 


* Save processed dataset in Analysis_Data folder
save "Data/Analysis_Data/analysis.dta", replace

	
	
//*****************************************************************************
//                         			THE END
//*****************************************************************************

log close processing
exit


