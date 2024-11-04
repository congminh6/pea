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

//Update data for many countries

cap program drop pea_dataupdate
program pea_dataupdate, rclass
	version 18.0
	syntax [if] [in] [aw pw fw], [datatype(string) pppyear(string) UPDATE]
		
	local persdir : sysdir PERSONAL	
	if "$S_OS"=="Windows" local persdir : subinstr local persdir "/" "\", all
	
	local datayear = real(substr("$S_DATE", -4, .))
	if "`pppyear'"=="" local pppyear 2017
	else local pppyear `=trim("`pppyear'")'
	
	local dl 0
	if "`update'"=="update" local dl 1
	else {	
		if "`datatype'"=="MPM" local returnfile "`persdir'pea/WLD_GMI_MPM.dta"
		else if "`datatype'"=="PIP" local returnfile "`persdir'pea/PIP_all_country.dta"
		else if "`datatype'"=="SCORECARD" local returnfile "`persdir'pea/Scorecard_country.dta"
		else if "`datatype'"=="LIST" local returnfile "`persdir'pea/PIP_list_name.dta"
		else if "`datatype'"=="UNESCO" local returnfile "`persdir'pea/UNESCO.dta"
		else if "`datatype'"=="CLASS" local returnfile "`persdir'pea/CLASS.dta"
		else {
			noi dis "`datatype' is not defined"
			exit 1
		}
		cap confirm file "`returnfile'"
		if _rc==0 {
			cap use "`returnfile'", clear	
			if _rc==0 {
				local dtadate : char _dta[version]			
				if (date("$S_DATE", "DMY")-date("`dtadate'", "DMY")) > 30 local dl 1
				else return local cachefile "`returnfile'"
			}
			else local dl 1
		}
		else {
			cap mkdir "`persdir'pea"
			local dl 1
		}
	}
	
	if `dl'==1 {
		//MPM DLW
		if "`datatype'"=="MPM" {
			cap dlw, country(WLD) type(GMI) year(`datayear') mod(MPM) files
			if _rc==0 {
				keep if ppp==`pppyear'
				if _N>0 {
					char _dta[version] $S_DATE		
					save "`persdir'pea/WLD_GMI_MPM.dta", replace
				}
				else {
					noi dis as error "No data is available for the requested PPP year, `pppyear'."
					exit `=_rc'
				}
			}
			else {
				noi dis as error "Unable to update MPM data from DLW"
				exit `=_rc'
			}			
		}
		
		//UNESCO
		if "`datatype'"=="UNESCO" {
			noi dis "Place holder only"
			*char _dta[version] $S_DATE
			*use "`persdir'pea/UNESCO.dta", clear	
		}
		
		//CLASS
		if "`datatype'"=="CLASS" {
			noi dis "Place holder only"
			*char _dta[version] $S_DATE
			*use "`persdir'pea/UNESCO.dta", clear	
		}
		
		//LIST country name and regions
		if "`datatype'"=="LIST" {
			cap pip tables, table(countries) clear
			if _rc==0 {
				ren country_code code
				replace region_code = africa_split_code if africa_split_code~=""
				save "`persdir'pea/PIP_list_name.dta", replace
			}
			else {
				noi dis "Unable to update country list from PIP"
				exit `=_rc'
			}
		}
		
		//PIP
		if "`datatype'"=="PIP" {
			clear
			tempfile gdppc codereglist povdata povben
			save `povben', replace emptyok
			
			//GDP https://data.worldbank.org/indicator/NY.GDP.PCAP.KD.
			pip tables, table(gdp) clear
			ren country_code code
			keep if data_level=="national"
			ren value gdppc
			char _dta[version] $S_DATE			
			save "`persdir'pea/PIP_all_GDP.dta", replace
			save `gdppc', replace
				
			//Income class, FCS etc
			
			//Country Pov data
			tempfile povdata1 povdata2 povdata3
			if `pppyear'==2017 local nlines 215 365 685
			
			local j = 1
			foreach line of local nlines {
				cap pip, country(all) year(all) ppp(`pppyear') povline(`=`line'/100') clear
				if _rc==0 {
					ren headcount headcount`line'
					drop if country_code=="CHN" & (reporting_level=="urban"|reporting_level=="rural")
					drop if country_code=="IND" & (reporting_level=="urban"|reporting_level=="rural")
					drop if country_code=="IDN" & (reporting_level=="urban"|reporting_level=="rural")
					keep country_code country_name year headcount`line' pg gini survey_acronym welfare_type
					save `povdata`j'', replace
					local j = `j' + 1
				}
				else {
					noi dis "Unable to update data from PIP"
					exit `=_rc'
				}
			}
			
			use `povdata1', clear
			merge 1:1 country_code year survey_acronym welfare_type using `povdata2', nogen keepus(headcount*)
			merge 1:1 country_code year survey_acronym welfare_type using `povdata3', nogen keepus(headcount*)
			
			gen code = country_code
			gen welfaretype= "CONS" if welfare_type==1
			replace welfaretype= "INC" if welfare_type==2
			for var headcount*: replace X = X*100
			
			merge m:1 code year using `gdppc', keepus(gdppc)
			drop if _merge==2
			drop _merge
			char _dta[version] $S_DATE			
			save "`persdir'pea/PIP_all_country.dta", replace
			
			//PIP lineup data
			tempfile povlineup	
			local j = 1
			foreach line of local nlines {
				cap pip, country(all) year(all) ppp(`pppyear') povline(`=`line'/100') clear fillgap
				if _rc==0 {
					ren headcount headcount`line'
					drop if country_code=="CHN" & (reporting_level=="urban"|reporting_level=="rural")
					drop if country_code=="IND" & (reporting_level=="urban"|reporting_level=="rural")
					drop if country_code=="IDN" & (reporting_level=="urban"|reporting_level=="rural")
					keep country_code year  headcount`line' pg   welfare_type
					save `povdata`j'', replace
					local j = `j' + 1
				}
				else {
					noi dis "Unable to update lineup data from PIP"
					exit `=_rc'
				}
			}
			
			use `povdata1', clear
			merge 1:1 country_code year  welfare_type using `povdata2', nogen keepus(headcount*)
			merge 1:1 country_code year  welfare_type using `povdata3', nogen keepus(headcount*)
			
			gen code = country_code
			gen welfaretype= "CONS" if welfare_type==1
			replace welfaretype= "INC" if welfare_type==2
			for var headcount*: replace X = X*100			
			char _dta[version] $S_DATE
			save "`persdir'pea/PIP_all_countrylineup.dta", replace
			
			//regional
			tempfile regional regdata
			local j = 1
			foreach line of local nlines {
				cap pip wb, region(all)  ppp(`pppyear') povline(`=`line'/100') clear
				if _rc==0 {
					ren headcount headcount`line'
					keep region_name region_code year  headcount`line' pg 
					save `povdata`j'', replace
					local j = `j' + 1
				}
				else {
					noi dis "Unable to update regional data from PIP"
					exit `=_rc'
				}
			}
			
			use `povdata1', clear
			merge 1:1 region_code year using `povdata2', nogen keepus(headcount*)
			merge 1:1 region_code year using `povdata3', nogen keepus(headcount*)
			for var headcount*: replace X = X*100
			char _dta[version] $S_DATE
			save "`persdir'pea/PIP_regional_estimate.dta", replace
		}
		
		//Scorecard
		if "`datatype'"=="SCORECARD" {
			noi dis "Place holder only"
			*char _dta[version] $S_DATE
			*save "`persdir'pea/CSC_atrisk2021.dta", replace
		}
	} //dl
end