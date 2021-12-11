all:
	gcc -g -std=gnu99 -o imageread imageread.c

clean:
	rm -rf imageread test_file.bmp string *.bmp
