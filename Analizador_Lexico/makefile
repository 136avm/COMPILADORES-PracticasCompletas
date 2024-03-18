lexico :	lexico.c
	gcc lexico.c -lfl -o lexico

lexico.c :	lexico.l
	flex -o lexico.c lexico.l

all :	lexico

clean :
	rm -f *.c lexico

run :	lexico test_lexico.txt
	./lexico < test_lexico.txt