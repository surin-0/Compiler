%{
	#include <stdio.h>
	#include <string.h>
    #include <stdlib.h>
	#include <stdbool.h>

	#define TOKEN_LIST_MAX 100 
	#define TOKEN_VALUE_MAX 10
	#define SYMBOL_TABLE_MAX 100
	#define SYMBOL_MAX 16

	typedef enum { ID = 1, INT, REAL, PLUS, MINUS, MUL, DIV, ASSIGN, LP, RP } TOKEN; 

	typedef struct {
		TOKEN token;
		char value[TOKEN_VALUE_MAX+1];
	}TOKEN_LIST;

	typedef struct {
		char symbol[SYMBOL_MAX+1];
		bool visit;
		double value;
	}SYMBOL_TABLE;

	/* Variables */
	TOKEN_LIST token_list[TOKEN_LIST_MAX];			// 사이즈가 100인 토큰 리스트 배열
	SYMBOL_TABLE symbol_table[SYMBOL_TABLE_MAX];	// 사이즈가 100인 심볼 테이블 배열
	int token_number = 0;							// 토큰 리스트에 저장된 토큰의 수
	int symbol_number = 0;							// 심볼 테이블에 저장된 심볼의 수
	int flag = 0;

	/* Functions */
	void do_lexical_analysis();
	void yyerror(int type, char* );
	void initialize_symbol_table();
	bool is_symbol_duplicated(char* target);
	int find_symbol(char* target);
	void initialize_token_list(); 
	void print_token_list();
	void save_token(TOKEN token, char* value);
	void save_symbol(char* symbol);
%}
id [a-zA-Z_][a-zA-Z0-9_]*
integer [1-9][0-9]*
real (0|[1-9][0-9]*)\.(0|[0-9]*[1-9])
delim [ \t\r]
ws {delim}+
under_score [_]+
digit_first [0-9]+[a-zA-Z|0-9|_]+

%%
{ws}			;
"+"				{save_token(PLUS, "");}
"-"				{save_token(MINUS, "");}
"*"				{save_token(MUL, "");}
"/"				{save_token(DIV, "");}
"="				{save_token(ASSIGN, "");}

"("				{save_token(LP, "");}
")"				{save_token(RP, "");}

"\n"			{ /* 어휘 분석기를 종료 시킨다 */ return 0;}

{integer}		{save_token(INT, yytext);}
{real}			{save_token(REAL, yytext);}

{digit_first}	{flag = 1;}
{under_score}	{flag = 1;}
{id}			{save_symbol(yytext); save_token(ID, yytext);}
.				{flag = 1;}

%%

typedef struct node{
	int index;
    struct node* left;
    struct node* right;
	bool hasleft;
	bool hasright;
}NODE;

int expr_count;
int flag;

NODE* A();
NODE* Aprime(NODE* n);
NODE* E();
NODE* Eprime(NODE* n);
NODE* T();
NODE* Tprime(NODE* n);
NODE* F();
NODE* Fprime();

double calculator(NODE* tree);

void alloc(NODE* n, int index, NODE* left, NODE* right, bool l, bool r)
{
	n->index = index;
    n->left = left;
    n->right = right;
	n->hasleft = l;
	n->hasright = r;
}

NODE* syntax_tree;
double result;
bool isReal;

int main()
{
	initialize_symbol_table();			// 심볼 테이블을 초기화 한다.

	while(!feof(stdin)) {
		initialize_token_list();		// 토큰 리스트를 초기화 한다.	
		printf(">");					// 프롬프트를 출력한다.
		expr_count = token_number;
		flag = 0;
		isReal = false;
		do_lexical_analysis();			// 어휘 분석기를 호출한다.

		if(flag == 1){
			yyerror(1, "");
			continue;
		}
		
		syntax_tree = (NODE*)malloc(sizeof(NODE));
		alloc(syntax_tree, -1, NULL, NULL, 0, 0);

       	while(true)
       	{
			syntax_tree = A();
			if(syntax_tree == NULL)
				break;
           	if(token_list[expr_count].token == 0)
               	break;
       	}

		if(token_number == 0)
			continue;
        else if(flag == 3)
            yyerror(flag, "");
		else
			result = calculator(syntax_tree);

		if(flag == 0){
			if(isReal)	printf("%lf\n", result);
			else		printf("%d\n",(int)result);
		}
	}
	fclose(yyin);
	return 0;
}

void initialize_symbol_table() 
{
	for(int i = 0; i < SYMBOL_TABLE_MAX; i++) {
		symbol_table[i].symbol[0] = '\0';
		symbol_table[i].value = 0.0;
		symbol_table[i].visit = false;
	}
}

void initialize_token_list() 
{
	for(int i = 0; i < TOKEN_LIST_MAX; i++) {
		token_list[i].token = 0;
		token_list[i].value[0] = '\0';
	}
}

void do_lexical_analysis()
{
		yyin = stdin;
		yylex();
		yyrestart(yyin);
}

void yyerror(int type, char* e)
{
    switch(type)
    {
        case 1 : printf("error : lexical error\n");  break;
        case 2 : printf("error : %s는 정의되지 않음\n", e); flag = 2; break;
        case 3 : printf("error : syntax error\n");  break;
    }
}

void save_token(TOKEN token, char* value)
{
	token_list[token_number].token = token;
	strcpy(token_list[token_number].value, value);
	token_number++;
}

