{smcl}
{* 10Nov2024}{...}
{hline}
help for {hi:pea figure10b}{right:January 2025}
{hline}

{title:Title} 

{p 4 15}
{bf:pea figure10b} — Prosperity gap scatter (line-up). 

{title:Syntax}  

{p 4 15}  
{opt pea figure10b}  
	[{it:weight}]  
	[{opt if} {it:exp}]  
	[{opt in} {it:exp}]  
	[{opt ,}  
	{opt ONEWelfare(varname numeric)}  
	{opt Year(varname numeric)}  
	{opt Country(string)}  
	{opt BENCHmark(string)}  
	{opt NONOTES}  
	{opt scheme(string)}  
	{opt palette(string)}  
	{opt save(string)}  
	{opt excel(string)}]{p_end}  

{title:Description}  

{p 4 4 2}  
{opt pea figure10b} program generates scatter visualizations connecting GDP per capita and welfare gaps for insights into temporal poverty trends and cross-country comparisons.  

{title:Options}  

{p 4 4 2}  
{opt ONEWelfare(varname numeric)}:  
Specifies the numeric welfare variable, such as income, consumption, or wealth, for analysis.  

{p 4 4 2}  
{opt Year(varname numeric)}: 
Specifies the numeric variable indicating survey years or temporal intervals for visualization.  

{p 4 4 2}  
{opt Country(string)}:  
Specifies the name of the country or countries for scatter plot comparisons.  

{p 4 4 2}  
{opt BENCHmark(string)}:  
A list of benchmark comparison countries. These will be plotted in the visualization for comparative analysis.  

{p 4 4 2}  
{opt NONOTES}:  
Suppresses descriptive notes and annotations from the visualization.  

{p 4 4 2}  
{opt scheme(string)}:  
Specifies the visualization style (default options include visualization schemes like `viridis`, `rainbow`).  

{p 4 4 2}  
{opt palette(string)}:  
Defines a custom color scheme or palette for visual clarity.  

{p 4 4 2}  
{opt save(string)}:  
Specifies the file path to save the visualization results.  

{p 4 4 2}  
{opt excel(string)}:  
Exports the visualization results or statistics into Excel for further analysis or visualization sharing.  

{title:Examples}  

{p 4 4 2}
{bf: pea figure10b} [aw=weight_p], c(GNB) year(year) benchmark(CIV GHA GMB SEN) onewelfare(welfppp) 
