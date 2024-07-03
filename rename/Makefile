CC = clang
INSTALL_DIR = ${HOME}/local/bin/

all:
	$(CC) -o rename rename.c

install:
	@mkdir -p ${INSTALL_DIR}
	@cp rename ${INSTALL_DIR}

clean:
	@rm -f rename
