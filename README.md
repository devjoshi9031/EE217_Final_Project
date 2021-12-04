# EE217_Final_Project
This repository will be used to implement SVD algorithm on a GPU Architecture.

# Purpose of the different files used in the project:
1. cpu_test.py: This file performs SVD on the images that are stored in "images/" directory. OUTPUT of the file is just how much time taken to perform SVD on the images and to reconstruct all the images.

It is very hard to read jpg file in a .c program, because of the lossy compression. Hence, all the images needs to be converted in bmp file, which is comparatively easy to read in .c file. 

2. jpg_to_bmp.py: This file converts all the .jpg files in .bmp files and also convert them in grayscale in-order for the .c file to read and operate on the data. IT will store the output images in images_converted folder. 

3. read_image.c: This is a C file that reads a bmp image and also stores the same image in another directory named "images_from_c_files/". This is just an experiment and the CUDA program to use SVD can be put in between reading and writing the image file to get suitable output. 

# DIRECTORIES:
1. images/ -> Actual images for the CPU version of SVD to operate upon.
2. images_converted/ -> Used by the jpg_to_bmp.py file to store the bmp files generated from .jpg files.
3. images_from_c_file/ -> Used by the read_images.c file to store the bmp files. 

# FlOW of executing files before running C files:
1. Make sure "images/" folder has .jpg files to operate on. 
2. Run jpg_to_bmp.py file.
3. Run read_image.c
