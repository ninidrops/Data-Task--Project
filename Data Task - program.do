
* Import - database
clear
import delimited "C:\Users\lalyc\Desktop\Medicare_Advantage\scp-1205.csv"

*Changing names as required
ren v1 countyname
ren v2 state
ren v3 contract 
ren v4 healthplanname
ren v5 typeofplan
ren v6 countyssa
ren v7 eligibles
ren v8 enrolles
ren v9 penetration
ren v10 ABrate

destring eligibles, replace
replace eligibles=0 if ABrate ==.

destring enrolles, replace
replace enrolles=0 if enrolles==.

destring penetration, replace
replace penetration=0 if penetration==.

*dropping variables not needed

drop if countyname == "GUAM "
drop if state== "PR "

*creation of number numberofplans 1 & 2
*_________________________________________________________________

by countyname: gen rowno = _n
save data1.dta, replace
*___________________________________________________________________
gen aux1=1 if enrolles>10
collapse (sum) aux1, by(countyname)
gen rowno=1
save data2.dta, replace
*___________________________________________________________________
clear
use data1.dta
merge 1:m countyname rowno using data2
drop _merge
ren aux numberofplans1
save data2.dta, replace
*_____________________________________________________________________
clear
use data1.dta
gen aux1=1 if penetration>0.5
collapse (sum) aux1, by(countyname)
gen rowno=1
save data3.dta, replace
*_____________________________________________________________________
clear
use data2.dta
merge 1:m countyname rowno using data3
drop _merge
ren aux1 numberofplans2

**********************************************************************
*according to a quick search of the plans belonging to MA
*these are: HMO, PPO, PFFS, SNPS, so I will consider those plans for
*the creation of totalenrolles
sort countyname
by countyname: egen totalenrolles= total(enrolles) if (typeofplan=="HMO "| typeofplan=="PPO "|typeofplan=="PFFS ")

gen totalenrolles2 = totalenrolles if totalenrolles!=. & rowno==1
drop totalenrolles
ren totalenrolles2 totalenrolles


**********************************************************************
gen totalpenetration= 100*(totalenrolles/eligibles)

sort state countyname


*keeping only the final variables
keep countyname state numberofplans1 numberofplans2 countyssa eligibles totalenrolles totalpenetration

keep if totalpenetration!=.

save basefinal.dta, replace