"reinit"
"set display color white"
"c"


"sdfopen /data/dadm1/obs/OISST_v2/daily/sst.day.mean.2018.nc"
"sdfopen /data/C.mileshsieh/ERA5_EAsia_00z/ERA5_EAsia_hourly_2018_00Z.nc"

"set x 461 560"
"set y 401 520"

* 20180114
"set t 14"
"define a=lterp(sst,t.2(lev=950),aave)"
"define b=a+273.15-t.2(lev=950)"

"set fwrite ../data/lts_nss_data_20180114.dat"
"set gxout fwrite"
"d b"
"d t.2(lev=700)*pow(1000./700.,2./7.)-t.2(lev=1000)"
"d u.2(lev=925)"
"d v.2(lev=925)"
"disable fwrite"

"q dims"
say result

"close 2"
"close 1"

"sdfopen /data/dadm1/obs/OISST_v2/daily/sst.day.mean.2020.nc"
"sdfopen /data/C.mileshsieh/ERA5_EAsia_00z/ERA5_EAsia_hourly_2020_00Z.nc"

"set x 461 560"
"set y 401 520"

* 20180114
"set t 9"
"define a=lterp(sst,t.2(lev=950),aave)"
"define b=a+273.15-t.2(lev=950)"

"set fwrite ../data/lts_nss_data_20200109.dat"
"set gxout fwrite"
"d b"
"d t.2(lev=700)*pow(1000./700.,2./7.)-t.2(lev=1000)"
"d u.2(lev=925)"
"d v.2(lev=925)"
"disable fwrite"

