/* "Efficiency and water use: Dynamic effects of irrigation technology adoption"
by Micah Cameron-Harp and Nathan Hendricks

Code written by Micah Cameron-Harp
May 16th, 2024

This do file runs the Monte Carlo simulation depicted in Figure B1 and then
	creates Figure B3 displaying the resulting biased TWFE estimate.
*/

*Define directories and set working directory
	/* NOTE - To replicate our results, you need to change the directory address in the next line */
global dr_root = "C:\Users\Micah\Dropbox\Irrigation technology transition\final revisions for conditional acceptance\replication materials"
global dr_data = "$dr_root\data"
global dr_output = "$dr_root\outputs"
global dr_output_main = "$dr_root\outputs\main_text"
global dr_output_app = "$dr_root\outputs\appendices"
global dr_output_log = "$dr_root\outputs\logs"
global dr_temp = "$dr_root\data\intermediate"
cd "$dr_temp"

****************************** Figure B1 ***************************************
clear
set obs 12
*Create time indicator
egen t = seq(), f(0) t(3) 
label var t "Time"
*Create indicator for control, early cohort, late cohort
egen treatment = seq(), f(1) t(3) b(4)
gen g = "control" 
replace g = "early" if treatment==2
replace g = "late" if treatment==3

*Create acre-feet time series for control
gen acre_feet = 170
label var acre_feet "Acre-feet applied"

*Create acre-feet time series for early adopter
replace acre_feet = 160 if t==0 & g=="early" 
replace acre_feet = 160 if t==1 & g=="early" 
replace acre_feet = 158 if t==2 & g=="early"
replace acre_feet = 140 if t==3 & g=="early"

*Create acre-feet time series for late adopters
replace acre_feet = 165 if t==0 & g=="late"
replace acre_feet = 165 if t==1 & g=="late"
replace acre_feet = 165 if t==2 & g=="late"
replace acre_feet = 163 if t==3 & g=="late"

*Drop if t==0
drop if t==0

*Create binary treatment indicator
gen treated=0
replace treated=1 if treatment!=1 & t >= treatment

*Plot the time series
	tw (line acre_feet t if g=="control", lcolor(orange)) ///
		(line acre_feet t if g=="early" & t <= 1, lcolor(navy)) ///
		(line acre_feet t if g=="early" & t >= 1, lcolor(navy) lpattern(dash)) ///
		(line acre_feet t if g=="late" & t <= 2, lcolor(purple)) ///
		(line acre_feet t if g=="late" & t >= 2, lcolor(purple) lpattern(dash)) ///
		(scatter acre_feet t if g=="control", mcolor(orange) msymbol(O)) ///
		(scatter acre_feet t if  g=="late" & t < 3, mcolor(purple) msymbol(O)) ///
		(scatter acre_feet t if  g=="late" & t >= 3, mcolor(purple) msymbol(T)) ///
		(scatter acre_feet t if  g=="early" & t < 2, mcolor(navy)) ///
		(scatter acre_feet t if  g=="early" & t >= 2, mcolor(navy) msymbol(T)) ///
		(scatter acre_feet t if  g=="early" & t > 3, mcolor(black) msymbol(O)) ///
		(scatter acre_feet t if  g=="early" & t > 3, mcolor(black) msymbol(T)) ///
		(line acre_feet t if  g=="early" & t > 3, lcolor(black) lpattern(dash)), ///
		ysc(r(135 175)) ylabel(140(10)170) xlabel(1(1)3) graphregion(color(white)) ///
		title("") ///
		ytitle("Acre-feet applied") ///
		legend(cols(2) order(1 13 4 11 2 12) label(1 "Control group") ///
		position(6) ///
		labe(2 "Early adopter") label(4 "Late adopter") ///
		label(11 "Old technology") label(12 "New technology") label(13 "Post adoption")) 
		
graph export "${dr_output_app}\figureB1.tif", replace wid(6500) height(6500)

