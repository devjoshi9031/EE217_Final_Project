# FILE: Run this script to transfer all the images that has 500 rows and 750 cols from "jpg" directory to "final_output_images" directory.

import cv2
import numpy as np
import os
import shutil

lib = os.listdir("./jpg/")

destination = "./final_output_images/"

for i in range(0,len(lib)):
    img = cv2.imread(os.path.join("./jpg/",str(lib[i])), 0)
    if((img.shape[0]==500) & (img.shape[1]==750)):
        shutil.move(os.path.join("./jpg/",str(lib[i])), os.path.join(destination, str(lib[i])))
        print(lib[i])