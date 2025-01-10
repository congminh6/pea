{smcl}
{* 10Nov2024}{...}
{hline}
help for {hi:pea figure5}{right:January 2025}
{hline}

{title:Title}

{p 4 15}
{bf:pea figure5} — Decomposition of poverty changes: growth and redistribution: Huppi-Ravallion.

{title:Syntax}

{p 4 15}
{opt pea figure5} 
	[{it:if}]
	[{it:in}] 
	[{it:aw pw fw}], 
    [{opt onewelfare(varname numeric)} 
    {opt oneline(varname numeric)}  
    {opt spells(string)} 
    {opt year(varname numeric)} 
	{opt urban(varname numeric)}
	{opt LINESORTED(string)}
    {opt NONOTES}
	{opt comparability(varname numeric)}
	{opt setting(string)} 
    {opt save(string)}
    {opt excel(string)}
	{opt scheme(string)}
	{opt palette(string)}]{p_end}  


{title:Description}

{p 4 4 2}
{opt pea figure5} performs poverty decomposition over time using the Huppi-Ravallion method. 
The program generates visualizations and numerical results showing the contribution of changes in income or welfare across different 
time periods or population groups. The results can help analysts and policymakers identify the drivers behind changes in poverty.

{title:Options}

{p 4 4 2} 
{opt onewelfare(varname numeric)}: Specifies the numeric variable representing welfare (e.g., income or consumption) for poverty analysis. 

{p 4 4 2} 
{opt oneline(varname numeric)}: Specifies the numeric variable representing the poverty line used for comparison in the analysis.

{p 4 4 2} 
{opt spells(string)}: Defines time periods (spells) to perform the decomposition. Use pairs of years separated by a space, with multiple spells separated by semicolons (e.g., "2000 2005; 2005 2010").  

{p 4 4 2} 
{opt year(varname numeric)}: Specifies the numeric variable representing the year for time association in the analysis.

{p 4 4 2}
{opt urban(varname numeric)}: Urban/Rural classification variable for subgroup analysis.

{p 4 4 2} 
{opt LINESORTED(string)}:
Allows users to sort lines based on a specific setting for better visualization clarity.

{p 4 4 2} 
{opt NONOTES}: Suppresses the default notes added to the resulting graphs or figures. 

{p 4 4 2}
{opt comparability(varname numeric)}: Required. This variable denotes which survey rounds are comparable over time. 
Non-comparable survey rounds are not connected in figures. Example:	comparability(comparability).

{p 4 4 2}
{opt setting(string)}: Optional. If GMD option is specified, harmonized variables are created, and additional options (hhhead(), edu(), married(), school(), services(), assets(), hhsize(), hhid(), pid(), industrycat4(), lstatus(), and empstat()) do not need to be specified. 

{p 4 4 2} 
{opt save(string)} Specifies the file path for saving the processed data or results from the decomposition analysis. 

{p 4 4 2} 
{opt excel(string)} Specifies the file path for exporting results to an Excel file for further analysis or visualization purposes.  

{p 4 4 2} 
{opt  scheme(string)}:
Allows users to define a specific visualization color scheme.

{p 4 4 2} 
{opt  palette(string)}:
Specifies a custom color palette for use in visualizations.

{title:Examples}

{p 4 4 2} 
{bf: pea figure5} [aw=weight_p], year(year) onew(welfare) onel(natline) palette(viridis) spells(2018 2021) urban(urban)
