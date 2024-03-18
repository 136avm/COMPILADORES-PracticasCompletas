salida :	sintactico.tab.c lex.yy.c
	gcc sintactico.tab.c lex.yy.c -lfl -o salida

sintactico.tab.c :	sintactico.y
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