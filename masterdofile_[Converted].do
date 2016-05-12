

** Master Thesis Dofile
** NOTE: To run this dofile you only need to set your working dir to the "working directory" dropbox folder
* Everything else remains the same

***************************************************************************************
*************************										***********************
**************************************** CONTENTS *************************************
*************************										***********************
***************************************************************************************

** 1) DATA CLEANING
		* 1.1) Merging HH modules B, E, A, and META
			* 1.1.1) Droping non hh heads in modules B and E
			* 1.1.2) Merging modules B and E to A and META
		* 1.2) Merging Community modules to HH_merged
			* 1.2.1) Reshaping module G (done but needs fixing)
			* 1.2.2) Reshaping module H (done)
			* 1.2.3) Reshaping module I (done)
			* 1.2.4) Reshaping module J
			* 1.2.5) Reshaping module K
			* 1.2.6) Reshaping module F2
			* 1.2.)7 Creating HH_COM_merged
		* 1.3) Merging Geovariables to HH_COM_merged
			* 1.3.1) Reshaping PlotGeovariables.dta
			* 1.3.2) Merging HouseholdGeovariables to PlotGeovariables_reshaped, to HH_COM_merged
		* 1.4) Merging Agricultural modules to HH_COM_merged
			* 1.4.1) Changing qty units to kilos
			* 1.4.2) Reshaping AG_MOD_BA
			* 1.4.3) Reshaping AG_MOD_G
			* 1.4.4) Reshaping AG_MOD_I
			* 1.4.5) Merging AG_MOD_BA to AG_MOD_G to AG_MOD_I to HH_COM_GeoHHGeoPlot_merged
			* 1.4.6) Reshaping AG_MOD_C
			* 1.4.7) Reshaping AG_MOD_D
		* 1.5) Merging Aggregate HH consumption to HH_COM_AG_merged
		* 1.6) Fractionalization and Polarization indexes
			* 1.6.1) Creating the indexes
			* 1.6.2) Merging census data to survey data 
** 2) DATA ANALYSIS
		* 2.1) Positive collective action regressions
		* 2.2) Negative collective action regressions
		* 2.3) Robustness checks


*****************************************************************************************
***********************											*************************
********************************* 1) DATA CLEANING **************************************
***********************											*************************
*****************************************************************************************

*set working dir: Note this changes depending on computer! Nothing else does
cd "C:\Users\Toshiba\Dropbox\Master Thesis\2013 revision Malawi\working directory"

******************** 1.1) Merging Household modules B, E, A, and META ***********
* There are 4000 households
* HH_MOD_B - at the individual level
* HH_MOD_E - at the individual level
* HH_MOD_A_FILT - household level
* HH_META - household level
* So for modules B, and E we need to drop all observations that are not household heads

* MISSING: HH_MOD_U - shock level 92000 obs. level of shock.

********************* 1.1.1) Droping non hh heads in HH_MOD_B and HH_MOD_E ***********

use "HH_MOD_B"

merge 1:1 y2_hhid PID using HH_MOD_E

keep if hh_b04 == 1

drop _merge

********************* 1.1.2) Merging HH_MOD_B and HH_MOD_E to HH_MOD_A_FILT and HH_META **************

merge 1:1 y2_hhid using HH_MOD_A_FILT
drop _merge
merge 1:1 y2_hhid using HH_META

drop _merge

* DONE with merging HH modules
save "HH_merged.dta", replace

********************* 1.2) Merging Community modules to HH_merged.dta  **********
** There are 204 communities (EAs)
** We need modules:
* COM_META - 204 obs.
* COM_MOD_D  - 204 obs.
* COM_MOD_F1 - 204 obs.
* COM_MOD_F2 - 233 obs. at level of project (13 different types, com_cf30)
* COM_MOD_G  - 2040 obs. at level of event (beneficial/bad for community)
* COM_MOD_H - 3672 obs. at level of community need
* COM_MOD_I - 1020 obs. at level of common pool resource 
* COM_MOD_J - 3876 obs. at level of organizations in community
* COM_MOD_K - 6528 obs. at level of item for sale


* So we must reshape modules: G, H, I, J, and K.
* MISSING: C.

********************* 1.2.1) Reshaping COM_MOD_G ****************
use "COM_MOD_G.dta" 

