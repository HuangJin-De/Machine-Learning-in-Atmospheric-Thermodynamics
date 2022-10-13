###data processing assoicated package
import pickle
import numpy as np
import glob
import pickle
import cv2

#### East asia
#local_lon=x[6000:11000]
#local_lat=y[14000:20000]
#print(local_lon.shape)
#print(local_lat.shape)
#print(local_lon[0])
#print(local_lon[4999])
#print(local_lat[0])
#print(local_lat[5999])
lon_s = 6000
lon_e = 11000
lat_s = 14000
lat_e = 20000

unzip_file = sorted(glob.glob('*.bin'))
print(unzip_file[2])
print(unzip_file[3])
print(unzip_file[4])
print(unzip_file[5])
sat_az = np.fromfile(unzip_file[2],dtype='>f4')
sat_zh = np.fromfile(unzip_file[3],dtype='>f4')
sun_az = np.fromfile(unzip_file[4],dtype='>f4')
sun_zh = np.fromfile(unzip_file[5],dtype='>f4')
sun_az_map = sun_az.reshape((3000,3000))
sun_zh_map = sun_zh.reshape((3000,3000))
sat_az_map = sat_az.reshape((3000,3000))
sat_zh_map = sat_zh.reshape((3000,3000))

filetime=unzip_file[2]
year=filetime[0:4]  
mon=filetime[4:6]
day=filetime[6:8]
hr=filetime[8:10]
mn=filetime[10:12]
 
fin_sun_az_map= cv2.resize(np.single(sun_az_map), (24000, 24000), interpolation=cv2.INTER_LINEAR)
r_map = fin_sun_az_map[::-1]
local_sun_az_map=r_map[lat_s:lat_e,lon_s:lon_e]
del fin_sun_az_map,r_map
fin_sun_zh_map= cv2.resize(np.single(sun_zh_map), (24000, 24000), interpolation=cv2.INTER_LINEAR)
r_map = fin_sun_zh_map[::-1]
local_sun_zh_map=r_map[lat_s:lat_e,lon_s:lon_e]
del fin_sun_zh_map,r_map
fin_sat_az_map= cv2.resize(np.single(sat_az_map), (24000, 24000), interpolation=cv2.INTER_LINEAR)
r_map = fin_sat_az_map[::-1]
local_sat_az_map=r_map[lat_s:lat_e,lon_s:lon_e]
del fin_sat_az_map,r_map
fin_sat_zh_map= cv2.resize(np.single(sat_zh_map), (24000, 24000), interpolation=cv2.INTER_LINEAR)
r_map = fin_sat_zh_map[::-1]
local_sat_zh_map=r_map[lat_s:lat_e,lon_s:lon_e]
del fin_sat_zh_map,r_map
del sun_az_map,sun_zh_map,sat_az_map,sat_zh_map
del sun_az,sun_zh,sat_az,sat_zh

hi_geo=np.zeros((4,6000,5000))
hi_geo[0,:,:]=local_sun_az_map[:,:]
hi_geo[1,:,:]=local_sun_zh_map[:,:]
hi_geo[2,:,:]=local_sat_az_map[:,:]
hi_geo[3,:,:]=local_sat_zh_map[:,:]
 
with open(''+str(year)+''+str(mon)+''+str(day)+''+str(hr)+'' +str(mn)+ '_geo.pkl', 'wb') as f:
   pickle.dump(hi_geo, f)
del hi_geo,local_sun_az_map,local_sun_zh_map,local_sat_az_map,local_sat_zh_map
