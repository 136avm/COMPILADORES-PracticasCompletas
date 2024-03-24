miCompilador :	sintactico.tab.c lex.yy.c listaSimbolos.c
	gcc sintactico.tab.c lex.yy.c listaSimbolos.c -lfl -o miCompilador

sintactico.tab.c :	sintactico.y listaSimbolos.h
	bison -d sintactico.y

lex.yy.c :	lexico.l
	flex lexico.l

clean :
	rm -f lex.yy.c sintactico.tab.* salida

test :	miCompilador test_funcional.txt
	./miCompilador test_funcional.txt

testLexico : miCompilador test_lexico.txt
	./miCompilador test_lexico.txt

testSintactico : miCompilador test_sintactico.txt
	./miCompilador test_sintactico.txt

testSemantico : miCompilador test_semantico.txt
	./miCompilador test_semantico.txt