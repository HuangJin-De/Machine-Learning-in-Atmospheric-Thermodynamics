import numpy as np


era=np.load('../data/era5.47918.zint_100.npy')
snd=np.load('../data/snd.47918.zint_100.npy')

print(era.shape)
print(snd.shape)

era=era.astype(np.float32)[:,0:4,:]
snd=snd.astype(np.float32)[:,0:4,:]

print(era.shape)
print(snd.shape)

era.tofile('../data/era.dat')
snd.tofile('../data/snd.dat')


