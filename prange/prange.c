#include <stdlib.h>
#include <stdio.h>

/*
* Input is two numbers (low, high),
* between 0 and 1000.
* Output:  a space delimited string
* of all numbers between low and high.
*/

#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
    long long v1, v2, *low, *high;
    const char *errstr;

    if (argc < 3) {
	printf("Wrong number of args\n");
	exit(-1);
    }

    v1 = strtonum(argv[1], 1, 1000, &errstr);
    v2 = strtonum(argv[2], 1, 1000, &errstr);

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
	printf("%lld ", *low);
	(*low)++;
    }
}
	
   
