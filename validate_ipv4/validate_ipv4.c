#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int validate_ipv4(char *);

int main(int argc, char *argv[]) {      
        int r;
	char *addr;

        if (argc != 2) {
            printf("Bad args\n");
            exit(-1);
        }

        strlcpy(addr, argv[1], 100);

        if ((r = validate_ipv4(addr)) != 0) {
	    printf("Bad\n");
            exit(-1);
        } else {
	    printf("Good\n");
	}
}
