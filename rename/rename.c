#include <dirent.h>
#include <errno.h>
#include <fcntl.h>
#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/syslimits.h> /* Defines PATH_MAX = 1024 */
#include <sys/types.h>
#include <unistd.h>

#define TRUE 1
#define FALSE 0
#define PATH_SIZE (PATH_MAX + 1)
#define BAD_CHAR ' '
#define GOOD_CHAR '_'

int rename_file(char *, char *);
int format_name(char *, char *);

int test = FALSE;

int main(int argc, char *argv[]) {
    char src[PATH_SIZE];
    char dst[PATH_SIZE];
    struct stat sb;
    struct dirent *e;
    DIR *dptr;
    char *f;
    int slen, i, ch;

    if ( argc == 2 ) {
	strlcpy(src, argv[1], PATH_SIZE);
    } else if ( argc == 3 ) {
	while ((ch = getopt(argc, argv, ":n")) != -1) {       
	    switch (ch) {
		case 'n': test = TRUE;
			  break;
		case '?': printf("bad arg\n");
			  exit(-1);
	    }
	}
	strlcpy(src, argv[2], PATH_SIZE);	
    } else {
	printf("bad args\n");
	exit(-1);
    }

    if (stat(src, &sb) < 0) {
	printf("stat error for %s: %s\n", argv[1], strerror(errno));
	exit(-1);
    }

    /* Regular file */
    if (S_ISREG(sb.st_mode) != 0) {
        if ((f = strrchr(src, '/')) != NULL)
	    f++;
	else
	    f = src;

	strlcpy(dst, dirname(src), PATH_SIZE);

	if (strlen(dst) == 1 && dst[0] == '.') {
	    dst[1] = '/';
	    dst[2] = '\0';
	} else {
	    dst[strlen(dst)] = '/';
	    dst[strlen(dst) + 1 ] = '\0';
	}

	if (format_name(f, dst) > 0 && rename_file(src, dst) != 0)
	    printf("%s doesn't contain bad chars\n", f);

	exit(0);
    }
    
    /* Directory */
    if (S_ISDIR(sb.st_mode) != 0) {
	slen = strlen(src);
        strlcpy(dst, src, PATH_SIZE);

	if ((dptr = opendir(src)) == NULL)
	    printf("Error opening %s: %s\n", src, strerror(errno));

	while ((e = readdir(dptr)) != NULL) {
	    if ( e->d_type != DT_REG )
		continue;

	    if (format_name(e->d_name, dst) > 0) {
		strlcat(src, e->d_name, PATH_SIZE);
		if (rename_file(src, dst) != 0) {
		    printf("Failure\n");
		}
	    }
	    src[slen] = '\0';
	    dst[slen] = '\0';
 	}
	exit(0);
    }

    printf("Error: input is neither file or directory\n");
    exit(-1);
}

int format_name(char *f, char *d) {
    int c = 0;
    int off = strlen(d);
    int i;

    for (i = 0; i < strlen(f); i++) {
        if (f[i] == BAD_CHAR) {
            d[i + off] = GOOD_CHAR;
            c++;
        } else {
            d[i + off] = f[i];
        }
    }
    d[i + off] = '\0';       
    return c;
}   

int rename_file(char *s, char *d) {
    struct stat sb;

    if (test) {
	printf("rename %s\t-->\t%s\n", s, d);
	return(0);
    }

    if ((stat(d, &sb)) == 0) {
	printf("Error: %s already exists\n", d);
	return -1;
    }
    
    if ((rename(s, d)) < 0) {
	printf("Error renaming %s: %s\n", s, strerror(errno));
	return -1;
    }

    return 0;
}
