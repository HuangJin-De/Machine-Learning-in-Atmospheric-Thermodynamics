###data processing assoicated package
import pickle
import glob
import numpy as np
import cv2
from pyspectral.rayleigh import Rayleigh
import netCDF4 as nc


#print('ext shape')
y = np.arange(-59.9975,60.0025,0.005)
x = np.arange(85.0025,205.0025,0.005)

local_lat = y[14000:20000]
local_lon = x[6000:11000]
print('lat',local_lat[0],local_lat[-1])
print('lon',local_lon[0],local_lon[-1])


fileband=sorted(glob.glob('*_band01.pkl'))
file_name = fileband[0]
date_name = file_name[0:12]
with open(fileband[0], 'rb') as f:
    band01= pickle.load(f)

fileband=sorted(glob.glob('*_band02.pkl'))
with open(fileband[0], 'rb') as f:
    band02= pickle.load(f)

fileband=sorted(glob.glob('*_band03.pkl'))
with open(fileband[0], 'rb') as f:
    band03= pickle.load(f)

fileband=sorted(glob.glob('*_band04.pkl'))
with open(fileband[0], 'rb') as f:
    band04= pickle.load(f)

filegeo=sorted(glob.glob('*_geo.pkl'))
with open(filegeo[0], 'rb') as f:
    hi_geo=pickle.load(f)
sun_az_map = hi_geo[0,:,:]
sun_zh_map = hi_geo[1,:,:]
sat_az_map = hi_geo[2,:,:]
sat_zh_map = hi_geo[3,:,:]

s_lon = 0
e_lon = 5000
s_lat = 0
e_lat = 6000
print(s_lat/2)

### resolution 1km
local_band01 = band01[int(s_lat/2):int(e_lat/2),int(s_lon/2):int(e_lon/2)]
local_band02 = band02[int(s_lat/2):int(e_lat/2),int(s_lon/2):int(e_lon/2)]
local_band04 = band04[int(s_lat/2):int(e_lat/2),int(s_lon/2):int(e_lon/2)]
### resolution 0.5km
local_band03 = band03[s_lat:e_lat,s_lon:e_lon]
# geo info
local_sun_az_map = sun_az_map[s_lat:e_lat,s_lon:e_lon]
local_sun_zh_map = sun_zh_map[s_lat:e_lat,s_lon:e_lon]
local_sat_az_map = sat_az_map[s_lat:e_lat,s_lon:e_lon]
local_sat_zh_map = sat_zh_map[s_lat:e_lat,s_lon:e_lon]

## resolution sharping (band01, 02, 04)
band011 = cv2.resize(local_band01, (5000, 6000), interpolation=cv2.INTER_LINEAR)
band022 = cv2.resize(local_band02, (5000, 6000), interpolation=cv2.INTER_LINEAR)
band033 = local_band03
band044 = cv2.resize(local_band04, (5000, 6000), interpolation=cv2.INTER_LINEAR)

local_rad = np.radians(local_sun_zh_map)
local_adjust = np.cos(local_rad)
# for Rayleigh correction
local_az_diff = local_sun_az_map-local_sat_az_map

print('local adjust')
band011 = band011/local_adjust
band022 = band022/local_adjust
band033 = band033/local_adjust
band044 = band044/local_adjust

band011[band011>100]=100
band022[band022>100]=100
band033[band033>100]=100
band044[band044>100]=100

hima = Rayleigh('Himawari-8', 'ahi')
print('Rayleigh correction')
refl_cor_band1 = hima.get_reflectance(local_sun_zh_map, local_sat_zh_map, local_az_diff, 'ch1',band033)
refl_cor_band2 = hima.get_reflectance(local_sun_zh_map, local_sat_zh_map, local_az_diff, 'ch2',band033)
refl_cor_band3 = hima.get_reflectance(local_sun_zh_map, local_sat_zh_map, local_az_diff, 'ch3',band033)

cor_band011 = band011-refl_cor_band1
cor_band022 = band022-refl_cor_band2
cor_band033 = band033-refl_cor_band3
print('hybrid green')
cor_bandgreen=0.93*cor_band022+0.07*band044

cor_bandgreen[cor_bandgreen<0]=0
cor_band011[cor_band011<0]=0
cor_band033[cor_band033<0]=0
print('image enhancement')
enh_band01 = (cor_band011/100)**(1/2)
enh_band02 = (cor_bandgreen/100)**(1/2)
enh_band03 = (cor_band033/100)**(1/2)

data = np.array([enh_band01,enh_band02,enh_band03])
rgb_array=np.zeros((6000,5000,3))
rgb_array[:,:,0]=data[2,:,:]
rgb_array[:,:,1]=data[1,:,:]
rgb_array[:,:,2]=data[0,:,:]

final_rgb = rgb_array
with open(''+ date_name +'_rgb.pkl', 'wb') as f:
     pickle.dump(rgb_array, f)
