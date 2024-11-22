*! version 0.1.1  12Sep2014
*! Copyright (C) World Bank 2017-2024 
*! Minh Cong Nguyen <mnguyen3@worldbank.org>; Sandra Carolina Segovia Juarez <ssegoviajuarez@worldbank.org>
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

cap program drop pea_figures
program pea_figures, rclass
	version 18.0	
	syntax [if] [in] [aw pw fw], [* NATWelfare(varname numeric) NATPovlines(varlist numeric) PPPWelfare(varname numeric) PPPPovlines(varlist numeric)  Year(varname numeric) SETting(string) excel(string) save(string) BYInd(varlist numeric) age(varname numeric) male(varname numeric) hhhead(varname numeric) edu(varname numeric) urban(varname numeric) married(varname numeric) school(varname numeric) services(varlist numeric) assets(varlist numeric) hhsize(varname numeric) hhid(string) pid(string) industrycat4(varname numeric) lstatus(varname numeric) empstat(varname numeric) ONELine(varname numeric) ONEWelfare(varname numeric) MISSING Country(string) LATEST WITHIN3 BENCHmark(string) spells(string)  scheme(string) palette(string)]	
		
	//load setting
	qui if "`setting'"=="GMD" {
		_pea_vars_set, setting(GMD)
		local vlist age male hhhead edu urban married school hhid pid hhsize industrycat4 empstat lstatus services assets
		foreach st of local vlist {
			local `st' "${pea_`st'}"
		}		
	}
	
	//house cleaning
	
	//variable checks
	//missing rate of key variables
	qui if "`excel'"=="" {
		tempfile xlsxout 	
		local path "`xlsxout'"		
		local lastslash = strrpos("`path'", "\") 				
		local dirpath = substr("`path'", 1, `lastslash')
		local date = c(current_date)
		local time = c(current_time) 
		local time : subinstr local time ":" "_", all		
		local excelout "`dirpath'\\PEA_figures_`date'_`time'.xlsx"
		putexcel save
	}
	else {
		cap confirm file "`excel'"
		if _rc~=0 {
			noi dis as error "Unable to confirm the file in excel()"
			error `=_rc'	
		}
		else local excelout "`excel'"
	}
	
	if "`latest'"~="" & "`within3'"~="" {
		noi dis as error "Either latest or wtihin3, not both options"
		error 1
	}
	if "`latest'"=="" & "`within3'"=="" local latest latest
	
	qui {
		local country "`=upper("`country'")'"
		cap drop code
		gen code = "`country'"
		//order the lines
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
		
		tempfile dataori datalbl
		save `dataori', replace
		des, replace clear
		save `datalbl', replace
		use `dataori', clear
	
		//FGT
		if "`natwelfare'"~="" & "`natpovlines'"~="" _pea_gen_fgtvars if `touse', welf(`natwelfare') povlines(`natpovlines')
		if "`pppwelfare'"~="" & "`ppppovlines'"~="" _pea_gen_fgtvars if `touse', welf(`pppwelfare') povlines(`ppppovlines') 
		
		//B40 T60 Mean - only for one distribution
		if "`natwelfare'"~="" & "`pppwelfare'"~="" local distwelf `natwelfare'
		if "`natwelfare'"=="" & "`pppwelfare'"~="" local distwelf `pppwelfare'
		_pea_gen_b40 [aw=`wvar'] if `touse', welf(`distwelf') by(`year')
		clonevar _Gini_`distwelf' = `distwelf' if `touse'
		gen double _prosgap_`pppwelfare' = 25/`pppwelfare' if `touse'
		gen _vulpov_`onewelfare'_`oneline' = `onewelfare'< `oneline'*1.5  if `touse'
		gen double _pop = `wvar'
		
		tempfile data1 data2
		save `data1', replace
	} //qui
	
	
	//trigger
	
	//Figure 1
	qui use `data1', clear	
	cap pea_figure1 [aw=`wvar'], natw(`natwelfare') natp(`natpovlines') pppw(`pppwelfare') pppp(`ppppovlines') year(`year') fgtvars linesorted urban(`urban') oneline(`oneline') onewelfare(`onewelfare') comparability(`comparability') scheme(`scheme') palette(`palette') excel("`excelout'")
	if _rc==0 {
		noi dis in green "Figure 1....... Done"
		local ok = 1
	}
	else noi dis in red "Figure 1....... Not done"
	
	//Figure 2	
	qui use `dataori', clear		
	cap pea_figure2 [aw=`wvar'], c(`country') year(`year') fgtvars oneline(`oneline') onewelfare(`onewelfare') scheme(`scheme') palette(`palette') excel("`excelout'")
	if _rc==0 {
		noi dis in green "Figure 2....... Done"
		local ok = 1
	}
	else noi dis in red "Figure 2....... Not done"
	
	//Figure 6
	qui use `dataori', clear	
	cap pea_figure6 [aw=`wvar'], natw(`natwelfare') natp(`natpovlines') pppw(`pppwelfare') pppp(`ppppovlines') year(`year') fgtvars linesorted oneline(`oneline') onewelfare(`onewelfare') spells(`spells') comparability(`comparability') scheme(`scheme') palette(`palette') excel("`excelout'")
	if _rc==0 {
		noi dis in green "Figure 6....... Done"
		local ok = 1
	}
	else noi dis in red "Figure 6....... Not done"
	
	//Figure 7
	qui use `dataori', clear	
	cap pea_figure7 [aw=`wvar'], natw(`natwelfare') natp(`natpovlines') pppw(`pppwelfare') pppp(`ppppovlines') year(`year') fgtvars linesorted age(`age') male(`male') edu(`edu') scheme(`scheme') palette(`palette') excel("`excelout'")
	if _rc==0 {
		noi dis in green "Figure 7....... Done"
		local ok = 1
	}
	else noi dis in red "Figure 7....... Not done"

	//Figure 10
	qui use `dataori', clear	
	cap pea_figure6 [aw=`wvar'], c(`country') year(`year') fgtvars oneline(`oneline') onewelfare(`onewelfare') within(`within') welfaretype(`welfaretpye') scheme(`scheme') palette(`palette') excel("`excelout'")
	if _rc==0 {
		noi dis in green "Figure 10....... Done"
		local ok = 1
	}
	else noi dis in red "Figure 10....... Not done"
	
	//Final open	
	if `ok'==1 {
		shell start excel "`excelout'"
		noi dis in green "Tables and Graphs are done....... Loading the Excel file!"
	}
	else {
		noi dis in red "No tables and graphs are produced"
	}
end