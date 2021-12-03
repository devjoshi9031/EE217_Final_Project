#include<stdio.h>
#include<stdlib.h>
#include<dirent.h>
#include<string.h>

#pragma pack(1)

//#define DEBUG
struct BITMAP_header {
    char name[2];
    unsigned int size;
    int garbage;
    unsigned int image_offset;
};

struct DIB_header{
    unsigned int header_size;
    unsigned int width;
    unsigned int height;
    unsigned short int colorplanes;
    unsigned short int bitsperpixel;
    unsigned int compression;
    unsigned int image_size;
    unsigned int temp[4];
};


void main(int argc, char* argv[]){
    FILE *fp;
    // DIR *d = opendir("/home/dev/EE217_Final_Project/images_converted/");
    // char *target_dir = "/home/dev/EE217_Final_project/images_from_c_files/";
    // char *final_dest[100];
    // if(d == NULL){
    //     printf("error in opening the directory\n");
    //     return;
    // }
    // int index=0;
    // struct dirent *dir;
    // while((dir = readdir(d)) != NULL){
    //     if(dir->d_type !=DT_DIR)
    //         printf("%s\n", dir->d_name);
    //     else
    //         printf("Else: %s\n", dir->d_name);
    
    
    // struct to hold the first header from the file.
    struct BITMAP_header header;
    // struct to hold the second header coming out from the file.
    struct DIB_header dibheader;

    // file pointer to hold the file IO.
    fp = fopen("/home/dev/EE217_Final_Project/images_converted/test4.bmp", "rb");
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
    
    for(int i=dibheader.height-1; i>=0; i--){
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
    FILE *fpw;
    fpw = fopen("/home/dev/EE217_Final_Project/images_from_c_files/test1.bmp", "w");
    if(fpw==NULL) return;
    
    // write the character 'B' & 'M' in the new file.
    fwrite(header.name, 2, 1, fpw);
    // write the rest of the first header file in the new BMP file.
    fwrite(&header.size, 3*sizeof(int), 1, fpw);
    // write the second header file in the new BMP file.
    fwrite(&dibheader, sizeof(struct DIB_header), 1, fpw);

    // Write the actual image data to a new BMP file.
    for( int i=dibheader.height-1; i>=0; i--)
        fwrite(&image_part[i], sizeof(unsigned char), dibheader.width, fpw);

    printf("File written successfully\n");
    fclose(fpw); 

    // close the file ptrs.

//    closedir(d);
       
    fclose(fp);
    return;
}