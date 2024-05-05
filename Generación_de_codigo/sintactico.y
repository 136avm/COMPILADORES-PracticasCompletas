%define parse.error verbose
%{
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include "listaSimbolos.h"
#include "listaCodigo.h"
#include <stdlib.h>
void yyerror(const char *s);
extern int yylex();
extern int yylineno;
int numErroresSintacticos = 0;
extern int numErroresLexicos;
Lista tabSimb;
Tipo tipo;
int  contCadenas = 0;
void insertar(char *id, Tipo tipo);
int perteneceTS(char *id);
int esConstante(char *id);
int numErroresSemanticos = 0;
extern char *yytext;
extern FILE *yyin;
extern int yyparse();
extern int yyleng();
int regs[10] = {0,0,0,0,0,0,0,0,0,0};
char * regsDevolver[10] = {"$t0", "$t1", "$t2", "$t3", "$t4", "$t5", "$t6", "$t7", "$t8", "$t9"};
char * obtenerReg();
char * concatena(char *a, char *b);
void liberarReg(char * reg);
void imprimirCodigo(ListaC codigo);
int contadorEtiq = 1;
char * nuevaEtiqueta() {
    char * aux;
    asprintf(&aux, "$l%d", contadorEtiq++);
    return aux;
}
char * creaCadena() {
    char * aux;
    asprintf(&aux, "$str%d", contCadenas);
    return aux;
}
char * argToString(int arg) {
    char * aux;
    asprintf(&aux, "%d", arg);
    return aux;
}
void imprimirCabecera();
%}

%code requires{
    #include "listaCodigo.h"
}

%union {
    int entero;
    char *cadena;
    ListaC codigo;
}

%type <codigo> expression statement statement_list print_item print_list read_list declarations identifier_list identifier;

%token LPAREN RPAREN ASSIGNOP PLUSOP MINUSOP PRODOP DIVOP UMENOS LBRACE RBRACE SEMICOLON COMMA VAR CONST IF ELSE WHILE PRINT READ
%token <entero> INTLITERAL
%token <cadena> ID
%token <cadena> CADENA
%left PLUSOP MINUSOP
%left PRODOP DIVOP
%left UMENOS
%%

program: { tabSimb = creaLS(); } ID LPAREN RPAREN LBRACE declarations statement_list RBRACE {imprimirCabecera();
                                                                                            concatenaLC($6, $7);
                                                                                            imprimirCodigo($6);
                                                                                            liberaLC($6);
                                                                                            liberaLC($7);
                                                                                            liberaLS(tabSimb);}
       /*| error LBRACE declarations statement_list RBRACE*/
       ;

declarations: declarations VAR { tipo=VARIABLE; } identifier_list SEMICOLON     { $$ = $1;
                                                                                  concatenaLC($$, $4);
                                                                                  liberaLC($4);}
            | declarations CONST { tipo=CONSTANTE; } identifier_list SEMICOLON  { $$ = $1;
                                                                                  concatenaLC($$, $4);
                                                                                  liberaLC($4);}
            | /* lambda */  { $$ = creaLC(); }
            ;

identifier_list: identifier                         { $$ = $1; }
               | identifier_list COMMA identifier   { $$ = $1;
                                                      concatenaLC($$, $3);
                                                      liberaLC($3); }
               ;

identifier: ID                          { if(!perteneceTS($1)) {insertar($1, tipo);}
                                          else {fprintf(stderr, "ERROR SEMÁNTICO, en la línea %d, ID ya declarado.\n", yylineno); numErroresSemanticos++; } 
                                          $$ = creaLC(); }
          | ID ASSIGNOP expression      { if(!perteneceTS($1)) {insertar($1, tipo);}
                                          else {fprintf(stderr, "ERROR SEMÁNTICO, en la línea %d, ID ya declarado.\n", yylineno); numErroresSemanticos++; } 
                                          $$ = $3;
                                          Operacion oper;
                                          oper.op = "sw";
                                          oper.res = recuperaResLC($3);
                                          oper.arg1 = concatena("_",$1);
                                          oper.arg2 = NULL;
                                          insertaLC($$, finalLC($$), oper);
                                          guardaResLC($$, oper.res);
                                          liberarReg(oper.res); }
          ;

