all: hw2

hw2 : lex.yy.c
	gcc -o hw2 lex.yy.c -lfl

lex.yy.c: hw2.l 
	flex hw2.l

clean:
	rm hw2 lex.yy.c