drop if com_cg35a==""
drop com_cg35c occ com_cg35a

* 8 categories of events
gen com_cg35a2= mod(_n-1,8) + 1

order ea_id com_cg35a com_cg35a2

reshape wide com_cg35b com_cg36 com_cg37, i(ea_id) j(com_cg35a2) 

label variable com_cg35b1 "important event 1 (bad)"
label variable com_cg35b2 "important event 2 (bad)"
label variable com_cg35b3 "important event 3 (bad)"
label variable com_cg35b4 "important event 4 (bad)"
label variable com_cg35b6 "important event 6(good)"
label variable com_cg35b7 "important event 7(good)"
label variable com_cg35b8 "important event 8(good)"

label variable com_cg361 "year important event 1 (bad)"
label variable com_cg362 "year important event 2 (bad)"
label variable com_cg363 "year important event 3 (bad)"
label variable com_cg364 "year important event 4 (bad)"

label variable com_cg365 "year important event 5 (good)"
label variable com_cg366 "year important event 6 (good)"
label variable com_cg367 "year important event 6 (good)"
label variable com_cg368 "year important event 8 (good)"

label variable com_cg371 "share of community affected event1"
label variable com_cg372 "share of community affected event2"
label variable com_cg373 "share of community affected event3"
label variable com_cg374 "share of community affected event4"
label variable com_cg375 "share of community affected event5"
label variable com_cg376 "share of community affected event6"
label variable com_cg377 "share of community affected event7"
label variable com_cg378 "share of community affected event8"

* That completes the manipulation of COM_MOD_G.dta

save "COM_MOD_G_reshaped.dta", replace


********************** 1.2.2)Reshaping COM_MOD_H *****************
 
use "COM_MOD_H"

tab com_ch0b, nolabel
* 18 categories of community needs

gen com_ch0b2= mod(_n-1,18) + 1

order ea_id com_ch0b2

* We drop occ because in this case it is the same as com_ch0b2 (list of all 18 categories)
drop occ 

reshape wide com_ch01 com_ch02 com_ch03 com_ch04 com_ch05 com_ch06 com_ch11 com_ch12 com_ch0b com_ch07a ///
com_ch07b com_ch07c com_ch07d com_ch07e com_ch07f com_ch07h com_ch07i com_ch08 com_ch09 com_ch09_1a ///
com_ch09_1b com_ch09_1c com_ch10 com_ch13a com_ch13b com_ch13c com_ch14 com_ch15, i(ea_id) j(com_ch0b2) 


* That completes the manipulation of COM_MOD_H.dta
save "COM_MOD_H_reshaped.dta", replace


********************** 1.2.3) Reshaping COM_MOD_I ********************
use "COM_MOD_I"

tab com_ci0b, nolabel
* From this we see there are 5 categories of common pool resources
gen com_ci0b2= mod(_n-1,5) + 1

order ea_id com_ci0b2

drop occ

reshape wide com_ci0b com_ci01 com_ci02 com_ci03 com_ci04 com_ci05 com_ci06 com_ci07a com_ci07b com_ci07c com_ci08a com_ci08b com_ci08c com_ci09a ///
com_ci09b com_ci09c com_ci10 com_ci11 com_ci12 com_ci13 com_ci14, i(ea_id) j(com_ci0b2)

* That completes the manipulation of COM_MOD_I.dta
save "COM_MOD_I_reshaped.dta", replace


*********************** 1.2.4) Reshaping COM_MOD_J **************
use "COM_MOD_J"

*we just need the number of groups and can drop the yes/ no group variable

replace com_cj02=0 if com_cj02==.

drop com_cj01

reshape wide com_cj0b com_cj02 com_cj03 com_cj04 com_cj05 com_cj06, i(ea_id) j(occ)

* That completes the manipulation of COM_MOD_J.dta
save "COM_MOD_J_reshaped.dta", replace

********************** 1.2.5) Reshaping COM_MOD_K ***************
use "COM_MOD_K"

destring com_ck00a, generate (com_ck00anum) ignore("CK") 

// i don't think we need this module

********************** 1.2.6) Reshaping COM_MOD_F2 ****************
use "COM_MOD_F2"

