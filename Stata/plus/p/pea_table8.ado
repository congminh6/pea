*! version 0.1.1  12Sep2014
*! Copyright (C) World Bank 2017-2024 

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.

//Table 8. Inequality indicators

*pea_table8 [aw=weight_p], welfare(welfare) year(year) byind(urban) missing

cap program drop pea_table8
program pea_table8, rclass
	version 18.0
	syntax [if] [in] [aw pw fw], [Welfare(varname numeric) Year(varname numeric) byind(varlist numeric) core setting(string) excel(string) save(string) missing]
	
	if "`using'"~="" {
		cap use "`using'", clear
		if _rc~=0 {
			noi di in red "Unable to open the data"
			exit `=_rc'
		}
	}
	
	gen _all_ = 1
	la def _all_ 1 "All sample"
	la var _all_ "All sample"
	la val _all_ _all_
	local byind "_all_ `byind'"
	
	//house cleaning
	if "`excel'"=="" {
		tempfile xlsxout 
		local excelout `xlsxout'		
		local path "`xlsxout'"		
		local lastslash = strrpos("`path'", "\") 				
		local dirpath = substr("`path'", 1, `lastslash')		
	}
	else {
		cap confirm file "`excel'"
		if _rc~=0 {
			noi dis as error "Unable to confirm the file in excel()"
			error `=_rc'	
		}
		else local excelout "`excel'"
	}
	
	if "`missing'"~="" { //show missing
		foreach var of local byind {
			su `var'
			local miss = r(max)
			replace `var' = `=`miss'+10' if `var'==.
			local varlbl : value label `var'
			la def `varlbl' `=`miss'+10' "Missing", add
		}
	}
	
	qui {		
		//Weights
		local wvar : word 2 of `exp'
		qui if "`wvar'"=="" {
			tempvar w
			gen `w' = 1
			local wvar `w'
		}
	
		//missing observation check
		marksample touse
		local flist `"`wvar' `welfare' `year' `byind'"'
		markout `touse' `flist' 
		
		foreach var of varlist `byind' {
			local lbl`var' : variable label `var'
			local label1 : value label `var'	
			//`lvl`var1'_`lv''
			levelsof `var', local(lvgr)
			foreach lv of local lvgr {
				local lvl`var'_`lv' : label `label1' `lv'
			}			
		}
		
		tempfile dataori datalbl
		save `dataori', replace
		des, replace clear
		save `datalbl', replace
		use `dataori', clear
	} //qui
	
	* Create a frame to store the results
	* More intuitive name to current default frame
	/*
	cap frame drop this_survey
	frame rename default this_survey
	* Change to original frame
	frame change this_survey
	*/
	cap frame create temp_frame
	cap frame change temp_frame
	cap frame drop ineq_results	
	frame create ineq_results strL(var) float(group year obs pop) ///
							  float(mean median sd min max) ///
							  float(Gini Theil Atkinson_1 Atkinson_2 Sen) ///
							  float(p10p50 p25p50 p75p25 p75p50 p90p10 p90p50) ///
							  float(ge0 ge1 ge2) 
	
	use `dataori', clear
	* Get unique combinations of year
	levelsof `year', local(years)
	
	* Loop through each year
	foreach y in `years' {			
		*use `dataori', clear
		*keep if `year' == `y'
		foreach var of local byind {
			levelsof `var', local(groups)
			foreach grp of local groups {
				qui: ineqdeco `welfare' [w=`wvar'] if (`var' == `grp' & `year'==`y'), welfare
				*local grp = `grp'		
				//need to add in the missing indicator: palma, watts, bottom20share, and post result here
				
				* Post the results to the frame
				frame ineq_results {  
					frame post ineq_results ("`var'") (`grp') (`y') (`r(N)') (`r(sumw)')	///
						(`r(mean)') (`r(p50)') (`r(sd)') (`r(min)') (`r(max)') 			///
						(`r(gini)') (`r(ge1)') (`r(a1)') (`r(a2)') (`r(wgini)') ///
						(`r(p10p50)') (`r(p25p50)') (`r(p75p25)') (`r(p75p50)') (`r(p90p10)')  (`r(p90p50)') ///
						(`r(ge0)') (`r(ge1)') (`r(ge2)') 
				}
			} //lvl each group
		}		
	} //end years

	* See results
	frame change ineq_results
	
	d, varlist
	local vars `r(varlist)'
	unab omit: var group year
	local choose:  list vars - omit
	noi di "`choose'"
	foreach var of local choose {
		rename `var' ind_`var'
	}

	reshape long ind_, i(`year' var group) j(indicator) string
	
	*Atkinson_2

	gen indicatorlbl=.
	replace indicatorlbl = 1 if indicator=="Gini"
	replace indicatorlbl = 2 if indicator=="Theil"
	replace indicatorlbl = 3 if indicator=="Kuznets"
	replace indicatorlbl = 4 if indicator=="Atkinson_1"
	replace indicatorlbl = 5 if indicator=="Sen"
	replace indicatorlbl = 6 if indicator=="Watts"
	replace indicatorlbl = 7 if indicator=="p10p50"
	replace indicatorlbl = 8 if indicator=="p25p50"
	replace indicatorlbl = 9 if indicator=="p75p25"
	replace indicatorlbl = 10 if indicator=="p75p50"
	replace indicatorlbl = 11 if indicator=="p90p10"
	replace indicatorlbl = 12 if indicator=="p90p50"
	replace indicatorlbl = 13 if indicator=="Bottom20share"
	replace indicatorlbl = 14 if indicator=="ge0"
	replace indicatorlbl = 15 if indicator=="ge1"
	replace indicatorlbl = 16 if indicator=="ge2"
	
	la def indicatorlbl 1 "Gini index" 2 "Theil index" 3 "Palma (Kuznets) ratio" 4 "Atkinson index" 5 "Sen index" 6 "Watts index" 7 "p10p50" 8 "p25p50" 9 "p75p25" 10 "p75p50" 11 "p90p10" 12 "p90p50" 13 "Bottom 20% share of incomes" 14 "GE(0)" 15 "GE(1)" 16 "GE(2)"
	
	//label var and group keeping original ordering 
	local i=1
	local j=1
	gen var_order = .
	gen group_order = .
	foreach var1 of local byind {
		replace var_order =`j' if var=="`var1'"
		la def var_order `j' "`lbl`var1''", add
		local j = `j'+1
		levelsof group if var=="`var1'", local(grplvl)
		foreach lv of local grplvl {
			replace group_order = `i' if var=="`var1'" & group==`lv'
			la def group_order `i' "`lvl`var1'_`lv''", add
			local i = `i' + 1
		}
	}
	la val var_order var_order
	la val group_order group_order
	
	la val indicatorlbl indicatorlbl
	drop if indicatorlbl==.	
	ren ind_ value
	order indicator indicatorlbl value

	collect clear
	qui collect: table (group_order indicatorlbl) (`year'), stat(mean value) nototal nformat(%20.2f) missing
	collect style header group_order indicatorlbl `year', title(hide)
	*collect style header subind[.], level(hide)
	*collect style cell, result halign(center)
	collect title `"Table 8. Inequality indicators"'
	collect notes 1: `"Source: ABC"'
	collect notes 2: `"Note: The global ..."'
	collect style notes, font(, italic size(10))
			
	if "`excel'"=="" {
		collect export "`dirpath'\\Table8.xlsx", sheet(Table8) modify 	
		shell start excel "`dirpath'\\Table8.xlsx"
	}
	else {
		collect export "`excelout'", sheet(Table8, replace) modify 
	}
end 
	
	
	