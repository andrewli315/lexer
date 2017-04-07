/*
	Topic: Homework1 for Compiler Course
	Deadline: xxx.xx.xxxx
*/

%{

/*	Definition section */

/*	insert the C library and variables you need */

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
	typedef struct SYMBOL{
		char *id;
		char *type;
		int index;
	}symbol;
	typedef struct TNODE{
		symbol* data;
		struct TNODE* left;
		struct TNODE* right;
	}Tnode;
	symbol* new_symbol (char* id,char* type,int index);
	Tnode* new_node(symbol* n);
	void insert_node(Tnode*,symbol*);
	void dump(Tnode*);
	void create_symbol();
	void insert_symbol(char*,symbol*);
	void dump_symbol();
	void count_line();
	int weight(char* str1,char* str2);
	int lookup_symbol(char*);
	//global variable
	Tnode* root;
	int node_index = 0;
	int line = 0;

%}

/*	define regular expression label */
letter 			[a-zA-Z]
digit 			[0-9]
id 				{letter}+({letter}|{digit})*
type_int		[iI][nN][tT]+{ws}
type_double 	[dD][oO][uU][bB][lL][eE]+{ws}
func_print		[pP][rR][iI][nN][tT]
w_while 		[wW][hH][iI][lL][eE]
w_if 			[iI][fF]
w_else 			[eE][lL][sS][eE]
ws 	 			[ \t]

%%

 /*	Rules section */
{type_int}+{id}				{create_symbol();}
{type_double}+{id}			{create_symbol();}
{func_print}				{printf("%s \t PRINT FUNCTION \n",yytext);	/* C action code */	;}
{w_while}					{printf("%s \t WHILE FUNCTION \n",yytext);}
{w_if}						{printf("%s \t IF \n",yytext);}
{w_else}					{printf("%s \t ELSE \n",yytext);}
"=" 						{printf("%s \t ASSIGN \n",yytext);}
"+" 						{printf("%s \t OPERATOR \n",yytext);}
"-" 						{printf("%s \t OPERATOR \n",yytext);}
"*" 						{printf("%s \t OPERATOR \n",yytext);}
"/" 						{printf("%s \t OPERATOR \n",yytext);}
"("							{printf("%s \t LB \n",yytext);}
")"							{printf("%s \t RB \n",yytext);}
">"							{printf("%s \t RELATIONAL \n",yytext);}
"<"							{printf("%s \t RELATIONAL \n",yytext);}
"<="						{printf("%s \t RELATIONAL \n",yytext);}
">="						{printf("%s \t RELATIONAL \n",yytext);}
"!="						{printf("%s \t RELATIONAL \n",yytext);}
"=="						{printf("%s \t RELATIONAL \n",yytext);}
";" 						{printf("%s \t SEMICOLON \n",yytext); }
","							{printf("%s \t COMMA \n",yytext);}
"{"							{printf("%s \t LCB \n",yytext);}
"}"							{printf("%s \t RCB \n",yytext);}
"\""						{printf("%s \t QUOTATION \n",yytext);}
"\'"						{printf("%s \t QUOTATION \n",yytext);}
"^"							{printf("%s \t EXPONETNTIAL \n",yytext);}
"\""+[^"\""]*+"\""	 		{printf("%s \t STRING \n",yytext); }

"/*"			{
					char c;
					for ( ; ; )
					{
						//do nothing
						while ( (c = input()) != '*' &&	c != EOF );
						if ( c == '*' )
						{
							while ( (c = input()) == '*' );
							if ( c == '/' )
							break;
						}
						if ( c == EOF )
						{
							printf( "EOF in comment" );
							break;
						}
					}
				}
"//"			{
					char c;
		    		while(c != '\n')
		    		{
						while ( (c = input()) != '\n' && c != EOF );
						if ( c == EOF )
						{
							printf( "EOF in comment" );
							break;
						}
					}
		    	}

{id} 					{printf("%s \t ID \n",yytext); }
{digit}+				{printf("%s \t NUMBER \n",yytext);}
{digit}+"."+{digit}		{printf("%s \t FLOATNUMBER \n",yytext);}
[\n]					{count_line();}
{ws}					{;}

%%

/*	C Code section */

/*	You have to define your C function in this section */

int main(int argc,char *argv[]){
	root = new_node(new_symbol("","",0));

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
	static int index = 1;
	symbol* node;
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
	node = new_symbol(pch,type,index++);
	printf("%s \t %s TYPE VAR\n", pch,type );
	printf("Create a symbol table\n");
	insert_symbol(pch,node);
}

void insert_symbol(char* s,symbol* node){
	printf("Insert a symbol:%s\n",s);
	insert_node(root,node);

}

int lookup_symbol(char* sym){

	Tnode* node = root->right;
	while(node != NULL)
	{
		if(strcmp(sym,node->data->id) == 0)
		{
			printf("\nLookup symbol:\n");
			printf("%d \t %s \t %s\n", node->data->index,node->data->id,node->data->type);
			return node->data->index;
		}
		else
		{
			if(weight(sym,node->data->id) == 0)
				node = node->left;
			else
				node = node->right;
		}
	}
	printf("There is no such symbol\n");
	return -1;
}

void dump_symbol(){
	printf("\nThe symbol table dump:\n");
	dump(root->right);
}
symbol* new_symbol(char* id,char* type,int index)
{
	symbol* new = (symbol*)malloc(sizeof(symbol));
	new->id = (char*)malloc(strlen(id)*sizeof(char));
	strcpy(new->id,id);
	new->type = (char*)malloc(strlen(type)*sizeof(char));
	strcpy(new->type,type);
	new->index = index;
	return new;

}
Tnode* new_node(symbol* n)
{
	Tnode* new;
	new = (Tnode*)malloc(sizeof(Tnode));
	new->data = (symbol*)malloc(sizeof(symbol));
	new->data->id = (char*)malloc(strlen(n->id)*sizeof(char));
	strcpy(new->data->id,n->id);
	new->data->type = (char*)malloc(strlen(n->type)*sizeof(char));
	strcpy(new->data->type,n->type);
	new->data->index = n->index;
	new->left = NULL;
	new->right = NULL;
	return new;
}
void insert_node(Tnode* t,symbol* n)
{
	
	if( weight(n->id ,t->data->id) == 1)
	{
		if( t->right == NULL)
		{
			t->right = new_node(n);
			return;
		}
		insert_node(t->right,n);
	}

	else if( weight(n->id ,t->data->id) == 0)
	{
		if( t->left == NULL)
		{
			t->left = new_node(n);
			return;
		}
		insert_node(t->left,n);
	}
}
void dump(Tnode* node)
{
	if(node != NULL)
	{
		printf("%d \t %s \t %s\n",node->data->index,node->data->id,node->data->type);
		dump(node->right);
		dump(node->left);		
	}
	else
		return;
}
int weight(char* str1,char* str2)
{
	int i;
	int length = strlen(str1)<strlen(str2)?strlen(str1):strlen(str2);
	for(i = 0 ; i<length;i++)
	{
		if(str1[i]<str2[i])
			return 0;
		else if(str1[i] == str2[i])
			continue;
		else
			return 1;
	}
	return strlen(str1)<strlen(str2)?0:1;
}
void count_line()
{
	line++;
}
