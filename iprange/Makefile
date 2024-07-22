CC = clang
UNAME := $(shell uname)
#DEBUGFLAGS = -D DEBUG -g
INSTALL_DIR = ${HOME}/local/bin/
LIBDIR = ${HOME}/dev/lib/C/iprange
INCLUDES = ${LIBDIR}/include/

objects = ${HOME}/dev/lib/C/iprange/iprange.o

iprange.o: iprange.h
	clang -fPIC -I${INCLUDES} -c -o iprange.o ${LIBDIR}/iprange.c

all: $(objects)
	$(CC) -I${INCLUDES} $(objects) -o iprange iprange.c

install:
	@mkdir -p ${INSTALL_DIR}
	@mv iprange ${INSTALL_DIR}
	@rm -f $(objects)

clean:
	@rm -f $(objects)