void save_symbol(char* symbol)
{
	// 심볼이 중복되지 않는 경우
	if(!is_symbol_duplicated(symbol)) {
		// 심볼 테이블에 저장
		strcpy(symbol_table[symbol_number].symbol, symbol);
		symbol_number++;
	}
}

bool is_symbol_duplicated(char* target)
{
	for(int i = 0; i < symbol_number; i++) {
		// 중복되는 경우
		if(strcmp(symbol_table[i].symbol, target) == 0)
			return true;
	}
	// 중복 안되는 경우
	return false;
}

int find_symbol(char* target)
{
	for(int i = 0; i < symbol_number; i++) {
		// 일치하는 심볼을 찾은 경우
		if(strcmp(symbol_table[i].symbol, target) == 0)
			return i;
	}
	return -1;
}

NODE* A()
{
    if(token_list[expr_count].token == ID)
    {
		NODE* new;
		new = (NODE*)malloc(sizeof(NODE));
		alloc(new, expr_count, NULL, NULL, 0, 0);
        expr_count++;
        return Aprime(new);
    }
    else{
		NODE* n = Fprime(); 
		NODE* m = Tprime(n);
		return Eprime(m);
    }
}

NODE* Aprime(NODE* n)
{
    if(token_list[expr_count].token == ASSIGN)
    {
		int index = expr_count;
		NODE* new;
		new = (NODE*)malloc(sizeof(NODE));
        expr_count++;
        NODE* m = A();
		alloc(new, index, m, n, 1, 1);
		return new;
    }
    else{
        NODE* m = Tprime(n);
		return Eprime(m);
    }
}

NODE* E()
{
    NODE* m = T();
    return Eprime(m);
}

NODE* Eprime(NODE* n)
{
    if(token_list[expr_count].token == PLUS){
		int index = expr_count;
        expr_count++;
        NODE* m = T();
        NODE* new;
		new = (NODE*)malloc(sizeof(NODE));
		alloc(new, index, n, m, 1, 1);
        return Eprime(new);
    }
	if(token_list[expr_count].token == MINUS){
		int index = expr_count;
        expr_count++;
        NODE* m = T();
        NODE* new;
		new = (NODE*)malloc(sizeof(NODE));
		alloc(new, index, n, m, 1, 1);
        return Eprime(new);
    }
    return n;
}

NODE* T()
{
    NODE* n = F();
    return Tprime(n);
}

NODE* Tprime(NODE* n)
{
    if(token_list[expr_count].token == MUL){
		int index = expr_count;
		expr_count++;
        NODE* m = F();
        NODE* new;
		new = (NODE*)malloc(sizeof(NODE));
		alloc(new,index, n, m, 1, 1);
        return Tprime(new);
    }
	if(token_list[expr_count].token == DIV){
		int index = expr_count;
		expr_count++;
        NODE* m = F();
        NODE* new;
		new = (NODE*)malloc(sizeof(NODE));
		alloc(new,index, n, m, 1, 1);
        return Tprime(new);
    }
    return n;
}

NODE* F()
{
    if(token_list[expr_count].token == ID){
		NODE* new;
		new = (NODE*)malloc(sizeof(NODE));
		alloc(new, expr_count, NULL, NULL, 0, 0);
        expr_count++;
		return new;
    }
    else{
		return Fprime();
	}
}

NODE* Fprime()
{
    if(token_list[expr_count].token == INT){
		NODE* new;
		new = (NODE*)malloc(sizeof(NODE));
		alloc(new, expr_count, NULL, NULL, 0, 0);
		expr_count++;
		return new;
	}
    else if(token_list[expr_count].token == REAL){
		NODE* new;
		new = (NODE*)malloc(sizeof(NODE));
		alloc(new, expr_count, NULL, NULL, 0, 0);
		expr_count++;
		return new;
	}
    else if(token_list[expr_count].token == LP){
        expr_count++;
        NODE* temp = E();
        if(token_list[expr_count].token == RP){
            expr_count++;
            return temp;
        }
        else{
			flag = 3;
			return NULL;
		}
    }
    else if(token_list[expr_count].token == MINUS){
		NODE* new;
		int index = expr_count;
        expr_count++;
        NODE* m = F();
		new = (NODE*)malloc(sizeof(NODE));
		alloc(new, index, m, NULL, 1, 0);
		return new;
    }
	flag = 3;
	return NULL;
}

double calculator(NODE* tree)
{
	int temp;
	switch(token_list[tree->index].token)
	{
		case INT :	return atoi(token_list[tree->index].value);
		case REAL :	isReal = true; return atof(token_list[tree->index].value);
		case PLUS :	return calculator(tree->left) + calculator(tree->right);
		case MINUS :
			if(tree->hasright == 0 && tree->hasleft == 1)	return calculator(tree->left)*(-1);
			else	return	calculator(tree->left) - calculator(tree->right);
		case MUL :	return calculator(tree->left) * calculator(tree->right);
		case DIV :	return calculator(tree->left) / calculator(tree->right);
		case ASSIGN :
			temp = find_symbol(token_list[tree->right->index].value);
			if(temp != -1){
				symbol_table[temp].visit = true;
				symbol_table[temp].value = calculator(tree->left);
			}
			return calculator(tree->right);
		case ID :
			temp = find_symbol(token_list[tree->index].value);
			if(symbol_table[temp].visit == false){
				yyerror(2, token_list[tree->index].value);
			}
			return symbol_table[temp].value;
		case LP : break;
		case RP : break;
		default : break;
	}
	return 0.0;
}
