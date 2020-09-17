%{
    #include <stdlib.h>
    #include <string.h>
    #include <stdio.h>
    #include "y.tab.h"

    YYSTYPE yylval;
    int yyerror(char*);
%}

id [a-zA-Z_][a-zA-Z0-9_]*
integer ([1-9][0-9]*|0)
real (0|[1-9][0-9]*)\.(0|[0-9]*[1-9])
delim [ \t\n]+
ws {delim}+
under_score [_]+
digit_first [0-9]+[a-zA-Z|0-9|_]+

%%
{ws}        ;
"+"         {return PLUS;}
"-"         {return MINUS;}
"*"         {return MUL;}
"/"         {return DIV;}
"="         {return ASSIGN;}
"("         {return LP;}
")"         {return RP;}
"{"         {return LEFT;}
"}"         {return RIGHT;}
";"         {return SEMICOLON;}
">"         {return GT;}
">="        {return GEQ;}
"<"         {return LT;}
"<="        {return LEQ;}
"=="        {return EQ;}
"!="        {return NEQ;}
"if"        {return IF;}
"else"      {return ELSE;}
"while"     {return WHILE;}
"print"     {return PRINT;}
"def"       {return DEF;}
"local"     {return LOCAL;}
"return"    {return RETURN;}
","         {return COMMA;}

{integer}   {yylval.ival = atoi(yytext); return INT;}
{real}      {yylval.dval = atof(yytext); return REAL;}

{digit_first}	{yyerror("lexical error");}
{under_score}	{yyerror("lexical error");}

{id}        {strcpy(yylval.symbol, yytext); return ID;}
.           {yyerror("lexical error");}
%%