statement_list: statement_list statement                            { $$ = $1;
                                                                      concatenaLC($$, $2);
                                                                      liberaLC($2);}
              | /* lambda */                                        { $$ = creaLC(); }
              ;

statement: ID ASSIGNOP expression SEMICOLON                         { if(!perteneceTS($1)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, ID no declarado.\n", yylineno); numErroresSemanticos++; }
                                                                      else if(esConstante($1)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, CONST no puede ser reasignado.\n", yylineno);numErroresSemanticos++;  } 
                                                                      $$ = $3;
                                                                      Operacion oper;
                                                                      oper.op = "sw";
                                                                      oper.res = recuperaResLC($3);
                                                                      oper.arg1 = concatena("_",$1);
                                                                      oper.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper);
                                                                      liberarReg(oper.res); }
         | LBRACE statement_list RBRACE                             { $$ = $2; }
         | IF LPAREN expression RPAREN statement ELSE statement     { $$ = $3;
                                                                      Operacion oper;
                                                                      oper.op = "beqz";
                                                                      oper.res = recuperaResLC($3);
                                                                      oper.arg1 = nuevaEtiqueta();
                                                                      oper.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper);
                                                                      concatenaLC($$, $5);
                                                                      Operacion oper2;
                                                                      oper2.op = "b";
                                                                      oper2.res = nuevaEtiqueta();
                                                                      oper2.arg1 = NULL;
                                                                      oper2.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper2);
                                                                      Operacion oper3;
                                                                      oper3.op = concatena(oper.arg1,":");
                                                                      oper3.res = NULL;
                                                                      oper3.arg1 = NULL;
                                                                      oper3.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper3);
                                                                      concatenaLC($$, $7);
                                                                      Operacion oper4;
                                                                      oper4.op = concatena(oper2.res,":");
                                                                      oper4.res = NULL;
                                                                      oper4.arg1 = NULL;
                                                                      oper4.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper4);
                                                                      liberarReg(oper.res); }
         | IF LPAREN expression RPAREN statement                    { $$ = $3;
                                                                      Operacion oper;
                                                                      oper.op = "beqz";
                                                                      oper.res = recuperaResLC($3);
                                                                      oper.arg1 = nuevaEtiqueta();
                                                                      oper.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper);
                                                                      concatenaLC($$, $5);
                                                                      Operacion oper2;
                                                                      oper2.op = concatena(oper.arg1,":");
                                                                      oper2.res = NULL;
                                                                      oper2.arg1 = NULL;
                                                                      oper2.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper2);
                                                                      liberarReg(oper.res); }
         | WHILE LPAREN expression RPAREN statement                 { $$ = creaLC();
                                                                      Operacion oper;
                                                                      char * etiqueta = nuevaEtiqueta();
                                                                      oper.op = concatena(etiqueta,":");
                                                                      oper.res = NULL;
                                                                      oper.arg1 = NULL;
                                                                      oper.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper);
                                                                      concatenaLC($$, $3);
                                                                      Operacion oper2;
                                                                      oper2.op = "beqz";
                                                                      oper2.res = recuperaResLC($3);
                                                                      oper2.arg1 = nuevaEtiqueta();
                                                                      oper2.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper2);
                                                                      concatenaLC($$, $5);
                                                                      Operacion oper3;
                                                                      oper3.op = "b";
                                                                      oper3.res = etiqueta;
                                                                      oper3.arg1 = NULL;
                                                                      oper3.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper3);
                                                                      Operacion oper4;
                                                                      oper4.op = concatena(oper2.arg1,":");
                                                                      oper4.res = NULL;
                                                                      oper4.arg1 = NULL;
                                                                      oper4.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper4);
                                                                      liberarReg(oper2.res); }
         | PRINT LPAREN print_list RPAREN SEMICOLON                 { $$ = $3; }
         | READ LPAREN read_list RPAREN SEMICOLON                   { $$ = $3; }
         ;

print_list: print_item  { $$ = $1; }
          | print_list COMMA print_item { $$ = $1;
                                          concatenaLC($$, $3);
                                          liberaLC($3); }
          ;

