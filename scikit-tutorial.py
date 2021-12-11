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

# The nummber of rows and columns we will use to restore the image
recon_rank=100
# Initialize the scikit-cuda linear algebra library to solve for the SVD matrix.
linalg.init()
# path to read the images
path = "images/"
# Get the total images in the file in an array.
list_of_images = os.listdir(path)
#probably not needed because its python but just to make sure. 
total_cpu_time = 0
total_gpu_time = 0
print("Image no: \t CPU_TIME \t GPU_TIME \t Image_size\t Error_CPU \t Error_GPU \t Rank")
#for loop to iterate over the all the images in the directory.
for file in range(0,len(list_of_images)):

    #Read the image file in grayscale mode and put it in a numpy array.
    image = cv2.imread(os.path.join(path,list_of_images[file]),0)
    # can work without this but just to make sure.
    img=image
    # #CPU CODE FOR THE SVD.
    # checkpoint to start the performance counter for measuring cpu execution time.
    cpu_time1 = time.time()
    #Actually run the linear algebra Singular Value decomposition using the numpy library.
    A, S, At = np.linalg.svd(image.astype(np.float32), full_matrices=False)
    #reconstruct the image using a set of rows and columns from the output matrices.
    ret_cpu = A[:,:recon_rank] @ np.diag(S)[0:recon_rank, :recon_rank] @ At[:recon_rank, :]
    #stop the calculation for aggregrate cpu_time
    cpu_time2 = time.time()
    # calculate the rms error. 
    cpu_error = np.sqrt(np.mean(np.square(ret_cpu-image)))
    cpu_rate = (cpu_error/127)*100
    print("Error_rms: " +str(cpu_error)+ " Error_rate: " +str(cpu_rate))
    #add the current ET to total Exectution time for all the images.
    total_cpu_time += (cpu_time2-cpu_time1)    
    # #END OF CPU CODE.

    #GPU CODE FOR THE SVD.
    ## checkpoint to start the performance counter for measuring gpu execution time.
    gpu_time1 = time.time()
    # Change the input array from normal to floating point instructions and get the gpu array format.
    a_gpu = gpuarray.to_gpu(np.array(img).astype(np.float32))
    # This is pre-req from the library that the shape[1] cannot be less than shape[0]
    if(a_gpu.shape[1]<a_gpu.shape[0]):
        continue
    # Calculate SVD using the scikit-cuda library and in the backend use cusolver.
    U_d, s_d, V_d = linalg.svd(a_gpu, lib='cusolver')
    
    #reconstrcut the data matrix.
    U = U_d.get()
    s = s_d.get()
    V = V_d.get()
    ret = U[:,:recon_rank] @ np.diag(s)[0:recon_rank, :recon_rank] @ V[:recon_rank, :]
    gpu_time2= time.time()
    total_gpu_time +=(gpu_time2-gpu_time1)
    print("Image_no: "+str(file)+" CPU_time: " +str(cpu_time2-cpu_time1)+ " GPU_time: "+str(gpu_time2-gpu_time1)+ " Image_size: " +str(image.shape[0])+ "x" +str(image.shape[1]))
    
    
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

print("Total Images: " +str(len(list_of_images))+ " Total_cpu_time: " +str(total_cpu_time)+ " Total GPU Time: "+str(total_gpu_time))