#include<stdio.h>
#include<stdlib.h>
#pragma pack(1)
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


void main(){
    FILE *fp;
    struct BITMAP_header header;
    struct DIB_header dibheader;
    char* string = "salu aa print thay che k nai e joi laie";
    fp = fopen("/home/dev/EE217_Final_Project/images_converted/test2.bmp", "rb");
    if(fp==NULL){
        printf("Error\n");
        exit(1);
    }
    fread(&header, sizeof(header),1,fp);
    printf("first two things: %c%c\t size: %d\t image_offset: %d\n",header.name[0], header.name[1], header.size, header.image_offset);
    fread(&dibheader, sizeof(dibheader), 1, fp);
    printf("Header_size: %d\t Width of the image: %d\t Height of the image: %d\t colorplane: %d\t bitsperppixel: %d\t compression: %d\t image_size: %d\n", dibheader.header_size, dibheader.width, dibheader.height, dibheader.colorplanes, dibheader.bitsperpixel, dibheader.compression, dibheader.image_size);

    unsigned char image_part[dibheader.height][dibheader.width];
    int fread_return=0, i;
    printf("for ni under gayu\n");
    for(i=dibheader.height-1; i>=0; i--){
        printf("fread_return: %d\n", fread_return);
        fread_return = fread((&image_part[i]),sizeof(unsigned char),dibheader.width  , fp);
        
    }
    // for(int i=0; i<dibheader.height-1; i++){
    //     for(int j=0; j<dibheader.width*3; j++){
    //         printf("%d ", image_part[i][j]);
    //     }
    //     printf("\n");
    // }
    
    // WRITING THE IMAGE BACK TO A NEW FILE.
    FILE *fpw;
    fpw = fopen("/home/dev/EE217_Final_Project/test_file.bmp", "w");
    int *p; 
    p = malloc(sizeof(int));
    *p = 5;
    if(fpw==NULL) return;
    fwrite(p, 4, 1, fpw);
    int r = fwrite(&header, sizeof(header),1,fpw);
    printf("%d\n", r);
    // fwrite(&header.size, 3*sizeof(int), 1, fpw);

    fwrite(&dibheader, sizeof(struct DIB_header), 1, fpw);

    for( int i=dibheader.height-1; i>=0; i++)
        fwrite(&image_part[i], sizeof(unsigned char), dibheader.width, fpw);
    fclose(fpw);    
    fclose(fp);
    return;
}