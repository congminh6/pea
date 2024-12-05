*! version 0.1.1  12Sep2014
*! Copyright (C) World Bank 2017-2024 
*! Minh Cong Nguyen <mnguyen3@worldbank.org>; Henry Stemmler <hstemmler@worldbank.org>; Sandra Carolina Segovia Juarez <ssegoviajuarez@worldbank.org>
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

//Fig 3. Growth Incidence Curve

cap program drop pea_figure3
program pea_figure3, rclass
	version 18.0
	syntax [if] [in] [aw pw fw], [Welfare(varname numeric) spells(string) Year(varname numeric) NONOTES comparability(string) setting(string) excel(string) save(string) by(varname numeric) scheme(string) palette(string)]
	
	//load data if defined
	if "`using'"~="" {
		cap use "`using'", clear
		if _rc~=0 {
			noi di in red "Unable to open the data"
			exit `=_rc'
		}
	}
		
	if "`save'"=="" {
		tempfile saveout
		local save `saveout'
	}
	if "`nooutput'"~="" & "`excel'"~="" {
		noi dis as error "Cant have both nooutput and excel() options"
		error 1
	}
	if "`spells'"=="" {
		noi dis as error "Need at least two years, i.e. 2000 2004"
		error 1
	}
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
	
	local x = subinstr("`spells'",";"," ",.)		
	local keepyears : list uniq x
	// Prepare spells
	tokenize "`spells'", parse(";")	
	local i = 1
	local a = 1
	while "``i''" != "" {
		if "``i''"~=";" {
			local spell`a' "``i''"		
			dis "`spell`a''"
			local a = `a' + 1
		}	
		local i = `i' + 1
	}
	// Comparability
	local one = 1
	if "`comparability'" ~= "" {
		forv j=1(1)`=`a'-1' {
			local test
			local spell_c`j' = "`spell`j''"												// Save local
			qui levelsof `comparability', local(comp_years)								// Loop through all values of comparability
			foreach i of local comp_years {
				qui	levelsof year if `comparability' == `i', local(year_c)				// Create list of comparable years
				local year_c = "`year_c'" 
				local test_`i': list spell_c`j' in year_c								// Check if spell years are in list of comparable years
				local test "`test' `test_`i''"
			}
			local test_pos: list one in test												// Check if any spell has comparable years
			if (`test_pos' == 0) local spell`j' = ""										// If years not comparable, drop local
			if (`test_pos' == 1) local spell`j' = "`spell_c`j''"							// If years comparable, keep local			
		}
	}	// if
		
	// Figure colors
	local _spells = subinstr("`spells'"," ","",.)														// Get number of spells
	local _spells = subinstr("`_spells'",";"," ",.)		
	local groups = `:word count `_spells''
	pea_figure_setup, groups("`groups'") scheme("`scheme'") palette("`palette'")						//	groups defines the number of colors chosen, so that there is contrast (e.g. in viridis)

	//variable checks
	//check plines are not overlapped.
	//trigger some sub-tables
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
		local flist `"`wvar' `welfare' `by' `year'"'
		markout `touse' `flist' 
		
		tempfile dataori datalbl
		save `dataori', replace
		
		levelsof `year' if `touse', local(yrlist)
		local same : list yrlist === keepyears
		if `same'==0 {
			noi dis "There are different years requested, and some not available in the data."
			noi dis "Requested: `keepyears'. Available: `yrlist'"
		}
		gen _keep =. if `touse'
		foreach yr of local keepyears {
			replace _keep=1 if `year'==`yr' & `touse'
		}
		keep if _keep==1 & `touse'
		drop _keep
		gen _all_ = 1 if `touse'
		la var _all_ "All sample"
		la def _all_ 1 "All sample"
		la val _all_ _all_
		local by "_all_ `by'"		
		save `dataori', replace
		levelsof `year' if `touse', local(yrlist)
		
		clear
		tempfile data2
		save `data2', replace emptyok
				
		foreach byvar of local by {
			use `dataori', clear			
			levelsof `byvar', local(byvlist)
			local lbl`byvar' : variable label `byvar'				
			local label1 : value label `byvar'
			
			foreach lvl of local byvlist {				
				local lvl`byvar'_`lvl' : label `label1' `lvl'				
				foreach yr of local yrlist {
					use `dataori', clear
					tempvar qwlf
					cap _ebin `welfare' [aw=`wvar'] if `touse' & `year'==`yr' & `byvar'==`lvl', nquantiles(100) gen(`qwlf')
					if _rc!=0 {
						noi di in red "Error in creating percentile for `byvar'==`lvl'"						
						exit `=_rc'
					} 
					else {												
						collapse (mean) `welfare' [aw=`wvar'] if `touse' & `year'==`yr' & `byvar'==`lvl', by(`qwlf')
						ren `qwlf' percentile
						gen year = `yr'
						gen var = "`byvar'"
						gen var_lvl = `lvl'
						append using `data2'
						save `data2', replace
					}					
				}
			}	
		}
		use `data2', clear
		reshape wide `welfare', i(var var_lvl percentile) j(`year')
		
		//label var and group keeping original ordering 
		local i=1
		local j=1
		gen var_order = .
		gen group_order = .
		foreach var1 of local by {
			replace var_order =`j' if var=="`var1'"
			la def var_order `j' "`lbl`var1''", add
			local j = `j'+1
			levelsof var_lvl if var=="`var1'", local(grplvl)
			foreach lv of local grplvl {
				replace group_order = `i' if var=="`var1'" & var_lvl==`lv'
				la def group_order `i' "`lvl`var1'_`lv''", add
				local i = `i' + 1
			}
		}
		la val var_order var_order
		la val group_order group_order
				
		local vargic 
		local varlbl

		forv j=1(1)`=`a'-1' {
			local spell`j' : list sort spell`j'
			tokenize "`spell`j''"
			if "`1'"~="" & "`2'"~="" {
				dis "Spell`j': `1'-`2'"		
				gen gic_`1'_`2' = ((`welfare'`2'/`welfare'`1')^(1/(`2'-`1'))-1)*100
				local vargic "`vargic' gic_`1'_`2'"
				local varcount = `:word count `vargic''						// added so that legend element fits if not all spells are comparable
				la var gic_`1'_`2' "GIC Spell`varcount': `1'-`2'"
				local varlbl `"`varlbl' `varcount' "`1'-`2'""'
			}
		}

		sort var_order group_order percentile
		return local vargic = "`vargic'"
		return local varlbl = `"`varlbl'"'
		
		//Figure preparation
		local figname Figure3
		if "`excel'"=="" {
			local excelout2 "`dirpath'\\`figname'.xlsx"
			local act replace
		}
		else {
			local excelout2 "`excelout'"
			local act modify
		}
				
		local gr 1
		local u  = 5
		//Prepare Notes
		local notes "Source: World Bank calculations using survey data accessed through the Global Monitoring Database."
		local notes `"`notes'" "Note: Growth incidence curves display annualized household growth in per capita consumption" "or income by percentile of the welfare distribution between two periods."'
		if "`nonotes'" ~= "" local notes ""
		
		//Figure
		putexcel set "`excelout2'", `act'
		levelsof group_order, local(grlist)
		foreach gr of local grlist {
			tempfile graph`gr'
			local lbltitle : label group_order `gr'	
			
			twoway (connected `vargic' percentile, lcolor(${colorpalette}) mcolor(${colorpalette})) if group_order==`gr' & percentile>=1 & percentile<=99, ///
				legend(on order(`"`varlbl'"') rows(1) size(medium) position(6)) ///
				note("`notes'", size(small)) ///
				xtitle(Percentile, size(medium)) ytitle("Annualized growth, %", size(medium)) title("`lbltitle'", size(medium)) name(ngraph`gr', replace)
			
			putexcel set "`excelout2'", modify sheet(Figure3, replace)
			graph export "`graph`gr''", replace as(png) name(ngraph`gr') wid(3000)
			putexcel A`u' = image("`graph`gr''")
			putexcel save					
		}		
		cap graph close	
	} //qui	
	if "`excel'"=="" shell start excel "`dirpath'\\`figname'.xlsx"	
end