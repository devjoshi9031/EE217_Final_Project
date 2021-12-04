all:
	gcc -g -std=c99 -o read_image read_image.c

clean:
	rm -rf read_image test_file.bmp string *.bmp
