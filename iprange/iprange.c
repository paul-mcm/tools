#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iprange.h>

int main(int argc, char *argv[]) {	
	int r;
	struct cidr_ip_range addrs;

	if (argc != 2) {
	    printf("Bad args\n");
	    exit(-1);
        }

	strlcpy(addrs.ip, argv[1], 100);
	if ((r = ip_range(&addrs)) != 0) {
	    exit(-1);
	}

	printf("%s %s\n", addrs.low, addrs.high);
}
