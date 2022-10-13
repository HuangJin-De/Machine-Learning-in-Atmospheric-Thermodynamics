###data processing assoicated package
import pickle
import numpy as np
import glob

####EXT
#xdef 24000 linear 85.0025  0.005
#ydef 24000 linear -59.9975 0.005
x = np.arange(85.0025,205.0025,0.005)
y = np.arange(-59.9975,60.0025,0.005)
#### Taiwan ishigaki area
#local_lon=x[6700:8700]
#local_lat=y[16200:17200]

#### East asia
local_lon=x[6000:11000]
local_lat=y[14000:20000]
print(local_lon.shape)
print(local_lat.shape)
print(local_lon[0])
print(local_lon[-1])
print(local_lat[0])
print(local_lat[-1])

unzip_file = sorted(glob.glob('*_band03.dat'))
if np.array(unzip_file).size > 0:
 for i in range(0,1):
  print(unzip_file[i])
  tem_tir = np.fromfile(unzip_file[i],dtype='<f4')

  filetime=unzip_file[i]
  year=filetime[0:4]
  mon=filetime[4:6]
  day=filetime[6:8]
  hr=filetime[8:10]
  mn=filetime[10:12]
  print(year,mon,day,hr,mn)
 #print(np.array(unzip_file).size)

  tem_tir_map  = tem_tir.reshape((24000,24000))
  r_tem_tir_map = tem_tir_map[::-1]
  local_map=r_tem_tir_map[14000:20000,6000:11000]
  with open(''+str(year)+''+str(mon)+''+str(day)+''+str(hr)+'' +str(mn)+ '_band03.pkl', 'wb') as f:
          pickle.dump(local_map, f)

