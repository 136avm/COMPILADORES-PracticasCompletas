%define parse.error verbose
%{
#include <stdio.h>
void yyerror(const char *s);
extern int yylex();
extern int yylineno;
int numErroresSintacticos = 0;
extern int numErroresLexicos;
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

program:   ID LPAREN RPAREN LBRACE declarations statement_list RBRACE
         | error LBRACE declarations statement_list RBRACE
        ;

declarations: declarations VAR identifier_list SEMICOLON
            | declarations CONST identifier_list SEMICOLON
            | error SEMICOLON
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

statement: ID ASSIGNOP expression SEMICOLON
         | LBRACE statement_list RBRACE
         | IF LPAREN expression RPAREN statement ELSE statement
         | IF LPAREN expression RPAREN statement
         | WHILE LPAREN expression RPAREN statement
         | PRINT LPAREN print_list RPAREN SEMICOLON
         | READ LPAREN read_list RPAREN SEMICOLON
         | error SEMICOLON
         | error LBRACE
         | error RPAREN
         | IF LPAREN error RPAREN statement ELSE statement
         | IF LPAREN error RPAREN statement
         | WHILE LPAREN error RPAREN statement
         | PRINT LPAREN error RPAREN SEMICOLON
         | READ LPAREN error RPAREN SEMICOLON
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

void yyerror(const char *s) {
    fprintf(stderr, "ERROR SINTÁCTICO en la línea %d: %s\n", yylineno, s);
    numErroresSintacticos++;
}

int main() {
    yyparse();

    if (numErroresSintacticos == 0) {
        printf("El análisis sintáctico fue exitoso\n");
    } else {
        printf("El análisis sintáctico encontró %d errores\n", numErroresSintacticos);
    }

    if (numErroresLexicos == 0) {
        printf("El análisis léxico fue exitoso\n");
    } else {
        printf("El análisis léxico encontró %d errores\n", numErroresLexicos);
    }

    if (numErroresSintacticos == 0 && numErroresLexicos == 0) {
        printf("El análisis fue exitoso\n");
    } else {
        printf("El análisis encontró errores\n");
    }

    return 0;
}
