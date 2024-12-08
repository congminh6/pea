{smcl}
{* 10Nov2024}{...}
{hline}
help for {hi:pea}{right:November 2024}
{hline}

{title:Title}

{bf:pea table3} — Generate detailed poverty and welfare analysis tables with specified parameters.


{title:Syntax}

{p 4 15}
{opt  pea table3}
	[{it:weight}] 
	[{opt if} {it:exp}] 
	[{opt in} {it:exp}] 
	[{opt ,}  
	{opt Country(string)} 
    {opt NATWelfare(varname)}
	{opt NATPovlines(varlist)} 
    {opt PPPWelfare(varname)} 
	{opt PPPPovlines(varlist)} 
    {opt FGTVARS}
	[opt using} {it:string}] 
    {opt Year(varname)} 
	{opt CORE} 
	{opt setting(string)} 
    {opt LINESORTED} 
	{opt excel(string)} 
	{opt save(string)} 
    {opt ONELine(varname)} 
	{opt ONEWelfare(varname)} 
    {opt MISSING} 
	{opt age(varname)}
	{opt male(varname)} 
    {opt hhhead(varname)}
	{opt edu(varname)}]{p_end}

{p 4 4 2}The command supports {opt aweight}s, {opt fweight}s, and {opt pweight}s. See {help weights} for further details.{p_end}

{title:Description}

{p 4 4 2}  
{opt pea table3} generates a detailed table that provides poverty and welfare statistics based on both 
    national and international poverty lines, as well as specified welfare measures. It also enables subgroup analysis 
    by age, gender, household head status, and education level. Additionally, it supports exporting results to Excel 
    and saving them in Stata format.

{title:Options}

{p 4 4 2} 
{opt Country(string)} specifies the country code or name for the analysis.
    
{p 4 4 2} 
{opt NATWelfare(varname)} is the variable containing national welfare values for analysis, such as income or consumption.

{p 4 4 2} 
{opt NATPovlines(varlist)} lists the national poverty lines to be used for poverty analysis.
    
{p 4 4 2} 
{opt PPPWelfare(varname)} is the welfare variable adjusted for purchasing power parity (PPP), typically for international comparisons.
    
{p 4 4 2} 
{opt PPPPovlines(varlist)} lists the PPP-adjusted poverty lines.
    
{p 4 4 2} 
{opt FGTVARS} generates Foster-Greer-Thorbecke (FGT) poverty indices, including headcount, poverty gap, and squared poverty gap.

{p 4 4 2} 
{opt using(string)} specifies the dataset to use for the analysis.
    
{p 4 4 2}
{opt Year(varname)} is the variable indicating the year for each observation.
    
{p 4 4 2} 
{opt CORE} enables the calculation of World Bank's Multidimensional Poverty Measure (MPM) for the specified {opt  Country} and {opt  Year}.
    
{p 4 4 2} 
{opt setting(string)} specifies the core setting to be used for the MPM calculation.
    
{p 4 4 2} 
{opt LINESORTED} indicates that the poverty lines are already sorted and skips internal sorting for efficiency.
    
{p 4 4 2} 
{opt excel(string)} specifies an Excel file for saving the results. If this option is not specified, a temporary file is used by default.

{p 4 4 2} 
{opt save(string)} specifies a file path to save the generated table in Stata dataset format.

{p 4 4 2} 
{opt ONELine(varname)} is the poverty line variable for calculating additional poverty statistics.

{p 4 4 2} 
{opt ONEWelfare(varname)} is the welfare variable associated with the {opt ONELine} poverty line.

{p 4 4 2} 
{opt MISSING} handles missing data in key demographic variables like age, gender, and education.

{p 4 4 2} 
{opt age(varname)} specifies the variable representing age groups for subgroup analysis.

{p 4 4 2} 
{opt male(varname)} specifies the variable representing gender (typically 1 for male, 0 for female).

{p 4 4 2} 
{opt hhhead(varname)} specifies the variable indicating household head status (typically 1 for head, 0 for non-head).

{p 4 4 2} 
{opt edu(varname)} specifies the variable indicating education level for subgroup analysis.

{title:Remarks}

{p 4 4 2}
The {opt  pea_table3} command performs poverty and welfare analysis based on a range of national and 
    international measures. It includes subgroup analysis by variables such as age, gender, education, and household head status. 
    The output table includes poverty headcount, poverty gap, poverty severity, welfare means, and inequality indices such as 
    the Gini index. It can be used to generate summary statistics and break down welfare measures by specific subgroups. 
    If the MPM option is used, it calculates the multidimensional poverty measure based on the World Bank’s framework.

    {pstd} Missing data in the core demographic variables can be handled and cleaned using the `MISSING` option to ensure accurate results.

{title:Examples}

{p 4 4 2}
Basic usage with national welfare and poverty lines, and subgroups by age and gender:
    
	{phang2}
	pea_table3, Country("GHA") NATWelfare(income) NATPovlines(200 400) PPPWelfare(ppp_income) PPPPovlines(150 250) FGTVARS using("data.dta") Year(year) MISSING age(age_group) male(gender)

{p 4 4 2}
Run the command with results saved to both Excel and Stata formats:
    
	{phang2}
	pea_table3, Country("GHA") NATWelfare(income) NATPovlines(200 300) PPPWelfare(ppp_income) PPPPovlines(150 250) FGTVARS using("data.dta") Year(year) excel("poverty_results.xlsx") save("poverty_output.dta")

{p 4 4 2}
Run the command with subgroup analysis by education and household head status:
    
	{phang2}
	pea_table3, Country("GHA") NATWelfare(income) NATPovlines(250 350) PPPWelfare(ppp_income) PPPPovlines(180 220) FGTVARS using("data.dta") Year(year) edu(education) hhhead(head_status)