print_item: expression  { $$ = $1;
                          Operacion oper;
                          oper.op = "li";
                          oper.res = "$v0";
                          oper.arg1 = "1";
                          oper.arg2 = NULL;
                          insertaLC($$, finalLC($$), oper);
                          Operacion oper2;
                          oper2.op = "move";
                          oper2.res = "$a0";
                          oper2.arg1 = recuperaResLC($1);
                          oper2.arg2 = NULL;
                          insertaLC($$, finalLC($$), oper2);
                          Operacion oper3;
                          oper3.op = "syscall";
                          oper3.res = NULL;
                          oper3.arg1 = NULL;
                          oper3.arg2 = NULL;
                          insertaLC($$, finalLC($$), oper3);
                          liberarReg(oper2.arg1); }
          | CADENA      { insertar($1, STRING); contCadenas++;
                          $$ = creaLC(); 
                          Operacion oper;
                          oper.op = "li";
                          oper.res = "$v0";
                          oper.arg1 = "4";
                          oper.arg2 = NULL;
                          insertaLC($$, finalLC($$), oper);
                          Operacion oper2;
                          oper2.op = "la";
                          oper2.res = "$a0";
                          oper2.arg1 = creaCadena();
                          oper2.arg2 = NULL;
                          insertaLC($$, finalLC($$), oper2);
                          Operacion oper3;
                          oper3.op = "syscall";
                          oper3.res = NULL;
                          oper3.arg1 = NULL;
                          oper3.arg2 = NULL;
                          insertaLC($$, finalLC($$), oper3); }
          ;

read_list: ID                                                       { if(!perteneceTS($1)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, ID no declarado.\n", yylineno); numErroresSemanticos++; }
                                                                      else if(esConstante($1)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, CONST no puede ser reasignado.\n", yylineno); numErroresSemanticos++; } 
                                                                      $$ = creaLC();
                                                                      Operacion oper;
                                                                      oper.op = "li";
                                                                      oper.res = "$v0";
                                                                      oper.arg1 = "5";
                                                                      oper.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper);
                                                                      Operacion oper2;
                                                                      oper2.op = "syscall";
                                                                      oper2.res = NULL;
                                                                      oper2.arg1 = NULL;
                                                                      oper2.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper2);
                                                                      Operacion oper3;
                                                                      oper3.op = "sw";
                                                                      oper3.res = recuperaResLC($$);
                                                                      oper3.arg1 = concatena("_",$1);
                                                                      oper3.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper3);}                              
         | read_list COMMA ID                                       { if(!perteneceTS($3)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, ID no declarado.\n", yylineno); numErroresSemanticos++; }
                                                                      else if(esConstante($3)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, CONST no puede ser reasignado.\n", yylineno); numErroresSemanticos++; }
                                                                      $$ = $1;
                                                                      Operacion oper;
                                                                      oper.op = "li";
                                                                      oper.res = "$v0";
                                                                      oper.arg1 = "5";
                                                                      oper.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper);
                                                                      Operacion oper2;
                                                                      oper2.op = "syscall";
                                                                      oper2.res = NULL;
                                                                      oper2.arg1 = NULL;
                                                                      oper2.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper2);
                                                                      Operacion oper3;
                                                                      oper3.op = "sw";
                                                                      oper3.res = recuperaResLC($$);
                                                                      oper3.arg1 = concatena("_",$3);
                                                                      oper3.arg2 = NULL;
                                                                      insertaLC($$, finalLC($$), oper3);}  
         ;

