%option yylineno
%{
#include "sintactico.tab.h"
char error_buffer[1024];
int error_buffer_index = 0;
int numErroresLexicos = 0;
%}

%x PANIC
digito              [0-9]
letra               [a-zA-Z]
entero              {digito}+
escape              (\\\"|\\\\|\\n|\\t)
%%
[ \n\t]+                            ;
"//"(.*)[\n]                        ;
"/*"([^*]|[*]+[^*/])*[*]+"/"        ;
var                                 return VAR;
const                               return CONST;
if                                  return IF;
else                                return ELSE;
while                               return WHILE;
print                               return PRINT;
read                                return READ;
({letra}|_)({letra}|{digito}|_)*    { if(yyleng<=32) {
                                        yylval.cadena = strdup(yytext);
                                        return ID;    
                                    } else {
                                        fprintf(stderr, "ERROR LÉXICO en la línea %d: \"%s\" con longitud %d. La cadena no puede exceder de 32 caracteres.\n", yylineno,yytext,yyleng);
                                        numErroresLexicos++;
                                    } };
{entero}                            { if(atoll(yytext)>=-2147483648 && atoll(yytext)<=2147483648) {
                                        yylval.entero = atoll(yytext);
                                        return INTLITERAL;
                                    } else {
                                        fprintf(stderr, "ERROR LÉXICO en la línea %d: \"%s\". El número entero debe estar entre -2^31 y 2^31.\n", yylineno,yytext);
                                        numErroresLexicos++;
                                    } };
\"([^"\n]|{escape})*\"              { yylval.cadena = strdup(yytext); return CADENA; };
"("                                 return LPAREN;		
")"                                 return RPAREN;
";"                                 return SEMICOLON;
","                                 return COMMA;
"="                                 return ASSIGNOP;
"+"                                 return PLUSOP;
"-"                                 return MINUSOP;
"{"                                 return LBRACE;
"}"                                 return RBRACE;
"*"                                 return PRODOP;
"/"                                 return DIVOP;
[^a-zA-Z0-9_+\-*/(){};,"= \n\t]     { BEGIN(PANIC); error_buffer[error_buffer_index++] = yytext[0]; }
<PANIC>[^a-zA-Z0-9_+\-*/(){};,"= \n\t] { error_buffer[error_buffer_index++] = yytext[0]; }
<PANIC>.                             { error_buffer[error_buffer_index] = '\0'; fprintf(stderr, "ERROR LEXICO en la línea %d: Secuencia de caracteres no reconocidos encontrada: %s\n", yylineno, error_buffer); error_buffer_index = 0; BEGIN(INITIAL); yyless(0); numErroresLexicos++; }
%%