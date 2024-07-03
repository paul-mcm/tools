CC = clang
UNAME := $(shell uname)
#DEBUGFLAGS = -D DEBUG -g
INSTALL_DIR = $HOME/local/bin/
LIBDIR = ${HOME}/dev/lib/C/validate_ipv4
INCLUDES = ${LIBDIR}/include/

objects = ${HOME}/dev/lib/C/validate_ipv4/validate_ipv4.o

validate_ipv4.o:
	clang -fPIC -I${INCLUDES} -c -o validate_ipv4.o ${LIBDIR}/validate_ipv4.c

all: $(objects)
	$(CC) -I${INCLUDES} $(objects) -o validate_ipv4 validate_ipv4.c
clean:
	@rm -f $(objects)
