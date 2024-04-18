%define parse.error verbose
%{
#include <stdio.h>
#include "listaSimbolos.h"
#include <stdlib.h>
void yyerror(const char *s);
extern int yylex();
extern int yylineno;
int numErroresSintacticos = 0;
extern int numErroresLexicos;
Lista tabSimb;
Tipo tipo;
int  contCadenas = 1;
void insertar(char *id, Tipo tipo);
int perteneceTS(char *id);
int esConstante(char *id);
int numErroresSemanticos = 0;
extern char *yytext;
extern FILE *yyin;
extern int yyparse();
extern int yyleng();
%}

%code requires{
    #include "listaCodigo.h"
}

%union {
    int entero;
    char *cadena;
    ListaC codigo;
}

%type <codigo> expression;

%token LPAREN RPAREN ASSIGNOP PLUSOP MINUSOP PRODOP DIVOP UMENOS LBRACE RBRACE SEMICOLON COMMA VAR CONST IF ELSE WHILE PRINT READ
%token <entero> INTLITERAL
%token <cadena> ID
%token <cadena> CADENA
%left PLUSOP MINUSOP
%left PRODOP DIVOP
%left UMENOS
%%

program: { tabSimb = creaLS(); } ID LPAREN RPAREN LBRACE declarations statement_list RBRACE
       | error LBRACE declarations statement_list RBRACE
       ;

declarations: declarations VAR { tipo=VARIABLE; } identifier_list SEMICOLON
            | declarations CONST { tipo=CONSTANTE; } identifier_list SEMICOLON
            | error SEMICOLON
            | /* lambda */
            ;

identifier_list: identifier
               | identifier_list COMMA identifier
               ;

identifier: ID                          { if(!perteneceTS($1)) {insertar($1, tipo);}
                                          else {fprintf(stderr, "ERROR SEMÁNTICO, en la línea %d, ID ya declarado.\n", yylineno); numErroresSemanticos++; } }
          | ID ASSIGNOP expression      { if(!perteneceTS($1)) {insertar($1, tipo);}
                                          else {fprintf(stderr, "ERROR SEMÁNTICO, en la línea %d, ID ya declarado.\n", yylineno); numErroresSemanticos++; } }
          ;

statement_list: statement_list statement
              | /* lambda */
              ;

statement: ID ASSIGNOP expression SEMICOLON                         { if(!perteneceTS($1)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, ID no declarado.\n", yylineno); numErroresSemanticos++; }
                                                                      else if(esConstante($1)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, CONST no puede ser reasignado.\n", yylineno);numErroresSemanticos++;  } }
         | LBRACE statement_list RBRACE
         | IF LPAREN expression RPAREN statement ELSE statement
         | IF LPAREN expression RPAREN statement
         | WHILE LPAREN expression RPAREN statement
         | PRINT LPAREN print_list RPAREN SEMICOLON
         | READ LPAREN read_list RPAREN SEMICOLON
         | error SEMICOLON
         | LBRACE error RBRACE
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
          | CADENA      { insertar($1, STRING); contCadenas++; }
          ;

read_list: ID                                                       { if(!perteneceTS($1)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, ID no declarado.\n", yylineno); numErroresSemanticos++; }
                                                                      else if(esConstante($1)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, CONST no puede ser reasignado.\n", yylineno); numErroresSemanticos++; } }                              
         | read_list COMMA ID                                       { if(!perteneceTS($3)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, ID no declarado.\n", yylineno); numErroresSemanticos++; }
                                                                      else if(esConstante($3)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, CONST no puede ser reasignado.\n", yylineno); numErroresSemanticos++; } }  
         ;

expression: expression PLUSOP expression
          | expression MINUSOP expression
          | expression PRODOP expression
          | expression DIVOP expression
          | MINUSOP expression %prec UMENOS
          | LPAREN expression RPAREN
          | ID                                                       { if(!perteneceTS($1)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, ID no declarado.\n", yylineno); numErroresSemanticos++; } }
          | INTLITERAL
          ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "ERROR SINTÁCTICO en la línea %d: %s\n", yylineno, s);
    numErroresSintacticos++;
}

void insertar(char *id, Tipo tipo) {
    Simbolo s;
    s.nombre = id;
    s.tipo = tipo;
    insertaLS(tabSimb, finalLS(tabSimb), s);
}

int perteneceTS(char *id) {
    return buscaLS(tabSimb, id) != finalLS(tabSimb);
}

int esConstante(char *id) {
    Simbolo s = recuperaLS(tabSimb, buscaLS(tabSimb, id));
    return s.tipo == CONSTANTE;
}

void imprimirCabecera(){
    printf("##################\n");
    printf("# Seccion de datos\n");
    printf("\t.data\n\n");
    imprimirLS(tabSimb);
}

int main(int argc, char *argv[]) {
    if (argc != 2){
        printf("Uso correcto: %s fichero\n", argv[0]);
        exit(1);
    }
    FILE *fitch = fopen(argv[1], "r");
    if (fitch == 0) {
        printf("No se pudo abrir el fichero %s\n", argv[1]);
        exit(1);
    }
    yyin = fitch;
    yyparse();
    fclose(fitch);

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

    if (numErroresSemanticos == 0) {
        printf("El análisis semántico fue exitoso\n");
    } else {
        printf("El análisis semántico encontró %d errores\n", numErroresSemanticos);
    }

    if (numErroresSintacticos == 0 && numErroresLexicos == 0 && numErroresSemanticos == 0) {
        printf("El análisis fue exitoso\n");
    } else {
        printf("El análisis encontró %d errores\n", numErroresSintacticos + numErroresLexicos + numErroresSemanticos);
    }

    printf("\nLa cabecera del código ensamblador es: \n\n");
    imprimirCabecera();
    liberaLS(tabSimb);

    return 0;
}
