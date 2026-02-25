/* Adapted from "Efficiency and water use: Dynamic effects of irrigation technology adoption"
by Micah Cameron-Harp and Nathan Hendricks

Code written by Micah Cameron-Harp
February 24th, 2026

This do file runs a Monte Carlo simulation generating TWFE estimates for the 
effect of adopting a more efficient irrigation technology on groundwater use 
over time. The resulting replicated estimates demonstrate how using TWFE in a
staggered adoption environemnt with dynamic treatment effects can produce 
biased ATE estimates.
*/

*Define directories and set working directory
	/* NOTE - you need to change the directory address in the next line */
global dr_root = "C:\Users\Micah\Dropbox\..."
global dr_data = "$dr_root\data"
global dr_output = "$dr_root\outputs"
global dr_output_main = "$dr_root\outputs\main_text"
global dr_output_app = "$dr_root\outputs\appendices"
global dr_output_log = "$dr_root\outputs\logs"
global dr_temp = "$dr_root\data\intermediate"
cd "$dr_temp"

set seed 12345

local est = "twfe"
	postfile buffer `est' using mcs_`est', replace
	qui forvalues i=1/1000 {
		clear
		set obs 900
		*Create time indicator
		*Choose time periods
		local periods = 3
		egen t = seq(), f(1) t(`periods') 
		label var t "Time"

		*Create panel_id
		local num_panels = _N/`periods'
		egen panel_id = seq(), f(1) t(`num_panels') b(`periods')
		xtset panel_id t
		xtdescribe

		*Create indicator for control, early cohort, late cohort
		*Decide balance of each
		local num_controls = 50
		local num_early = 50
		local num_late = 200
		gen g = "control" 
		replace g = "early" if inrange(panel_id, `num_controls'+1,`num_controls'+`num_early')
		replace g = "late" if inrange(panel_id, `num_controls'+`num_early'+1,`num_controls'+`num_early'+`num_late')

		*Create treatment indicator
		gen treated = 0
		replace treated = 1 if t>=2 & g=="early"
		replace treated = 1 if t>=3 & g=="late"

		*Set noise parameter
		local eit_mean = 0
		local eit_sd = 1

		*Create acre-feet time series for control
		gen acre_feet = 170 + rnormal(`eit_mean', `eit_sd')
		label var acre_feet "Acre-feet applied"
		
		*test for three period case
		drop if t==0

		*Create acre-feet time series for early adopter
		replace acre_feet = 160 + rnormal(`eit_mean', `eit_sd') if t==1 & g=="early" 
		replace acre_feet = 158 + rnormal(`eit_mean', `eit_sd') if t==2 & g=="early"
		replace acre_feet = 140 + rnormal(`eit_mean', `eit_sd') if t==3 & g=="early"

		*Create acre-feet time series for late adopters
		replace acre_feet = 165 + rnormal(`eit_mean', `eit_sd') if t==1 & g=="late"
		replace acre_feet = 165 + rnormal(`eit_mean', `eit_sd') if t==2 & g=="late"
		replace acre_feet = 163 + rnormal(`eit_mean', `eit_sd') if t==3 & g=="late"

		*Run twfe
		*save the coefficient on treated
			xtreg acre_feet i.t treated, fe
			post buffer (_b[treated])
	}
	postclose buffer 


*Open the dataset containing the TWFE coefficients 
use mcs_twfe, clear 
	*Summarize the coefficient variable
	sum twfe
	*Histogram 
	hist twfe, name(twfe_hist, replace) ///
		xtitle("Estimated effect of adoption using TWFE") ///
		title("Monte Carlo simulation results")
graph export "${dr_output_app}\TWFE_MonteCarlo_Results.tif", replace wid(6500) height(4500)