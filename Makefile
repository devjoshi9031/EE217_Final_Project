all:
	gcc -g -o read_image read_image.c

clean:
	rm -rf read_image test_file.bmp
