import numpy as np
import cv2
import os
import matplotlib.pyplot as plt
import time
# number of rows and columns taken to reconstruct the image.
recon_rank=100
# Name of the folder that contains all the images.
path = 'images/'
# Get the name of all the files inside the folder in an array.
list_of_images = os.listdir(path)

# Run SVD for all the files inside a folder.
total_time = 0
for file in range(0,len(list_of_images)):

    check_point1 = time.time()
    # Get the image from the current directory and read it in grayscale.
    image = cv2.imread(os.path.join(path, list_of_images[file]),0)
    # Convert the coloured image into grayscale image
    # image = np.mean(image,-1)
    # Perform Singular value decomposition of the image
    U, S, V = np.linalg.svd(image, full_matrices=False)

    # Reconstruct the image using "recon_rank" number of rows and columns from U, S, and V matrices.
    ret = U[:,:recon_rank] @ np.diag(S)[0:recon_rank, :recon_rank] @ V[:recon_rank,:]

    check_point2 = time.time()
    total_time +=(check_point2-check_point1)
    print("Time taken to calculate SVD and reconstruct image for the file number " +str(file)+" is: "+str(check_point2-check_point1)+ 'secs')

    # Calculate the difference between the reconstructed image and original image.
    diff_array = np.subtract(image, ret)

    # Plot both the figures side-by-side
    fig = plt.figure()
    ax1 = fig.add_subplot(1,2,1)
    img = ax1.imshow(ret)
    img.set_cmap('gray')
    ax1.title.set_text('SVD with reconstruction using:'+str(recon_rank))
    plt.axis('off')

    ax2 = fig.add_subplot(1,2,2)
    img = ax2.imshow(image)
    img.set_cmap('gray')
    ax2.title.set_text('Original Image')
    plt.axis('off')
    plt.show()

print("Time taken to calculate SVD and reconstruct image for "+str(len(list_of_images))+" number of files is: "+str(total_time))