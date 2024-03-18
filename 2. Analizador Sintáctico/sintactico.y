
%{
#include <stdio.h>
#include "../lexico.h"
void yyerror();
extern int yylex();
%}

%union{
       int entero;
       char *cadena;
}

%token LPAREN RPAREN ASSIGNOP PLUSOP MINUSOP PRODOP DIVOP UMENOS LBRACE RBRACE SEMICOLON COMMA CADENA VAR CONST
%token <entero> INTLITERAL
%token <cadena> ID
%left PLUSOP MINUSOP
%left PRODOP DIVOP
%left UMENOS
%%

program: ID LPAREN RPAREN LBRACE declarations statement_list RBRACE
        ;


declarations: declarations VAR identifier_list SEMICOLON
            | declarations CONST identifier_list SEMICOLON
            | /* lambda */
            ;

identifier_list: identifier
               | identifier_list COMMA identifier
               ;

identifier: ID
          | ID ASSIGNOP expression 
          ;

statement_list: statement_list statement
              | /* lambda */
              ;

statement: identifier ASSIGNOP expression SEMICOLON
         | LBRACE statement_list RBRACE
         | 'if' LPAREN expression RPAREN statement 'else' statement
         | 'if' LPAREN expression RPAREN statement
         | 'while' LPAREN expression RPAREN statement
         | 'print' LPAREN print_list RPAREN SEMICOLON
         | 'read' LPAREN read_list RPAREN SEMICOLON
         ;

print_list: print_item
          | print_list COMMA print_item
          ;

print_item: expression
          | CADENA
          ;

read_list: ID                  
                               
         | read_list COMMA ID   

         ;

expression: expression PLUSOP expression
          | expression MINUSOP expression
          | expression PRODOP expression
          | expression DIVOP expression
          | MINUSOP expression %prec UMENOS
          | LPAREN expression RPAREN
          | ID
          | INTLITERAL
          ;



%%

void yyerror()
{
printf("Se ha producido un error en esta expresion\n");
}
