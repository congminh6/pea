{smcl}
{* 10Nov2024}{...}
{hline}
help for {hi:pea table10}{right:November 2024}
{hline}

{title:Title}

{bf:pea table10} — Generates Poverty and Equity Analysis Tables

{title:Syntax}

{p 4 15}
{cmd: pea_table10}
[{cmd:if} {it:exp}] 
[{cmd:in} {it:exp}] 
[{cmd:,} 
{opt Country(string)} 
{opt Year(varname numeric)}
{opt Indicator(varname)} 
{opt excel(string)} 
{opt save(string)}]{p_end}

{title:Description}

{p 4 4 2}
{cmd:pea table10} calculates and generates tables of poverty and equity-related indicators for poverty analysis. It extracts data for specified countries and years, and produces a detailed table summarizing poverty and inequality measures, including poverty headcount ratio, income distribution, and equity indices. Results can be exported to Excel or saved in a specified file format.

{title:Options}

  {phang} {opt Country(string)} specifies the country code for which the poverty indicators are to be generated.
 
  {phang} {opt Year(varname numeric)} specifies the year variable for the analysis.

  {phang} {opt Indicator(varname)} specifies the specific indicator(s) to include in the analysis, such as poverty headcount or Gini index.
 
  {phang} {opt excel(string)} specifies the file path for exporting results to Excel. If omitted, results are saved to a temporary file.
 
  {phang} {opt save(string)} specifies the file path for saving intermediate data.

{title:Details}

{p 4 4 2}
{cmd:pea_table10} imports relevant poverty and equity datasets, extracts the country-specific and region-specific data for the selected year, and generates a table with:
  
	  - Poverty headcount ratios (e.g., at $1.90 and $3.20 poverty lines)
	  - Gini coefficients
	  - Theil indices
	  - Distributional indices like the Palma ratio
	  - Additional poverty and inequality measures with contextual information (e.g., inequality thresholds).

{p 4 4 2}
The final output is a comprehensive summary table ordered by the specified indicator(s), with results available for immediate reporting. Results can be exported to Excel if the `excel` option is used, or saved in a specified file format.


