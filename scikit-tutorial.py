# Needs pycuda and numpy version 1.19.4
# followed this https://github.com/jetson-nano-wheels/python3.6-pycuda-2021.1

import pycuda.autoinit
import pycuda.gpuarray as gpuarray
import numpy as np
import skcuda.cusolver as solver
import skcuda.linalg as linalg
import os 
import time
from PIL import Image
import cv2
import matplotlib.pyplot as plt


recon_rank=150
linalg.init()
path = "images/"
list_of_images = os.listdir(path)
print(list_of_images)
total_time = 0

for file in range(0,len(list_of_images)):
    image = cv2.imread(os.path.join(path,list_of_images[file]),0)
    img=image
    check_pt1 = time.time()
    a_gpu = gpuarray.to_gpu(np.array(img).astype(np.float32))

    U_d, s_d, V_d = linalg.svd(a_gpu)

    U = U_d.get()
    s = s_d.get()
    V = V_d.get()
    ret = U[:,:recon_rank] @ np.diag(s)[0:recon_rank, :recon_rank] @ V[:recon_rank, :]
    check_pt2 = time.time()
    total_time +=(check_pt2-check_pt1)
    print("Time taken to calculate SVD and recostruct image for the file " +str(file)+"is : "+str(check_pt2-check_pt1))
    
    
    # #   Plot both the figures side-by-side
    # fig = plt.figure()
    # ax1 = fig.add_subplot(1,2,1)
    # img = ax1.imshow(ret)
    # img.set_cmap('gray')
    # ax1.title.set_text('SVD with reconstruction using:'+str(recon_rank))
    # plt.axis('off')
    # ax2 = fig.add_subplot(1,2,2)
    # img = ax2.imshow(image)
    # img.set_cmap('gray')
    # ax2.title.set_text('Original Image')
    # plt.axis('off')
    # plt.show()

print("Time taken to calculate SVD and reconstruct image for "+str(len(list_of_images))+": "+str(total_time))

# print("printing U;" + str(U))



# print("Working fine")