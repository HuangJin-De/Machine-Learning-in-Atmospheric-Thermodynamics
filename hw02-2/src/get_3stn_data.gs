"reinit"
"set display color white"
"c"

date.1=00Z14JAN2018 
date.2=00Z09JAN2020

i=1
while(i<=2)

yr=substr(date.i,9,4)
mo=substr(date.i,6,3)

if (mo=JAN)
mo=01
endif

da=substr(date.i,4,2)

"sdfopen ../ERA5_EAsia_00z/ERA5_EAsia_hourly_"yr"_00Z.nc"

"set z 1 27"
"set time "date.i""

stn=47918
lon1=124.16
lat1=24.33

"set gxout fwrite"
"set fwrite era5_"stn"_"yr""mo""da".dat"

"set lon "lon1""
"set lat "lat1""

"d t*pow(1000/lev,2./7.)"
"d q"
"d u"
"d v"

"disable fwrite"


stn=47945
lon1=131.23
lat1=25.83

"set gxout fwrite"
"set fwrite era5_"stn"_"yr""mo""da".dat"


"set lon "lon1""
"set lat "lat1""

"d t*pow(1000/lev,2./7.)"
"d q"
"d u"
"d v"

"disable fwrite"


stn=47909
lon1=129.55
lat1=28.38

"set gxout fwrite"
"set fwrite era5_"stn"_"yr""mo""da".dat"

"set lon "lon1""
"set lat "lat1""

"d t*pow(1000/lev,2./7.)"
"d q"
"d u"
"d v"

"disable fwrite"

"close 1"

i=i+1
endwhile

