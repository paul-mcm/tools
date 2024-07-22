CC = clang
UNAME := $(shell uname)
INSTALL_DIR = ${HOME}/local/bin

all: 
	$(CC) -o prange prange.c

install:
	@mkdir -p ${INSTALL_DIR}
	@mv prange ${INSTALL_DIR}
