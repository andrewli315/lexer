/*
    Topic: Homework1 for Compiler Course
    Deadline: xxx.xx.xxxx
*/

%{

/*  Definition section */

/*  insert the C library and variables you need */

    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>

/*
    Symbol table function

    TAs create the basic function which you have to fill.
    We encourage you define new function to make the program work better.
    However, the four basic functions must be finished.
*/
    typedef struct SYMBOL_TABLE{
        int index;
        char *id;
        char *type;
        struct SYMBOL_TABLE* next;
    }symbol_table;
    void create_symbol();
    void insert_symbol();
    int lookup_symbol();
    void dump_symbol();
    void insert_node(symbol_table*);
    void count_line();
    symbol_table* recent_node();
    symbol_table* create_node(char*,char*);
    int linenum = 0;

    symbol_table *root;
    int node_index = 0;
    int line =0;

%}

/*  define regular expression label */
letter                      [a-zA-Z]
digit                       [0-9]
id                          {letter}+({letter}|{digit})*
type_int                    [iI][nN][tT]+{ws}*
type_double                 [dD][oO][uU][bB][lL][eE]+{ws}*
func_print                  [pP][rR][iI][nN][tT]
w_while                     [wW][hH][iI][lL][eE]
w_if                        [iI][fF]
w_else                      [eE][lL][sS][eE]
ws                          [ \t]
op                          [+\-*/]
relat                       [><]|[==]|[>=]|[<=]

%%

 /* Rules section */
{type_int}+{id}             {create_symbol();}
{type_double}+{id}          {create_symbol();}
{func_print}                {printf("%s \t PRINT FUNCTION \n",yytext);  /* C action code */ ;}
{w_while}                   {printf("%s \t WHILE FUNCTION \n",yytext);}
{w_if}                      {printf("%s \t IF \n",yytext);}
{w_else}                    {printf("%s \t ELSE \n",yytext);}
{op}                        {printf("%s \t OPERATOR \n",yytext);}
"="                         {printf("%s \t ASSIGN \n",yytext);}
"("                         {printf("%s \t LB \n",yytext);}
")"                         {printf("%s \t RB \n",yytext);}
{relat}                     {printf("%s \t RELATIONAL \n",yytext);}
";"                         {printf("%s \t SEMICOLON \n",yytext); }
","                         {printf("%s \t COMMA \n",yytext);}
"{"                         {printf("%s \t LCB \n",yytext);}
"}"                         {printf("%s \t RCB \n",yytext);}
"%"                         {printf("%s \t REMAINDER \n",yytext);}
"^"                         {printf("%s \t EXPONETNTIAL \n",yytext);}
"\""                {
                        printf("\" \t QUOTATION\n");
                        char c;
                        while((c =input()) != '\"' && c!= EOF)
                        {
                            putchar(c);
                        }
                        printf(" \t STRING\n");
                        printf("\" \t\n");
                    }

"/*"                        {

                                char c;
                                printf("%s",yytext);
                                for ( ; ; )
                                {
                                    while ( (c = input()) != '*' && c != EOF )
                                    {
                                        if(c == '\n')
                                            count_line();
                                        if((int)c >= 32 || c=='\n')
                                        putchar(c);

                                    }
                                    if ( c == '*' )
                                    {
                                        putchar(c);
                                        while ( (c = input()) == '*' )
                                        {
                                            printf("*");
                                        }
                                        if ( c == '/' )
                                        {
                                            putchar(c);
                                            printf(" \t COMMENT\n");
                                            break;
                                        }
                                    }
                                    if ( c == EOF )
                                    {
                                        printf( "EOF in comment" );
                                        break;
                                    }
                                }
                            }
"//"                        {
                                char c = '\0';
                                printf("%s",yytext);
                                while(c != '\n')
                                {
                                    while ( (c = input()) != '\n' && c != EOF )
                                    {
                                        if((int)c >= 32)
                                            putchar(c);
                                    }
                                    if ( c == EOF )
                                    {
                                        printf( "EOF in comment" );
                                        break;
                                    }
                                }
                                count_line();
                                printf(" \t COMMENT\n");
                            }
                            
{id}                {printf("%s \t ID \n",yytext); }
{digit}+            {printf("%s \t NUMBER \n",yytext);}
{digit}+"."+{digit} {printf("%s \t FLOATNUMBER \n",yytext);}
[\n]                {count_line();}
{ws}                {;}

%%

/*  C Code section */

/*  You have to define your C function in this section */

int main(int argc,char *argv[]){
    
    root = create_node("","");

    yyin = fopen(argv[1],"r");
    yylex();

    printf("\nParse over, the line number is %d\n", line);
    dump_symbol();

    return 0;
}

int yywrap(void) {
    return 1;
}

void create_symbol(){
    symbol_table* node;
    char pch[100];
    char type[100];
    char* temp;
    temp = strtok(yytext," ");
    strcpy(type,temp);
    while(temp != NULL)
    {
        temp = strtok (NULL," ");
        strcpy(pch,temp);
        break;
    }

    if(lookup_symbol(pch) == 0)
    {
        node = create_node(type,pch);
        printf("%s \t %s TYPE VAR\n", pch,type );
        printf("Create a symbol table\n");
        insert_symbol(pch,node);
    }
    else
        return;
}

void insert_symbol(char* s,symbol_table* node){
    printf("Insert a symbol:%s\n",s);
    insert_node(node);

}

int lookup_symbol(char* sym){
    symbol_table* temp;
    temp = root;
    while(temp->next != NULL)
    {
        if(strcmp(temp->id,sym) == 0 )
        {
            return temp->index;
        }
        temp = temp->next;  
    }
    return 0;
}

void dump_symbol(){
    printf("\nThe symbol table dump:\n");
    symbol_table* temp;
    temp = root->next;
    while(temp != NULL)
    {
        printf("%d \t %s \t %s\n", temp->index,temp->id,temp->type);
        temp = temp->next;  
    }

}
symbol_table* create_node(char* type, char* id)
{
    symbol_table* new = (symbol_table*)malloc(sizeof(symbol_table));
    //malloc the id mem
    new->id =(char*)malloc(strlen(id)*sizeof(char));
    strcpy(new->id,id);
    //malloc the type mem
    new->type =(char*)malloc(strlen(type)*sizeof(char));
    strcpy(new->type,type);
    new->index = node_index;
    new->next = NULL;
    node_index++;
    return new;
}
void insert_node(symbol_table* node)
{
    symbol_table* temp;
    temp = recent_node();
    node->next = temp->next;
    temp->next = node;
}
symbol_table* recent_node()
{
    symbol_table* temp;
    temp = root;
    while(temp->next != NULL)
        temp = temp->next;
    return temp;
}
void count_line()
{
    line++;
}
