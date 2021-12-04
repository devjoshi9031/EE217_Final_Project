all:
	gcc -g -std=gnu99 -o read_image read_image.c

clean:
	rm -rf read_image test_file.bmp string *.bmp
