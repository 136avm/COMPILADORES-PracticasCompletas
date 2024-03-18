%option yylineno
%{
#include "sintactico.tab.h"
char error_buffer[1024];
int error_buffer_index = 0;
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
                                        return ID;    
                                    } else {
                                        printf("ERROR LÉXICO en la línea %d: \"%s\" con longitud %d. La cadena no puede exceder de 32 caracteres.\n", yylineno,yytext,yyleng);
                                    } };
{entero}                            { if(atoll(yytext)>=-2147483648 && atoll(yytext)<=2147483648) {
                                        return INTLITERAL;
                                    } else {
                                        printf("ERROR LÉXICO en la línea %d: \"%s\". El número entero debe estar entre -2^31 y 2^31.\n", yylineno,yytext);
                                    } };
\"([^"\n]|{escape})*\"              return CADENA;
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
<PANIC>.                             { error_buffer[error_buffer_index] = '\0'; printf("ERROR LEXICO en la línea %d: Secuencia de caracteres no reconocidos encontrada: %s\n", yylineno, error_buffer); error_buffer_index = 0; BEGIN(INITIAL); yyless(0); }
%%

/*void main() {
    int i;
    while (i=yylex())
        switch (i) {
                case 1:
                    printf("%d [%s, ]\n",i,"VAR");
                    break;
                case 2:
                    printf("%d [%s, ]\n",i,"CONST");
                    break;
                case 3:
                    printf("%d [%s, ]\n",i,"IF");
                    break;
                case 4:
                    printf("%d [%s, ]\n",i,"ELSE");
                    break;
                case 5:
                    printf("%d [%s, ]\n",i,"WHILE");
                    break;
                case 6:
                    printf("%d [%s, ]\n",i,"PRINT");
                    break;
                case 7:
                    printf("%d [%s, ]\n",i,"READ");
                    break;
                case 8:
                    if(yyleng<=32) {
                        printf("%d [%s, %s]\n",i,"ID",yytext);    
                    } else {
                        printf("ERROR LÉXICO en la línea %d: \"%s\" con longitud %d. La cadena no puede exceder de 32 caracteres.\n", yylineno,yytext,yyleng);
                    }
                    break;
                case 9:
                    if(atoll(yytext)>=-2147483648 && atoll(yytext)<=2147483648) {
                        printf("%d [%s, %s]\n",i,"INTLITERAL",yytext);
                    } else {
                        printf("ERROR LÉXICO en la línea %d: \"%s\". El número entero debe estar entre -2^31 y 2^31.\n", yylineno,yytext);
                    }
                    break;
                case 10:
                    printf("%d [%s, %s]\n",i,"CADENA",yytext);
                    break;
                case 11:
                    printf("%d [%s, ]\n",i,"LPAREN");
                    break;
                case 12:
                    printf("%d [%s, ]\n",i,"RPAREN");
                    break;
                case 13:
                    printf("%d [%s, ]\n",i,"SEMICOLON");
                    break;
                case 14:
                    printf("%d [%s, ]\n",i,"COMMA");
                    break;
                case 15:
                    printf("%d [%s, ]\n",i,"ASSIGNOP");
                    break;
                case 16:
                    printf("%d [%s, ]\n",i,"PLUSOP");
                    break;
                case 17:
                    printf("%d [%s, ]\n",i,"MINUSOP");
                    break;
                case 18:
                    printf("%d [%s, ]\n",i,"LBRACE");
                    break;
                case 19:
                    printf("%d [%s, ]\n",i,"RBRACE");
                    break;
                case 20:
                    printf("%d [%s, ]\n",i,"PRODOP");
                    break;
                case 21:
                    printf("%d [%s, ]\n",i,"DIVOP");
                    break;
        }
    printf("FIN DE ANALISIS LEXICO\n");
}*/