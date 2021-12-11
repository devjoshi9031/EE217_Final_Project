#!/bin/bash

echo "Downloading the dataset of images"
wget https://www.robots.ox.ac.uk/~vgg/data/flowers/102/102flowers.tgz
echo "Extracting the tar file"
tar -xzf 102flowers.tgz jpg/
mkdir images_converted
mkdir final_output_images
echo "Running get_images_for_svd.py script"
python3 get_images_for_svd.py
ehco "Running cpu_and_gpu_final_svd.py"
python3 cpu_and_gpu_final_svd.py