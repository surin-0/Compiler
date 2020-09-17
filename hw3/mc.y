%{
    #include <stdio.h>
    #include <string.h>
    #include <stdlib.h>
    #include <stdbool.h>

    #define SYMBOL_MAX 10
    #define FUNC_NAME_MAX 20
    #define SYMBOL_TABLE_MAX 100
    #define LOCAL_TABLE_MAX 20
    #define FUNC_TABLE_MAX 100

    extern FILE* yyin;
    extern int yylex();
    extern int yyerror(char const *s);

    void initialize_symbol_table();
    void initialize_func_table();
    int find_symbol(char* target);
    int find_local(int index, char* target);
    int find_func(char* target);

    typedef struct symbol{
        char id[SYMBOL_MAX+1];
        double val;
    }SYMBOL;

    typedef struct Node{
        int t;
        union val{
            double real_constant;
            int integer_constant;
        }value;
        char symbol[11];
        struct Node* left;
        struct Node* right;
        struct Node* mid;
        struct Node* name;
    }NODE;

    typedef struct func{
        char id[FUNC_NAME_MAX + 1];
        SYMBOL local_table[LOCAL_TABLE_MAX];
        int arg_index[LOCAL_TABLE_MAX];
        int local_number;
        int arg_number;
        NODE* statement_list;
        double return_value;
        int alloc_argnum;
    }FUNC;

    SYMBOL symbol_table[SYMBOL_TABLE_MAX];
    FUNC func_table[FUNC_TABLE_MAX];
    int func_number = 0;
    int symbol_number = 0;
    int flag = 0;

    NODE* mkNode(int t, NODE* left, NODE* right, NODE* contidition);
    NODE* mkLeaf(int t, int ival, double dval, char*s);
    NODE* mkFunc(int t, NODE* name, NODE* arg, NODE* local, NODE* exe);
    double execute(NODE* root);
    void print_exp(NODE* root);
    void alloc_local(int index, NODE* left, NODE* mid);
    void alloc_arg(int index, NODE* arg);
    void save_var_list(int index, NODE* root, bool islocal);
%}

%union{
    struct Node* node;
    int ival;
    double dval;
    char symbol[11];
}

%token <symbol> ID
%token <ival> INT
%token <dval> REAL

%token IF WHILE PRINT
%token SEMICOLON
%token LP RP LEFT RIGHT
%token DEF LOCAL RETURN
%token COMMA

%nonassoc ELSE

%left GT GEQ LT LEQ EQ NEQ
%left PLUS MINUS
%left MUL DIV
%right ASSIGN
%nonassoc UMINUS

%type <node> program 
%type <node> fun_list fun_def decl
%type <node> stmt_list print_stmt control_stmt if_stmt while_stmt assign_stmt empty_stmt return_stmt
%type <node> var_list expr_list
%type <node> stmt block expr term factor variable 

%%
program:
                                    { }
    | program stmt                  {execute($2);}
    | program fun_list stmt         {execute($2); execute($3);}
    | program fun_list              {execute($2);}
    | error                         {printf("---line err\n");}
    ;

fun_list:
    fun_def fun_list    {$$ = mkNode(0, $1, $2, NULL);}
    | fun_def           {$$ = $1;}
    ;

fun_def:
    DEF variable LP expr_list RP LEFT decl stmt_list RIGHT  {$$ = mkFunc(21, $2, $4, $7, $8);}
    | DEF variable LP expr_list RP LEFT stmt_list RIGHT     {$$ = mkFunc(21, $2, $4, NULL, $7);}
    | DEF variable LP RP LEFT decl stmt_list RIGHT          {$$ = mkFunc(21, $2, NULL, $6, $7);}
    | DEF variable LP RP LEFT stmt_list RIGHT               {$$ = mkFunc(21, $2, NULL, NULL, $6);}
    ;

decl:
    LOCAL var_list SEMICOLON    {$$ = $2;}
    ;

stmt:
    expr SEMICOLON          {$$ = $1;}
    | empty_stmt            {$$ = $1;}
    | print_stmt SEMICOLON  {$$ = $1;}
    | assign_stmt SEMICOLON {$$ = $1;}
    | control_stmt          {$$ = $1;}
    | return_stmt SEMICOLON {$$ = $1;}
    | block                 {$$ = $1;}
    ;

empty_stmt:
    ';'     {$$ = NULL;}
    ;

