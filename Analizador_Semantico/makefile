salida :	sintactico.tab.c lex.yy.c listaSimbolos.c
	gcc sintactico.tab.c lex.yy.c listaSimbolos.c -lfl -o salida

sintactico.tab.c :	sintactico.y listaSimbolos.h
	bison -d sintactico.y

lex.yy.c :	lexico.l
	flex lexico.l

clean :
	rm -f lex.yy.c sintactico.tab.* salida

test :	salida test_funcional.txt
	./salida < test_funcional.txt

testLexico : salida test_lexico.txt
	./salida < test_lexico.txt

testSintactico : salida test_sintactico.txt
	./salida < test_sintactico.txt

testSemantico : salida test_semantico.txt
	./salida < test_semantico.txt