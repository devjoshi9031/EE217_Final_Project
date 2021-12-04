#include<stdio.h>
#include<stdlib.h>
#include<dirent.h>
#include<string.h>

#pragma pack(1)

//#define DEBUG
struct BITMAP_header {
    char name[2]; // Array to store 'B' & 'M' 
    unsigned int size;  // Size of the header file.
    int garbage;        // Not necessary information
    unsigned int image_offset;  // When will the exact pixel values start in bytes.
};

struct DIB_header{
    unsigned int header_size; // Size of DIB_Header
    unsigned int width;         // Width of the image
    unsigned int height;        // Height of the image
    unsigned short int colorplanes; // Which colorplanes
    unsigned short int bitsperpixel;    // How many bits we have per pixel.
    unsigned int compression;           // If the file has compression applied.
    unsigned int image_size;            // What is the actual image size.
    unsigned int temp[4];               // Not Necessary but required.
};


void main(int argc, char* argv[]){
    
    // pointer to hold the file pointer.
    FILE *fp;
    int i;
    // Get the directory pointer.
    /**
     * Change this directory to the directory that contaiins bmp converted image from jpg_to_bmp.py file"
     */
    DIR *d = opendir("./images_converted/");
    if(d == NULL){
        printf("error in opening the directory\n");
        return;
    }
    // Get the struct to read each file in the directory.
    struct dirent *dir;

    // Read from the directory one file at a time.
    while((dir = readdir(d)) != NULL){
        // This is to get the files from the directory were every image will be stored from the python file.
        /**
         * FILE_DIR: path from where we are reading the files.
         * TARGET_DIR: path where we are storing the files.
         * 1. Give proper path depending on your system. 
         *      -> for file_dir: run pwd in the directory where all the images are stored by the file "jpg_to_bmp.py" file.
         *      -> for target_dir: run pwd in the directory where you want the images to be stored by this .c file.
         */
        char file_dir[100] = "./images_converted/";
        char target_dir[100] = "./images_from_c_files/";

        // check if the current file read is file. 
        if(dir->d_type !=DT_DIR)
            printf("%s\n", dir->d_name);
        else
            continue;
    
    
    // struct to hold the first header from the file.
    struct BITMAP_header header;
    // struct to hold the second header coming out from the file.
    struct DIB_header dibheader;
    // file pointer to hold the file IO.
    strcat(&file_dir[0], dir->d_name);
    fp = fopen(file_dir, "rb");
    if(fp==NULL){
        printf("Error\n");
        exit(1);
    }
    // Read the first header from the bmp file.
    fread(&header, sizeof(header),1,fp);
    #ifdef DEBUG
    printf("first two things: %c%c\t size: %d\t image_offset: %d\n",header.name[0], header.name[1], header.size, header.image_offset);
    #endif
    // Read the second header from the bmp file.
    fread(&dibheader, sizeof(dibheader), 1, fp);
    #ifdef DEBUG
    printf("Header_size: %d\t Width of the image: %d\t Height of the image: %d\t colorplane: %d\t bitsperppixel: %d\t compression: %d\t image_size: %d\n", dibheader.header_size, dibheader.width, dibheader.height, dibheader.colorplanes, dibheader.bitsperpixel, dibheader.compression, dibheader.image_size);
    #endif

    // array to hold the actual image file.
    unsigned char image_part[dibheader.height][dibheader.width];
    
    for(i=dibheader.height-1; i>=0; i--){
        fread((&image_part[i]),sizeof(unsigned char),dibheader.width  , fp);
    }

    // To print the data we get from the image.
    #ifdef DEBUG
    for(int i=0; i<dibheader.height-1; i++){
        for(int j=0; j<dibheader.width; j++){
            printf("%d ", image_part[i][j]);
        }
        printf("\n");
    }
    #endif
    
    // WRITING THE IMAGE BACK TO A NEW FILE to check if we what we get is okay.
    strcat(&target_dir[0], dir->d_name);
    FILE *fpw;
    fpw = fopen(target_dir, "w");
    if(fpw==NULL) return;
    
    // write the character 'B' & 'M' in the new file.
    fwrite(header.name, 2, 1, fpw);
    // write the rest of the first header file in the new BMP file.
    fwrite(&header.size, 3*sizeof(int), 1, fpw);
    // write the second header file in the new BMP file.
    fwrite(&dibheader, sizeof(struct DIB_header), 1, fpw);

    // Write the actual image data to a new BMP file.
    for(i=dibheader.height-1; i>=0; i--)
        fwrite(&image_part[i], sizeof(unsigned char), dibheader.width, fpw);

    printf("File written successfully\n");
    fclose(fpw); 
        fclose(fp);
    }
    // close the file ptrs.

   closedir(d);
       

    return;
}