* At the level of agricultural project
* com_cf30 shows 13 different types of projects

com_cf30

reshape wide com_cf28 com_cf00 com_cf29 com_cf30 com_cf31 com_cf32a com_cf32b com_cf33 com_cf34 com_cf35a com_cf35b com_cf35c ///
com_cf35d com_cf35e, i(ea_id) j(occ)
save "COM_MOD_F2_reshaped.dta", replace

********************** 1.2.7) Creating HH_COM_merged **************
** We need modules:
* META - 204 obs.
* D  - 204 obs.
* F1 - 204 obs.
* F2 - 233 obs. at level of agricultural project (list of 13 options)
* G  - 2040 obs. at level of event (beneficial/bad for community)
* H - 3672 obs. at level of community need
* I - 1020 obs. at level of common pool resource 
* J - 3876 obs. at level of organizations in community
* K - 6528 obs. at level of item for sale

use "COM_META.dta"

merge 1:1 ea_id using COM_MOD_D

drop _merge
merge 1:1 ea_id using COM_MOD_F1

drop _merge
merge 1:1 ea_id using COM_MOD_F2_reshaped

drop _merge
merge 1:1 ea_id using COM_MOD_G_reshaped

drop _merge
merge 1:1 ea_id using COM_MOD_H_reshaped

drop _merge
merge 1:1 ea_id using COM_MOD_I_reshaped

drop _merge
merge 1:1 ea_id using COM_MOD_J_reshaped

drop _merge
merge 1:m ea_id using HH_merged
drop _merge

save "HH_COM_merged.dta", replace



*********************************** 1.3) Merging Geovariable modules ******************
* 2 modules, need them both:
* HouseholdGeovariables.dta - 4000 obs. HH level.
* PlotGeovariables.dta - 9389 obs. Plot level. 

*********************** 1.3.1) Reshaping PlotGeovariables.dta ****************

use "PlotGeovariables_IHPS.dta"
* y2_hhid ag_c00 uniquely identify each obs (plot)

* ag_c00 is string, so we need to make it numeric
encode ag_c00, gen(ag_c00_num)

reshape wide ag_c00 dist_hh slope elevation twi, i(y2_hhid) j(ag_c00_num)

save "PlotGeovariables_reshaped.dta", replace

*********************** 1.3.2) Merging HouseholdGeovariables to PlotGeovariables_reshaped, to HH_COM_merged **************
use "HouseholdGeovariables_IHPS.dta"
merge 1:1 y2_hhid using PlotGeovariables_merged

drop _merge

merge 1:1 y2_hhid using HH_COM_merged
drop _merge

save "HH_COM_GeoHHGeoPlot_merged.dta", replace

************************ 1.4) Merging Agricultural modules to HH_COM_merged ***************
** We need modules BA, G, and I. Controls: C and D.

* AG_MOD_BA - occ y2_hhid uniquely identify each obs (occ counts obs within each household)
* AG_MOD_G - 
* AG_MOD_I - 

*********************** 1.4.1) Changing qty units to kilos ********************


********

************************ 1.4.2) Reshaping AG_MOD_BA *************************

* We want to reshape to leave it at household level (4000 obs)
reshape wide , i(y2_hhid) j(occ)


************************ 1.4.3) Reshaping AG_MOD_G *************************



************************ 1.4.4) Reshaping AG_MOD_I *************************
reshape wide qx_type interview_status ag_i0b ag_i01 ag_i01_1 ag_i02a ag_i02b ag_i02c ag_i03 ag_i11 ag_i12a ag_i12b ag_i12c ag_i12_1a ag_i12_1b ///
ag_i13 ag_i14a ag_i14b ag_i15a ag_i15b ag_i16 ag_i17 ag_i18 ag_i19 ag_i20 ag_i21a ag_i21b ag_i21c ag_i21_1a ag_i21_1b ag_i22 ag_i23a ag_i23b ///
ag_i24a ag_i24b ag_i25 ag_i26 ag_i27 ag_i31a ag_i31b ag_i31c ag_i32a ag_i32b ag_i32c ag_i33a ag_i33b ag_i33c ag_i34a ag_i34b ag_i34c ag_i35a ///
ag_i35b ag_i35c ag_i36a ag_i36b ag_i36c ag_i36d ag_i37a ag_i37b ag_i38 ag_i39 ag_i40a ag_i40b ag_i40c ag_i41a ag_i41b ag_i42a ag_i42b, i(y2_hhid) j(occ)


