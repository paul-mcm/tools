#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

/*
* Input is two integers (low, high).
* Output: integers between low and high
* incremented by 1 or -i <increment> arg.
* -r reverses output
* -s <delim> sets a delimiter ('\n' is default)
*/

#include <stdio.h>
#include <stdlib.h>

#define MAX 1000

int main(int argc, char *argv[])
{
    long long v1, v2, *low, *high;
    const char *errstr;
    int ch;
    char *sep = "\n";
    int incr = 1;
    bool reverse = false;

    if (argc < 1) {
	printf("Not enough args\n");
	exit (-1);
    }
    while ((ch = getopt(argc, argv, ":hi:rs:")) != -1) {
	switch (ch) {
	    case 'h': printf("usae prange [-hnr] [-i increment ] low high\n");
		exit(0);
	    case 'i': incr = strtonum(optarg, 1, MAX, &errstr);
		break;
	    case 'r': reverse = true;
		break;
	    case 's': sep = optarg;
		break;
	    case '?': printf("ignoring bad arg\n");
		exit(0);
            }
 	}

    v1 = strtonum(argv[ ((optind++)) ], 1, MAX, &errstr);
    v2 = strtonum(argv[optind], 1, MAX, &errstr);

    if (v1 == v2) {
	exit(0);
    } else if (v1 > v2) {
	high = &v1;
	low  = &v2;
    } else {
	high = &v2;
	low  = &v1;
    }

    if (! reverse ) {
	while (*low < *high) {
	    printf("%lld%s", *low, sep);
	    (*low) += incr;
	}
	printf("%lld\n", *low);
    } else {
	while (*high > *low) {
	    printf("%lld%s", *high, sep);
	    *high -= incr;
	}
	printf("%lld\n", *high);
    }
}
