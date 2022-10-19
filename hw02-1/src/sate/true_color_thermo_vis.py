###data processing assoicated package
import pickle
import numpy as np
import glob

###xdef 12000 linear 85.005  0.01
###ydef 12000 linear -59.995 0.01
x = np.arange(85.005,205.005,0.01)
y = np.arange(-59.995,60.005,0.01)
#### Taiwan and Ishigaki area
#print(x.shape)
#print(y.shape)
#local_lon=x[3350:4350]
#local_lat=y[8100:8600]
#print(local_lon.shape)
#print(local_lat.shape)

local_lon=x[3000:5500]
local_lat=y[7000:10000]
print(local_lon.shape)
print(local_lat.shape)
print(local_lon[0])
print(local_lon[-1])
print(local_lat[0])
print(local_lat[-1])



unzip_file_01 = sorted(glob.glob('*_band01.dat'))
unzip_file_02 = sorted(glob.glob('*_band02.dat'))
unzip_file_04 = sorted(glob.glob('*_band04.dat'))

file_exist = [np.array(unzip_file_01).size, np.array(unzip_file_02).size, np.array(unzip_file_04).size]
print(file_exist)
if file_exist[0] > 0:
  unzip_file = unzip_file_01
  print(unzip_file[0])
  bb = '01'
if file_exist[1] > 0:
  unzip_file = unzip_file_02
  print(unzip_file[0])
  bb = '02'
if file_exist[2] > 0:
  unzip_file = unzip_file_04
  print(unzip_file[0])
  bb = '04'
for i in range(0,1):
#print(unzip_file[1])
  tem_tir = np.fromfile(unzip_file[i],dtype='<f4')
#print(tem_tir.size)
  filetime=unzip_file[i]
  year=filetime[0:4]
  mon=filetime[4:6]
  day=filetime[6:8]
  hr=filetime[8:10]
  mn=filetime[10:12]
  print(year,mon,day,hr,mn)
 #print(np.array(unzip_file).size)

  tem_tir_map  = tem_tir.reshape((12000,12000))
  r_tem_tir_map = tem_tir_map[::-1]
  local_map=r_tem_tir_map[7000:10000,3000:5500]
  with open(''+str(year)+''+str(mon)+''+str(day)+''+str(hr)+'' +str(mn)+ '_band'+bb+'.pkl', 'wb') as f:
      pickle.dump(local_map, f)







