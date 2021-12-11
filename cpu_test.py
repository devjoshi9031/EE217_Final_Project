import numpy as np
import cv2
import os
import matplotlib.pyplot as plt
import time
# number of rows and columns taken to reconstruct the image.
recon_rank_1=100
recon_rank_2=250
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
    
    # Perform Singular value decomposition of the image
    A, S, At = np.linalg.svd(image.astype(np.float32), full_matrices=False)

    # Reconstruct the image using "recon_rank" number of rows and columns from U, S, and V matrices.
    ret_100 = A[:,:recon_rank_1] @ np.diag(S)[0:recon_rank_1, :recon_rank_1] @ At[:recon_rank_1,:]

    ret_250 = A[:,:recon_rank_2] @ np.diag(S)[0:recon_rank_2, :recon_rank_2] @ At[:recon_rank_2,:]

    check_point2 = time.time()
    total_time +=(check_point2-check_point1)
    print("Time taken to calculate SVD and reconstruct image for the file number " +str(file)+" is: "+str(check_point2-check_point1)+ ' secs')

    # Calculate the difference between the reconstructed image and original image.
    # diff_array = np.subtract(image, ret)

    # Plot both the figures side-by-side
    fig = plt.figure()
    
    ax1 = fig.add_subplot(1,3,1)
    img = ax1.imshow(ret_100, aspect='equal')
    img.set_cmap('gray')
    ax1.title.set_text('SVD Image: '+str(recon_rank_1))
    plt.axis('off')

    ax2 = fig.add_subplot(1,3,2)
    img = ax2.imshow(ret_250, aspect='equal')
    img.set_cmap('gray')
    ax2.title.set_text('SVD Image: '+str(recon_rank_2))
    plt.axis('off')

    ax3 = fig.add_subplot(1,3,3)
    img = ax3.imshow(image, aspect='equal')
    img.set_cmap('gray')
    ax3.title.set_text('Original Image')
    plt.axis('off')
    plt.savefig(os.path.join("./", str(list_of_images[file])), bbox_inches='tight', pad_inches = 0.2)
    plt.show()


print("Time taken to calculate SVD and reconstruct image for "+str(len(list_of_images))+" number of files is: "+str(total_time))