****************************** Figure B2 ***************************************
*Plot each of the 2x2's 
*Start with Early Group versus Untreated Group
tw (connected acre_feet t if g=="control", lcolor(orange) mcolor(orange) msymbol(O)) ///
	(connected acre_feet t if g=="early" & t <= 1, lcolor(navy) mcolor(navy)) ///
	(line acre_feet t if g=="early" & t >= 1 & t<=2, lcolor(navy) lpattern(dash)) ///
	(connected acre_feet t if g=="early" & t >= 2, lcolor(navy) mcolor(navy) msymbol(T) lpattern(dash)) ///
	(line acre_feet t if g=="control" & t > 3, lcolor(orange)) ///
	(line acre_feet t if g=="late" & t > 3, lcolor(purple)) ///
	(line acre_feet t if g=="early" & t > 3, lcolor(navy)) ///
	(scatter acre_feet t if  g=="early" & t > 3, mcolor(black) msymbol(O)) ///Add these in for the legend entries
	(scatter acre_feet t if  g=="early" & t > 3, mcolor(black) msymbol(T)) ///
	(line acre_feet t if  g=="early" & t > 3, lcolor(black) lpattern(dash)), ///
	title("(a) Early versus control", size(medium)) ///
	ytitle("") ///
	xtitle("") ///
	ysc(r(135 175)) ylabel(140(10)170) xlabel(1(1)3) graphregion(color(white)) ///
	legend(cols(2) order(5 10 6 8 7 9) label(5 "Control group") ///
		label(7 "Early adopter") label(6 "Late adopter") ///
		label(8 "Old technology") label(9 "New technology") label(10 "Post adoption") ///
		position(6)) ///
	name(early_vs_control, replace)
	
*Late Group versus Untreated Group
tw (connected acre_feet t if g=="control", lcolor(orange) mcolor(orange) msymbol(O)) ///
	(connected acre_feet t if g=="late" & t <= 2, lcolor(purple) mcolor(purple)) ///
	(line acre_feet t if g=="late" & t >= 2, lcolor(purple) mcolor(purple) lpattern(dash)) ///
	(scatter acre_feet t if g=="late" & t > 2, mcolor(purple) msymbol(T)), ///
	title("(b) Late versus control", size(medium)) ///
	ytitle("") ///
	xtitle("") ///
	ysc(r(135 175)) ylabel(140(10)170) xlabel(1(1)3) graphregion(color(white)) ///
	legend(off) ///
	name(late_vs_control, replace)
	
*Early group versus late group, before 2
tw (connected acre_feet t if g=="early" & t <= 1, lcolor(navy) mcolor(navy) msymbol(O)) ///
	(line acre_feet t if g=="early" & inrange(t, 1, 2), lcolor(navy) lpattern(dash)) ///
	(scatter acre_feet t if g=="early" & t==2, mcolor(navy) msymbol(T)) ///
	(connected acre_feet t if g=="late" & t <= 2, lcolor(purple) mcolor(purple) msymbol(O)), ///
	title("(c) Early versus late, {it:t{&le}2}", size(medium)) ///
	ytitle("") ///
	xtitle("") ///
	ysc(r(135 175)) ylabel(140(10)170) xlabel(1(1)3) graphregion(color(white)) ///
	legend(off) ///
	name(early_vs_late, replace)
	
*Late group versus early group, after 2
tw (connected acre_feet t if g=="early" & t >= 2, lcolor(navy) lpattern(dash) mcolor(navy) msymbol(T)) ///
	(line acre_feet t if g=="late" & t >= 2, lcolor(purple) lpattern(dash)) ///
	(scatter acre_feet t if g=="late" & t == 2, mcolor(purple)  msymbol(O)) ///
	(scatter acre_feet t if g=="late" & t > 2, mcolor(purple) msymbol(T)), ///
	title("(d) Late versus early, {it:t{&ge}2}", size(medium)) ///
	ytitle("") ///
	xtitle("") ///
	ysc(r(135 175)) ylabel(140(10)170) xlabel(1(1)3) graphregion(color(white)) ///
	legend(off) ///
	name(late_vs_early, replace)

*Combine the four graphs in a 2x2 matrix 
grc1leg2 early_vs_control late_vs_control early_vs_late late_vs_early, ///
	rows(2) cols(2) legendfrom(early_vs_control) xcommon b2title("Time") ycommon l1title("Acre-feet applied") ///
	labsize(vsmall) graphregion(color(white)) xsize(6.5) ysize(6.5) iscale(.8)
graph export "${dr_output_app}\figureB2.tif", replace wid(6500) height(6500)