print_stmt:
    PRINT expr              {$$=mkNode(1, $2, NULL, NULL);}
    ;

assign_stmt:
    variable ASSIGN expr    {$$ = mkNode(2, $1, $3, NULL);}
    | variable ASSIGN error {printf("---assign error\n"); $$ = mkNode(2, $1, NULL, NULL);}
    ;

control_stmt:
    if_stmt         {$$ = $1;}
    | while_stmt    {$$ = $1;}
    ;

if_stmt:
    IF factor stmt ELSE stmt    {$$ = mkNode(3, $3, $5, $2);}
    | IF error stmt ELSE stmt   {printf("---if_stmt error\n"); $$ = mkNode(3, $3, $5, NULL);}
    ;

while_stmt:
    WHILE factor stmt   {$$ = mkNode(4, $2, $3, NULL);}
    | WHILE error stmt  {printf("---while_stmt error\n"); $$ = mkNode(4, NULL, $3, NULL);}
    ;

return_stmt:
    RETURN expr     {$$ = mkNode(20, $2, NULL, NULL);}
    ;

stmt_list:
    stmt                {$$ = $1;}
    | stmt_list stmt    {$$ = mkNode(0, $1, $2, NULL);}
    ;

block:
    LEFT stmt_list RIGHT    {$$ = $2;}
    | LEFT stmt_list error  {yyerrok; yyclearin; printf("---missing RIGHT\n"); $$ = $2;}
    ;

expr:
    expr PLUS term              {$$ = mkNode(5, $1, $3, NULL);}
    | expr MINUS term           {$$ = mkNode(6, $1, $3, NULL);}
    | expr GT expr              {$$ = mkNode(7, $1, $3, NULL);}
    | expr GEQ expr             {$$ = mkNode(8, $1, $3, NULL);}
    | expr LT expr              {$$ = mkNode(9, $1, $3, NULL);}
    | expr LEQ expr             {$$ = mkNode(10, $1, $3, NULL);}
    | expr EQ expr              {$$ = mkNode(11, $1, $3, NULL);}
    | expr NEQ expr             {$$ = mkNode(12, $1, $3, NULL);}
    | MINUS expr %prec UMINUS   {$$ = mkNode(13, $2, NULL, NULL);}
    | variable LP expr_list RP  {$$ = mkNode(19, $1, $3, NULL);}
    | variable LP RP            {$$ = mkNode(19, $1, NULL, NULL);}
    | term                      {$$ = $1;}
    ;

expr_list:
    expr                    {$$ = $1;}
    | expr_list COMMA expr  {$$ = mkNode(0, $1, $3, NULL);}
    ;

var_list:
    variable                    {$$ = $1;}
    | var_list COMMA variable   {$$ = mkNode(0, $1, $3, NULL);}
    ;

term:
    term MUL factor     {$$ = mkNode(14, $1, $3, NULL);}
    | term DIV factor   {$$ = mkNode(15, $1, $3, NULL);}
    | factor            {$$ = $1;}
    ;

factor:
    LP expr RP  {$$ = $2;}
    | INT       {$$ = mkLeaf(16, $1, 0.0, NULL);}
    | REAL      {$$ = mkLeaf(17, 0, $1, NULL);}
    | variable  {$$ = $1;}
    | LP expr error {yyerrok; yyclearin; printf("---missing RP\n"); $$ = $2;}
    ;

variable:
    ID        {$$ = mkLeaf(18, 0, 0.0, $1);}
    ;

%%
int yyerror(char const *s)
{
    fprintf(stderr, "%s\n", s);
    return -1;
}

NODE* mkNode(int t, NODE* left, NODE* right, NODE* contidition)
{
    NODE* new = (NODE*)malloc(sizeof(NODE));
    new->t = t;

    (new->value).real_constant = 0.0;
    (new->symbol)[0] = '\0';
    new->left = left;
    new->right= right;
    new->mid = contidition;
    new->name = NULL;

    return new;
}

NODE* mkLeaf(int t, int ival, double dval, char*s)
{
    NODE* new = (NODE*)malloc(sizeof(NODE));
    new->t = t;

    if(t == 17)
        (new->value).real_constant = dval;
    else if(t == 16)
        (new->value).integer_constant = ival;
    else if (t==18)
        (new->value).integer_constant = find_symbol(s);
    else
        (new->value).real_constant = 0.0;

    if(s) strcpy(new->symbol, s);
    else (new->symbol)[0] = '\0';

    new->left = NULL;
    new->right = NULL; 
    new->mid = NULL;
    new->name = NULL; 

    return new;
}

