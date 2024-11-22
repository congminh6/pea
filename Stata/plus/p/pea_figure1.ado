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

//Figure 1. Poverty rates by year lines
//todo: add comparability, add the combine graph option

cap program drop pea_figure1
program pea_figure1, rclass
	version 18.0
	syntax [if] [in] [aw pw fw], [NATWelfare(varname numeric) NATPovlines(varlist numeric) PPPWelfare(varname numeric) PPPPovlines(varlist numeric) FGTVARS Year(varname numeric) urban(varname numeric) LINESORTED setting(string) comparability(string) combine(string) NOOUTPUT excel(string) save(string) MISSING scheme(string) palette(string)]

	local persdir : sysdir PERSONAL	
	if "$S_OS"=="Windows" local persdir : subinstr local persdir "/" "\", all		
	
	//house cleaning	
	if "`urban'"=="" {
		noi di in red "Sector/urban variable must be defined in urban()"
		exit 1
	}
	if "`comparability'"=="" {
		noi di in red "Warning: Comparability option not specified for Figure 1. Non-comparable spells may be shown."	// Not a strict condition
	}
	else if "`comparability'"~="" {
		qui ta `year'
		local nyear = r(r)
		qui ta `comparability'
		local ncomp = r(r)
		if `ncomp' > `nyear' {
			noi dis as error "Inconsistency between number of years and number of comparable data points."
			error 1
		}
	}	
	// Combine options
	if "`combine'" == "" {
			noi di in red "Combine option not specified, singe figures produced"	// Not a strict condition	
	}
	if "`combine'" == "no" {
		local combine = ""
	}
	if ("`combine'" ~= "yes" & "`combine'" ~= "no" & "`combine'" ~= "") {
			noi dis as error "Invalid option, combine may only take yes, no or be missing."
			error 1	
	}
	if "`using'"~="" {
		cap use "`using'", clear
		if _rc~=0 {
			noi di in red "Unable to open the data"
			exit `=_rc'
		}
	}
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
	
	//Number of groups (for colors)
	qui levelsof `urban', local(group_num)
	local groups = `:word count `group_num'' + 1

	// Figure colors
	pea_figure_setup, groups("`groups'") scheme("`scheme'") palette("`palette'")	//	groups defines the number of colors chosen, so that there is contrast (e.g. in viridis)

	//variable checks
	//check plines are not overlapped.
	//trigger some sub-tables
	qui {		
		//order the lines
		if "`linesorted'"=="" {
			if "`ppppovlines'"~="" {
				_pea_pline_order, povlines(`ppppovlines')			
				local ppppovlines `=r(sorted_line)'
				foreach var of local ppppovlines {
					local lbl`var' `=r(lbl`var')'
				}
			}
			
			if "`natpovlines'"~="" {
				_pea_pline_order, povlines(`natpovlines')
				local natpovlines `=r(sorted_line)'
				foreach var of local natpovlines {
					local lbl`var' `=r(lbl`var')'
				}
			}
		}
		else {
			foreach var of varlist `natpovlines' `ppppovlines' {
				local lbl`var' : variable label `var'
			}
		}
	}

	//Weights
	local wvar : word 2 of `exp'
	qui if "`wvar'"=="" {
		tempvar w
		gen `w' = 1
		local wvar `w'
	}
	
	
	//missing observation check
	marksample touse
	local flist `"`wvar' `natwelfare' `natpovlines' `pppwelfare' `ppppovlines' `year'"'
	markout `touse' `flist' 
	
	tempfile dataori datacomp data1 data2
	save	`dataori'
	qui sum urban, d
	local max_val = r(max) + 1
	
	//store comparability
	if "`comparability'"~="" {
		bys  `year': keep if _n == 1
		keep `year' `comparability'
		save `datacomp'
	}	
	
	// Create fgt
	use `dataori'
	if "`fgtvars'"=="" { //only create when the fgt are not defined			
		//FGT
		if "`natwelfare'"~="" & "`natpovlines'"~="" _pea_gen_fgtvars if `touse', welf(`natwelfare') povlines(`natpovlines')
		if "`pppwelfare'"~="" & "`ppppovlines'"~="" _pea_gen_fgtvars if `touse', welf(`pppwelfare') povlines(`ppppovlines') 
	}	

	//variable checks
	save `data1', replace
	
	//FGT national
	use `data1', clear
	groupfunction  [aw=`wvar'] if `touse', mean(_fgt*) by(`year')
	gen `urban' = `max_val' 			

	save `data2', replace
	
	//FGT urban-rural
	foreach var of local urban {
		use `data1', clear
		groupfunction  [aw=`wvar'] if `touse', mean(_fgt*) by(`year' `var')
		append using `data2'
		save `data2', replace
	}	
	
	// Add comparability variable
	if "`comparability'"~="" {
		merge m:1 `year' using `datacomp', nogen
		keep `year' `urban' `comparability' _fgt0*
	}
	else if "`comparability'"=="" {
		keep `year' `urban' _fgt0*
	}	
	// Clean and label
	label values `urban' urban
	if "`ppppovlines'"~="" {
		foreach var of local ppppovlines {
			label var _fgt0_`pppwelfare'_`var' "`lbl`var''"
			replace   _fgt0_`pppwelfare'_`var' = _fgt0_`pppwelfare'_`var' * 100
		}
	}
	
	if "`natpovlines'"~="" {
		foreach var of local natpovlines {
			label var _fgt0_`natwelfare'_`var' "`lbl`var''"
			replace   _fgt0_`natwelfare'_`var' = _fgt0_`natwelfare'_`var' * 100
		}
	}
	
	// Figure	
	qui levelsof `urban'		, local(group_num)
	if ("`comparability'"~="") qui levelsof `comparability', local(compval)
	qui levelsof `year'			, local(yearval)
	label define urban `max_val' "Total", add									// Add Total as last entry

	foreach i of local group_num {
		local j = `i' + 1			
		local scatter_cmd`i' = `"scatter var year if `urban'== `i', mcolor("${col`j'}") lcolor("${col`j'}") || "'								// Colors defined in pea_figure_setup
		local scatter_cmd "`scatter_cmd' `scatter_cmd`i''"
		local label_`i': label(`urban') `i'
		local legend`i' `"`j' "`label_`i''""'
		local legend "`legend' `legend`i''"	
		// Connect years (only if comparable if option is specified)
		if "`comparability'"~="" {																											// If comparability specified, only comparable years are connected
			foreach co of local compval {
				local line_cmd`i'`co' = `"line var year if `urban'== `i' & `comparability'==`co', mcolor("${col`j'}") lcolor("${col`j'}") || "'
				local line_cmd "`line_cmd' `line_cmd`i'`co''"
			}
			local note "Note: Non-connected dots indicate that survey-years are not comparable."
		}
		else if "`comparability'"=="" {
			local line_cmd`i' = `"line var year if `urban'== `i', mcolor("${col`j'}") lcolor("${col`j'}") || "' 					
			local line_cmd "`line_cmd' `line_cmd`i''"
		}
	}		

	if "`excel'"=="" {
		local excelout2 "`dirpath'\\Figure1.xlsx"
		local act replace
	}
	else {
		local excelout2 "`excelout'"
		local act modify
	}	
	
	local gr = 1
	local u  = 1
	putexcel set "`excelout2'", `act'
	//change all legend to bottom, and maybe 2 rows
	//add comparability
	foreach var of varlist _fgt* {
		rename `var' var
		tempfile graph`gr'
		local lbltitle : variable label var
		if "`combine'" == "" {
			twoway `scatter_cmd' `line_cmd'									///	
					  , legend(order("`legend'")) 							///
					  ytitle("Poverty rate (percent)") 						///
					  xtitle("")											///
					  title("`lbltitle'")									///
					  xlabel("`yearval'")									///
					  name(ngraph`gr', replace)								///
					  note(`note')
			putexcel set "`excelout2'", modify sheet(Figure1_`gr', replace)	  
			graph export "`graph`gr''", replace as(png) name(ngraph`gr') wid(3000)		
			putexcel A`u' = image("`graph`gr''")
			putexcel save	
			local gr = `gr' + 1
			rename var `var'
		}
		if "`combine'" ~= "" {													// If combine specified, without notes 
			twoway `scatter_cmd' `line_cmd'									///	
					  , legend(order("`legend'")) 							///
					  ytitle("Poverty rate (percent)") 						///
					  xtitle("")											///
					  title("`lbltitle'")									///
					  xlabel("`yearval'")									///
					  name(ngraph`gr', replace)		
			local graphnames "`graphnames' ngraph`gr'"
			local gr = `gr' + 1
			rename var `var'
	}
	}	
	if "`combine'" ~= "" {														// If combine specified, export combined graph
		tempfile graph`gr'
		graph combine `graphnames', note(`note') name(ngraphcomb)
		putexcel set "`excelout2'", modify sheet(Figure1_comb, replace)	  
		graph export "`graph`gr''", replace as(png) name(ngraphcomb) wid(3000)		
		putexcel A`u' = image("`graph`gr''")
		putexcel save
	}
	cap graph close	
	if "`excel'"=="" shell start excel "`dirpath'\\Figure1.xlsx"

end	
