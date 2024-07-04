#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define BUFF_MAX 256
int validate_ipv4(char *);

/* Return 0 for valid IPv4 addr; 1 for invalid addr */

int main(int argc, char *argv[]) {
        int r;
	char addr[BUFF_MAX];
	if (argc == 1) {		/* try to read from STDIN */
	    if ((r = read(0, addr, BUFF_MAX)) < 0) {
		printf("Read error: %s\n", strerror(errno));
		exit(1);
	    } else {
		addr[r - 1] = '\0';	/* replace '\n' w/ NULL */
	    }
	} else if (argc == 2) {
	    strlcpy(addr, argv[1], BUFF_MAX);
	} else {
	    printf("Invalid # of args\n");
	    return(1);
	}

        if ((r = validate_ipv4(addr)) == 0) {
	    printf("%s is valid\n", addr);
	    exit(r);
	} else {
	    printf("%s is invalid\n", addr);
	    exit(r);
	}
}