expression: expression PLUSOP expression       {$$ = $1;
                                                concatenaLC($$, $3);
                                                Operacion oper;
                                                oper.op = "add";
                                                oper.res = recuperaResLC($1);
                                                oper.arg1 = recuperaResLC($1);
                                                oper.arg2 = recuperaResLC($3);
                                                insertaLC($$, finalLC($$), oper);
                                                liberaLC($3);
                                                liberarReg(oper.arg2);}
          | expression MINUSOP expression      {$$ = $1;
                                                concatenaLC($$, $3);
                                                Operacion oper;
                                                oper.op = "sub";
                                                oper.res = recuperaResLC($1);
                                                oper.arg1 = recuperaResLC($1);
                                                oper.arg2 = recuperaResLC($3);
                                                insertaLC($$, finalLC($$), oper);
                                                liberaLC($3);
                                                liberarReg(oper.arg2);} 
          | expression PRODOP expression       {$$ = $1;
                                                concatenaLC($$, $3);
                                                Operacion oper;
                                                oper.op = "mul";
                                                oper.res = recuperaResLC($1);
                                                oper.arg1 = recuperaResLC($1);
                                                oper.arg2 = recuperaResLC($3);
                                                insertaLC($$, finalLC($$), oper);
                                                liberaLC($3);
                                                liberarReg(oper.arg2);}
          | expression DIVOP expression        {$$ = $1;
                                                concatenaLC($$, $3);
                                                Operacion oper;
                                                oper.op = "div";
                                                oper.res = recuperaResLC($1);
                                                oper.arg1 = recuperaResLC($1);
                                                oper.arg2 = recuperaResLC($3);
                                                insertaLC($$, finalLC($$), oper);
                                                liberaLC($3);
                                                liberarReg(oper.arg2);}
          | MINUSOP expression %prec UMENOS    {$$ = $2;
                                                Operacion oper;
                                                oper.op = "neg";
                                                oper.res = recuperaResLC($2);
                                                oper.arg1 = recuperaResLC($2);
                                                oper.arg2 = NULL;
                                                insertaLC($$, finalLC($$), oper);} 
          | LPAREN expression RPAREN           {$$ = $2;}
          | ID                                 {if(!perteneceTS($1)) {fprintf(stderr, "ERROR SEMÁNTICO en la línea %d, ID no declarado.\n", yylineno); numErroresSemanticos++; } 
                                                $$ = creaLC();
                                                Operacion oper;
                                                oper.op = "lw";
                                                oper.res = obtenerReg();
                                                oper.arg1 = concatena("_",$1);
                                                oper.arg2 = NULL;
                                                insertaLC($$, finalLC($$), oper);
                                                guardaResLC($$, oper.res);}
          | INTLITERAL                         {$$ = creaLC();
                                                Operacion oper;
                                                oper.op = "li";
                                                oper.res = obtenerReg();
                                                oper.arg1 = argToString($1);
                                                oper.arg2 = NULL;
                                                insertaLC($$, finalLC($$), oper);
                                                guardaResLC($$, oper.res);}
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

char * obtenerReg() {
    for (int i = 0; i < 10; i++) {
        if (regs[i] == 0) {
            regs[i] = 1;
            return regsDevolver[i];
        }
    }
    fprintf(stderr, "ERROR: registros temporales agotados\n");
    return "";
}

char * concatena(char *a, char *b) {
    char *res = malloc(strlen(a) + strlen(b) + 1);
    strcpy(res, a);
    strcat(res, b);
    return res;
}

void liberarReg(char * reg) {
    // Obtener el tercer caracter del registro, pasarlo a numero y liberar en el array de registros
    int num = reg[2] - '0';
    regs[num] = 0;
}

void imprimirCodigo(ListaC codigo) {
    printf("\n##################\n");
    printf("# Seccion de código\n");
    printf("\t.text\n");
    printf("\t.globl main\n");
    printf("main:\n");
    PosicionListaC p = inicioLC(codigo);
    while (p != finalLC(codigo)) {
        Operacion oper = recuperaLC(codigo,p);
        if (oper.op[0] != '$') printf("\t");
        printf("%s",oper.op);
        if (oper.res) printf(" %s",oper.res);
        if (oper.arg1) printf(",%s",oper.arg1);
        if (oper.arg2) printf(",%s",oper.arg2);
        printf("\n");
        p = siguienteLC(codigo,p);
    }
    printf("##################\n");
    printf("# Fin del programa\n");
    printf("\tli $v0, 10\n");
    printf("\tsyscall\n");
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

    if (numErroresSintacticos == 0) {} else {
        printf("El análisis sintáctico encontró %d errores\n", numErroresSintacticos);
    }

    if (numErroresLexicos == 0) {} else {
        printf("El análisis léxico encontró %d errores\n", numErroresLexicos);
    }

    if (numErroresSemanticos == 0) {} else {
        printf("El análisis semántico encontró %d errores\n", numErroresSemanticos);
    }

    if (numErroresSintacticos == 0 && numErroresLexicos == 0 && numErroresSemanticos == 0) {} else {
        printf("El análisis encontró %d errores\n", numErroresSintacticos + numErroresLexicos + numErroresSemanticos);
    }

    return 0;
}
