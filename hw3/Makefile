mc : mc.l mc.y
	make clean 
	bison -d -b y mc.y
	flex mc.l
	gcc -o $@ y.tab.c lex.yy.c -ly -ll

.PHONY : 
	clean
clean :
	rm -rf *.tab.c *.tab.h *.yy.c mc *.output