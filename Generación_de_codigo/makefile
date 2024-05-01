miniC :	sintactico.tab.c lex.yy.c listaSimbolos.c listaCodigo.c
	gcc sintactico.tab.c lex.yy.c listaSimbolos.c listaCodigo.c -lfl -o miniC

sintactico.tab.c :	sintactico.y listaSimbolos.h listaCodigo.h
	bison -d sintactico.y

lex.yy.c :	lexico.l
	flex lexico.l

clean :
	rm -f lex.yy.c sintactico.tab.* salida

test :	miniC test_funcional.txt
	./miniC test_funcional.txt

testLexico : miniC test_lexico.txt
	./miniC test_lexico.txt

testSintactico : miniC test_sintactico.txt
	./miniC test_sintactico.txt

testSemantico : miniC test_semantico.txt
	./miniC test_semantico.txt

testFinal : miniC test_funcional.txt
	./miniC test_funcional.txt > test.s
	spim -file test.s
	rm test.s