SOURCES=main.cpp
LDLIBS=-lGL -lGLU -lglut -lX11
BINNAME=tablet-tool # scripts use this
CFLAGS=-g

${BINNAME}: ${SOURCES}
	${CXX} ${SOURCES} -o ${BINNAME} ${LDLIBS} ${CFLAGS}
