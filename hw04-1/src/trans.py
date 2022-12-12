import numpy as np
import matplotlib.pyplot as plt

filen='../data/ideal_inver_data.dat'

data=np.fromfile(filen,dtype=np.float32)
data=data.reshape(10,4,50)


print(data[9,0,:])
print(data[9,1,:])
print(data[9,2,:])
print(data[9,3,:])

np.savez('../idealized_profile.npz',th=data[:,0,:],T=data[:,1,:],RH=data[:,2,:],qv=data[:,3,:])