NODE* mkFunc(int t, NODE* name, NODE* arg, NODE* local, NODE* exe)
{
    NODE* new = (NODE*)malloc(sizeof(NODE));
    new->t = t;

    (new->value).real_constant = 0.0;
    (new->symbol)[0] = '\0';

    new->name = name;
    new->mid = arg;
    new->left = local;
    new->right = exe;

    return new;
}

void initialize_symbol_table() 
{
	for(int i = 0; i < SYMBOL_TABLE_MAX; i++) {
		symbol_table[i].id[0] = '\0';
		symbol_table[i].val = 0.0;
	}
}

int find_symbol(char* target)
{
	for(int i = 0; i < symbol_number; i++) {
		// 일치하는 심볼을 찾은 경우
		if(strcmp(symbol_table[i].id, target) == 0)
			return i;
	}
	return -1;
}

int find_local(int index, char* target)
{
    if(index == -1)
        return -1;
    else{
        for(int i=0; i < func_table[index].local_number; i++){
            if(strcmp(func_table[index].local_table[i].id, target) == 0)
                return i;
        }
        return -1;
    }
}

void initialize_func_table()
{
    for(int i=0; i<FUNC_TABLE_MAX; i++)
    {
        func_table[i].id[0] = '\0';
        for(int j = 0; j<LOCAL_TABLE_MAX; j++){
            func_table[i].local_table[j].id[0] ='\0';
            func_table[i].local_table[j].val = 0.0;
            func_table[i].arg_index[j] = -1;
        }
        NODE* statement_list;
        func_table[i].local_number = 0;
        func_table[i].arg_number = 0;
        func_table[i].return_value = 0.0;
        func_table[i].alloc_argnum = 0;
    }
}

int find_func(char* target)
{
    for(int i = 0; i < func_number; i++){
        if(strcmp(func_table[i].id, target) == 0)
            return i;
    }
    return -1;
}

void print_exp(NODE* root)
{
    if(root->t == 16)
        printf("%d\n",(root->value).integer_constant);

    if(root->t == 17)
        printf("%lf\n",(root->value).real_constant);

    if(root->t == 18){
        int index = find_symbol(root->symbol);
        double val;
        if(index == -1){
            if(flag == -1){
                yyerror("syntax error : a variable whose value is not stored in symbol_table");
                return;
            }
            else{
                if(find_local(flag, root->symbol) == -1){
                    yyerror("syntax error : a variable whose value is not stored in symbol_table and local_table");
                    return;
                }
                else
                    val = func_table[flag].local_table[find_local(flag, root->symbol)].val;
            }
        }
        else
            val = symbol_table[index].val;

        if(val - (int)val == 0)
            printf("%d\n", (int)val);
        else   
            printf("%lf\n",val);
    }
}

void alloc_local(int index, NODE* left, NODE* mid)
{
    save_var_list(index, mid, false);
    save_var_list(index, left, true);
}

void save_var_list(int index, NODE* root, bool islocal)
{
    int count_local = func_table[index].local_number;
    int count_arg = func_table[index].arg_number;
    if(!root)
        return;

    if(root->t == 0){
        save_var_list(index, root->left, islocal);
        save_var_list(index, root->right, islocal);
    }
    else{
        if(islocal){
            if(find_symbol(root->symbol) != -1){
                yyerror("syntax error : already declared global variable");
                return;
            }
            strcpy(func_table[index].local_table[count_local].id, root->symbol);
            func_table[index].local_number++;
        }
        else{
            int argn = func_table[index].arg_number;
            strcpy(func_table[index].local_table[count_local].id, root->symbol);
            func_table[index].local_number++;
            func_table[index].arg_index[argn] = find_local(index, root->symbol);
            func_table[index].arg_number++;
        }
    }
}

