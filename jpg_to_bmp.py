from PIL import Image
import os 
import re

path_to_jpeg = 'images/'

path_to_bmp = 'images_converted/'
bmp = ".bmp"

list_of_images = os.listdir(path_to_jpeg)

if(len(os.listdir(path_to_bmp)) == 0):
    exit
# print(list_of_images)
for file in range(0,len(list_of_images)):
    image = Image.open(os.path.join(path_to_jpeg, list_of_images[file])).convert('L')
    file_out = re.split("[*.]", list_of_images[file])[0]
    file_out += ".bmp"
    print(file_out)
    image.save(os.path.join(path_to_bmp, str(file_out)))



