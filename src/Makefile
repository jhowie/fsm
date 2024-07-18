# Makefile for various bits of code...
#
CFLAGS=-DINDEX=strchr 
LIBS=-ll -lm
CC=cc
LEX=flex
YACC=bison
#
.c.o:
	$(CC) $(CFLAGS) -c $<

all:    spp san schk

clean:
	rm spp san schk *.o y.tab.h lex.yy.c states.tab.[ch]

spp:    main.o spp.o list.o states.tab.o lex.yy.o
	$(CC) -o spp main.o spp.o list.o states.tab.o lex.yy.o $(LIBS)

san:    main.o san.o list.o states.tab.o lex.yy.o
	$(CC) -o san main.o san.o list.o states.tab.o lex.yy.o $(LIBS)

schk:   main.o schk.o graph.o list.o states.tab.o lex.yy.o
	$(CC) -o schk main.o schk.o graph.o list.o states.tab.o lex.yy.o $(LIBS)

states.tab.o: states.tab.c states.h list.h
lex.yy.o: lex.yy.c states.tab.h
main.o: main.c states.h list.h states.tab.h
spp.o: spp.c states.h list.h states.tab.h
san.o: san.c states.h list.h states.tab.h
schk.o: schk.c states.h list.h states.tab.h graph.h
list.o: list.c list.h
graph.o: graph.c graph.h

states.tab.h: states.y
	$(YACC) -d states.y
	cp states.tab.h y.tab.h

states.tab.c: states.y
	$(YACC) -d states.y
	cp states.tab.h y.tab.h

lex.yy.c:       states.l
	$(LEX) states.l
