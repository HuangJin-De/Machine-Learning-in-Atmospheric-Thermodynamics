import numpy as np
import glob 
import pickle
import matplotlib.pyplot as plt

path='../../data/'
fileband=sorted(glob.glob(path+'2018*_rgb.pkl'))
file_name = fileband[0]
date_name = file_name[11:23]
with open(path+date_name+'_rgb.pkl', 'rb') as f:
    rgb_array =  pickle.load(f)#.astype(np.float32)
#print('ext shape')
y = np.arange(-59.9975,60.0025,0.005)
x = np.arange(85.0025,205.0025,0.005)

rgb_array = (255.*rgb_array).astype(np.short)

local_lat = y[14000:20000]
local_lon = x[6000:11000]

print(rgb_array.shape,y.shape)
np.savez_compressed(path+date_name+'_rgb.npz',rgb=rgb_array)

fileband=sorted(glob.glob(path+'2020*_rgb.pkl'))
file_name = fileband[0]
date_name = file_name[11:23]
with open(path+date_name+'_rgb.pkl', 'rb') as f:
    rgb_array =  pickle.load(f).astype(np.float32)

rgb_array = (255.*rgb_array).astype(np.short)
np.savez_compressed(path+date_name+'_rgb.npz',rgb=rgb_array)


#print('lat',local_lat[0],local_lat[-1])
#print('lon',local_lon[0],local_lon[-1])
#
#
#fig = plt.figure(figsize=(9,11)) 
#m = Basemap(llcrnrlon=115, urcrnrlon=140, llcrnrlat=10, urcrnrlat=40,resolution='i')
#m.drawcoastlines(linewidth=1.2,color='yellow',zorder=2)
#m.drawparallels(np.arange(10., 41., 5.), labels=[1, 0, 0, 0], linewidth=0, color='k', fontsize=18)
#m.drawmeridians(np.arange(115., 139., 5.), labels=[0, 0, 0, 1], linewidth=0, color='k', fontsize=18)
#m.imshow(rgb_array)
## ishigaki
#lon=124.2
#lat=24.3
#k=40
#plt.scatter(lon,lat,k,color='fuchsia',zorder=5)
#plt.tight_layout()

#plt.title(''+date_title+' local time 0800',fontsize=22)
#plt.savefig(''+date_title+'_lt08.png',dpi=400)

