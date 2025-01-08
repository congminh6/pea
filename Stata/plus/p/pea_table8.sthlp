{smcl}
{* 10Nov2024}{...}
{hline}
help for {hi:pea table8}{right:January 2025}
{hline}

{title:Title}

{p 4 15}
{bf:pea table8} — Generates core inequality indicators.

{title:Syntax}

{p 4 15}
{opt pea table8}
[{it:weight}] 
[{opt if} {it:exp}] 
[{opt in} {it:exp}] 
[{opt ,} 
{opt Welfare(varname numeric)} 
{opt Year(varname numeric)} 
{opt byind(varlist numeric)}
{opt CORE}
{opt setting(string)} 
{opt excel(string)} 
{opt save(string)} 
{opt MISSING}]{p_end}

{p 4 4 2}The command supports {opt aweight}s, {opt fweight}s, and {opt pweight}s. See {help weights} for further details.{p_end}

{title:Description}

{p 4 4 2}
{opt pea_table8} calculates core inequality indicators. Such as:

{p 4 4 2} - Gini index, Theil index, Palma (Kuznets) ratio, Atkinson index, Sen index, Watts index

{p 4 4 2} - Comparison of incomes across different percentiles (e.g., p10p50, p90p10, etc.)

{p 4 4 2} - GE(0), GE(1), GE(2)


{title:Options}

{p 4 4 2} 
{opt Welfare(varname numeric)}:
 specifies the welfare variable to be used for poverty dynamics calculations.
  
{p 4 4 2} 
{opt Year(varname numeric)}:
 specifies the year variable for the analysis.
 
{p 4 4 2} 
{opt byind(varlist numeric)}:
Geographic units for disaggregation, multiple entries allowed.

{p 4 4 2} 
{opt CORE setting(string)}:
 allows the use of custom settings for the analysis (e.g., regional specifications).
  
{p 4 4 2} 
{opt excel(string)}:
 specifies the file path for exporting results to Excel. If omitted, the results are saved to a temporary file.
  
{p 4 4 2} 
{opt save(string)}:
 specifies the file path for saving intermediate data.
  
{p 4 4 2} 
{opt MISSING}:
 enables the handling of missing data, allowing for custom handling of categorical variables.

{title:Example}

{p 4 4 2} 
{bf:pea_table8} [aw=weight_p], welfare(welfare) year(year) byind(urban) missing
