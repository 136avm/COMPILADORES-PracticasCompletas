%{
#include <stdio.h>
#include "/home/avm/Escritorio/compiladores/1. Analizador Léxico/lexico.h"
void yyerror();
extern int yylex();
%}

%union {
    int entero;
    char *cadena;
}

%token LPAREN RPAREN ASSIGNOP PLUSOP MINUSOP PRODOP DIVOP UMENOS LBRACE RBRACE SEMICOLON COMMA CADENA VAR CONST IF ELSE WHILE PRINT READ
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
         | IF LPAREN expression RPAREN statement ELSE statement
         | IF LPAREN expression RPAREN statement
         | WHILE LPAREN expression RPAREN statement
         | PRINT LPAREN print_list RPAREN SEMICOLON
         | READ LPAREN read_list RPAREN SEMICOLON
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

void yyerror() {
    printf("Se ha producido un error en esta expresion\n");
}