************************ 1.4.5) Merging AG_MOD_BA to AG_MOD_G to AG_MOD_I to HH_COM_GeoHHGeoPlot_merged ************

************************ 1.4.6) Reshaping AG_MOD_C ************
use "AG_MOD_C.dta"
keep occ y2_hhid qx_type ag_c00 ag_c02 ag_c04c
reshape wide qx_type interview_status ag_c00 ag_c02 ag_c04c, i(y2_hhid) j(occ)
save "AG_MOD_C_reshaped.dta", replace

************************ 1.4.7) Reshaping AG_MOD_D ************


******************* 1.5) Merging Aggregate HH consumption to HH_COM_AG_merged *********************

* "Round 2 (2013) Consumption Aggregate.dta" is at household level. No reshaping needed.
use "Round 2 (2013) Consumption Aggregate.dta"

merge 1:1 y2_hhid using HH_COM_AG_merged
drop _merge

***************************** 1.6) Creating Fractionalization and Polarization indexes **********************





********************************************************************************
***********************								    ************************
******************************* 2) DATA ANALYSIS *******************************
***********************								    ************************
********************************************************************************

*********************** 2.1) Scatter plots fractionalization vs polarization ******************

* Linguistic heterogeneity
scatter fractionalization polarization

* Religious heterogeneity
scatter fractionalization polarization


*********************** 2.2) Positive collective action regressions ********************
* Positive collective action problems: irrigation systems, forests, grazing (existence of common pool resources)

reg harvest frac frac*irrigation controls_indiv controls_hh controls_plot controls_weather controls_comm
reg harvest pol pol*irrigation controls_indiv controls_hh controls_plot controls_weather controls_comm

reg harvest frac frac*forest controls_indiv controls_hh controls_plot controls_weather controls_comm
reg harvest pol pol*forest controls_indiv controls_hh controls_plot controls_weather controls_comm

reg harvest frac frac*grazing controls_indiv controls_hh controls_plot controls_weather controls_comm
reg harvest pol pol*grazing controls_indiv controls_hh controls_plot controls_weather controls_comm


reg income frac frac*irrigation controls_indiv controls_hh controls_plot controls_weather controls_comm
reg income pol pol*irrigation controls_indiv controls_hh controls_plot controls_weather controls_comm

reg income frac frac*forest controls_indiv controls_hh controls_plot controls_weather controls_comm
reg income pol pol*forest controls_indiv controls_hh controls_plot controls_weather controls_comm

reg income frac frac*grazing controls_indiv controls_hh controls_plot controls_weather controls_comm
reg income pol pol*grazing controls_indiv controls_hh controls_plot controls_weather controls_comm

* Open qn: controls_comm needed or not?

*********************** 2.3) Negative collective action regressions ********************
* Negative collective action problems: droughts, irregular rains, and floods.

reg harvest frac frac*drought controls_indiv controls_hh controls_plot controls_weather controls_comm
reg harvest pol pol*drought controls_indiv controls_hh controls_plot controls_weather controls_comm

reg harvest frac frac*irregular_rain controls_indiv controls_hh controls_plot controls_weather controls_comm
reg harvest pol pol*irregular_rain controls_indiv controls_hh controls_plot controls_weather controls_comm

reg harvest frac frac*flood controls_indiv controls_hh controls_plot controls_weather controls_comm
reg harvest pol pol*flood controls_indiv controls_hh controls_plot controls_weather controls_comm



reg income frac frac*drought controls_indiv controls_hh controls_plot controls_weather controls_comm
reg income pol pol*drought controls_indiv controls_hh controls_plot controls_weather controls_comm

reg income frac frac*irregular_rain controls_indiv controls_hh controls_plot controls_weather controls_comm
reg income pol pol*irregular_rain controls_indiv controls_hh controls_plot controls_weather controls_comm

reg income frac frac*flood controls_indiv controls_hh controls_plot controls_weather controls_comm
reg income pol pol*flood controls_indiv controls_hh controls_plot controls_weather controls_comm

********************************** 2.4) Robustness checks **************************

