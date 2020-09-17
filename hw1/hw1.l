%{
#define ID 1
#define INTEGER 2
#define DOUBLE 3
#define STRING 4
#define COMMENT 5
extern char* yylval;
int check_(char* id);
%}
blank [ \t\n]+
id [a-zA-Z_]([0-9a-zA-Z_]?)*
integer [-+]?[0-9]+
double [-+]?(([0-9]+)|([0-9]*\.[0-9]+))([eE][-+]?[0-9]+)?
string "\""([^\n\"\\]*(\\[.\n])*)*"\""
comments (\/\/([^(\n)])*)|(\/\*([^(\*\/)])*\*\/)
%%
{blank} ;
"int" {printf("<INT, >\t\t%s\n","int");}
"double" {printf("<DOUBLEKEY, >\t%s\n","double");}
"str" {printf("<STR, >\t\t%s\n","str");}
"if" {printf("<IF, >\t\t%s\n","if");}
"while" {printf("<WHILE, >\t%s\n","while");}
"return" {printf("<RETURN, >\t%s\n","return");}
{integer} {yylval = yytext; return INTEGER;}
{double} {yylval = yytext; return DOUBLE;}
{comments} {yylval = yytext; return COMMENT;}
{string} {yylval = yytext; return STRING;}
{id} {yylval = yytext; if(check_(yylval)==1) return ID; if(check_(yylval)==0) printf("%s === ERROR! only underscore!\n",yylval);}
\" {printf("<QUOTE, >\t%s\n","\"");}
\, {printf("<COMMA, >\t%s\n",",");}
\( {printf("<LPAREN, >\t%s\n","(");}
\) {printf("<RPAREN, >\t%s\n",")");}
\; {printf("<SEMICOLON, >\t%s\n",";");}
\{ {printf("<LEFT, >\t%s\n","{");}
\} {printf("<RIGHT, >\t%s\n","}");}
\+ {printf("<ADD, >\t\t+\n");}
\- {printf("<SUB, >\t\t-\n");}
\* {printf("<MUL, >\t\t*\n");}
\/ {printf("<DIV, >\t\t/\n");}
\= {printf("<TO, >\t\t=\n");}
\> {printf("<GT, >\t\t>\n");}
">=" {printf("<GEQ, >\t\t>=\n");}
\< {printf("<LT, >\t\t<\n");}
"<=" {printf("<LEQ, >\t\t<=\n");}
"==" {printf("<EQ, >\t\t==\n");}
"!=" {printf("<NEQ, >\t\t!=\n");}
. {ECHO; printf(" ===Error!\n");}
%%
char* yylval;
#include <stdio.h>
#include <string.h>
extern FILE* yyin;
extern int yylex();

int index_str = 0;
int index_sy = 0;
char* strings[100];
char* symbols[100];

int check_(char* id)
{
	int len = strlen(id);
	int i;
	for(int i = 0; i<len; i++)
	{
		if(id[i] != '_')
			return 1;
	}
	return 0;
}

int compare_str(char* str)
{
	int i;
	for(i = 0; i<index_str; i++)
	{
		if(strcmp(strings[i], str) == 0)
			return i+1;
	}
	strings[index_str] = malloc(sizeof(char)*(strlen(str)+1));
	strcpy(strings[index_str], yylval);
	return ++index_str;
}

int compare_sy(char* str)
{
	int i;
	for(i = 0; i<index_sy; i++)
	{
		if(strncmp(symbols[i], str, 16) == 0)
			return i+1;
	}
	symbols[index_sy] = malloc(sizeof(char)*17);
	strncpy(symbols[index_sy], yylval, 16);
	return ++index_sy;
}

int main(int argc, char* argv[])
{
	if(argc>1)
	{
		FILE* file;
		file = fopen(argv[1], "r");
		if(!file)
		{
			fprintf(stderr, "could not open %s!\n",argv[1]);
			exit(1);
		}
		yyin = file;
	}
	int tok;
	int i;
	printf("==========TOKEN LIST==========\n");
	printf("TOKEN\t\t%s\n","LEXEME");
	while((tok = yylex())!=0){
		if(tok == INTEGER)
		{
			int len = strlen(yylval);
			if(len > 10)	yylval = yylval + (len/10-1) + (len%10);
			if(yylval[0] == '0')
				printf("%s === ERROR! can't be started with 0!\n", yylval);
			else
				printf("<INTEGER, %s>\t%s\n",yylval,yylval);
		}
		if(tok == DOUBLE) printf("<DOUBLE, %s>\t%s\n",yylval,yylval);
		if(tok == COMMENT) printf("<COMMENT>\t%s\n",yylval);
		if(tok == STRING)
		{
			printf("<STRING, %d>\t%s\n",compare_str(yylval),yylval);
		}
		if(tok == ID)
		{
			int id = compare_sy(yylval);
			printf("<ID, %d>\t\t%s\n",id,symbols[id-1]);
		}
	}
	printf("==========SYMBOL TABLE==========\n");
	for(i = 0; i<index_sy; i++)
		printf("index = %d \t symbols = %s\n",i+1,symbols[i]);
	printf("==========STRING TABLE==========\n");
	for(i = 0; i<index_str; i++)
		printf("index = %d \t symbols = %s\n",i+1,strings[i]);
	return 0;
}
