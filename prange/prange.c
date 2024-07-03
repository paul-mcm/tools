#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

/*
* Input is two numbers (low, high),
* between 0 and 1000.
* Output: a space or newline delimited
* string (-n) of all numbers between 
* low and high.
*/

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    long long v1, v2, *low, *high;
    const char *errstr;
    int ch;
    char sep = ' '; /* may be set to '\n' */

    if (argc == 3) {
	v1 = strtonum(argv[1], 1, 1000, &errstr); 
	v2 = strtonum(argv[2], 1, 1000, &errstr);
    } else if (argc == 4) {
	while ((ch = getopt(argc, argv, ":s")) != -1) {
            switch (ch) {
                case 's': sep = '\n';
                          break;
                case '?': printf("ignoring bad arg\n");
                          break;
            }
	}
	v1 = strtonum(argv[2], 1, 1000, &errstr);
	v2 = strtonum(argv[3], 1, 1000, &errstr);
    } else {
	printf("Invalid args\n");
	exit(-1);
    }

    if (v1 == v2) {
	exit(0);
    } else if (v1 > v2) {
	high = &v1;
	low  = &v2;
    } else {
	high = &v2;
	low  = &v1;
    }

    while (*low <= *high) {
	printf("%lld%c", *low, sep);
	(*low)++;
    }
}