void alloc_arg(int index, NODE* arg)
{
    int alloc_argnum = func_table[index].alloc_argnum;
    if(!arg)
        return;

    if(arg->t==0){
        alloc_arg(index, arg->left);
        alloc_arg(index, arg->right);
    }
    else{
        if(arg->t == 16){
            int val = (arg->value).integer_constant;
            int tmp_index = func_table[index].arg_index[alloc_argnum];
            func_table[index].local_table[tmp_index].val = val;
            func_table[index].alloc_argnum++;
        }
        else if(arg->t == 17){
            int tmp_index = func_table[index].arg_index[alloc_argnum];
            func_table[index].local_table[tmp_index].val = (arg->value).real_constant;
            func_table[index].alloc_argnum++;
        }
        else if(arg->t == 18){
            double val = symbol_table[find_symbol(arg->symbol)].val;
            int tmp_index = func_table[index].arg_index[alloc_argnum];
            func_table[index].local_table[tmp_index].val = (double)val;
            func_table[index].alloc_argnum++;
        }
        else    
            yyerror("syntax error : problem of argument");
    }
}

double execute(NODE* root)
{
    if(!root)
        return 0;

    switch(root->t){
        case 0 : 
            execute(root->left);
            execute(root->right);
            break;
        case 1 : 
            print_exp(root->left);
            break;
        case 2 :
        {   
            int index = find_symbol((root->left)->symbol);
            if(index == -1)
            {
                int local_index = find_local(flag, (root->left)->symbol);
                if(local_index != -1){
                    (func_table[flag].local_table[local_index]).val = (double)execute(root->right);
                }
                else{
                    strcpy(symbol_table[symbol_number].id, (root->left)->symbol);
                    symbol_table[symbol_number].val = (double)execute(root->right);
                    symbol_number++;
                }
            }
            else
                symbol_table[index].val = (double)execute(root->right);
            break;
        }
        case 3 :
            if(root->mid == NULL)   return 0;
            if(execute(root->mid))  execute(root->left);
            else execute(root->right);
            break;
        case 4 :
            while(execute(root->left)){
                execute(root->right);
            }
            break;
        case 5 :
            return execute(root->left) + execute(root->right);
        case 6 :
            return execute(root->left) - execute(root->right);
        case 7 :
            return execute(root->left) > execute(root->right);
        case 8 : 
            return execute(root->left) >= execute(root->right);
        case 9 :
            return execute(root->left) < execute(root->right);
        case 10 :
            return execute(root->left) <= execute(root->right);
        case 11 :
            return execute(root->left) == execute(root->right);
        case 12 :
            return execute(root->left) != execute(root->right);
        case 13 :
            return -execute(root->left);
        case 14 :
            return execute(root->left) * execute(root->right);
        case 15 :
        {
            double dv = (double)execute(root->right);
            if(dv == 0.0){
                yyerror("syntax error : divide by zero");
                return execute(root->left);
            }
            else
                return execute(root->left) / dv;
        }
        case 16 :
            return (root->value).integer_constant;
        case 17 :
            return (root->value).real_constant;
        case 18 :
            if(flag != -1){
                int local_index = find_local(flag, root->symbol);
                return func_table[flag].local_table[local_index].val;
            }
            else if(find_func(root->symbol) != -1)
                break;
            else
                return symbol_table[find_symbol(root->symbol)].val;   
        case 19 :
        {
            int index = find_func((root->left)->symbol);
            if(index == -1){
                yyerror("syntax error : a variable whose valuse is not stored in func_table");
                return 0;
            }
            else{
                if(root->right)
                    alloc_arg(index, root->right);
                    
                //execute
                flag = index;
                NODE* temp = func_table[index].statement_list;
                execute(temp);
                flag = -1;

                double result = func_table[index].return_value;
                if(result)
                    return result;
                break;
            }
        }
        case 20 :
        {
            if(flag == -1){
                yyerror("syntax error : you can only return in function");
                return 0;
            }
            else{
                double val = (double)execute(root->left);
                func_table[flag].return_value = val;
                break;
            }
        }
        case 21:
        {
            int index = find_func((root->name)->symbol);
            if(index == -1){
                strcpy(func_table[func_number].id, (root->name)->symbol);
                func_table[func_number].statement_list = root->right;
                alloc_local(func_number, root->left, root->mid);
                func_number++;
                break;
            }
            else{
                yyerror("syntax error: the name of the function that is already defined.");
                return 0;
            }
        }
        default :
            yyerror("syntax error!");
    }
    return 0;
}

int main(int argc, char* argv[])
{
    if(argc > 1)
    {
        FILE* file;
        file = fopen(argv[1], "r");
        if(!file)
        {
            fprintf(stderr, "could not open %s!\n", argv[1]);
            exit(1);
        }
        yyin = file;
    }
    flag = -1;
    initialize_func_table();
    initialize_symbol_table();
    yyparse();

    return 0;
}