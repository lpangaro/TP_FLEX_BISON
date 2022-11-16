%{
 #include <stdio.h>
 #include <stdlib.h>
 #include <math.h>
 extern char *yytext;
 extern int yyleng;
 extern int yylex(void);
 extern void yyerror(char*);
 void mostrarResultado(int);
 %}
 %union {char* cadena; int num; char caracter;}
 %token INICIO FIN LEER ESCRIBIR ID CONSTANTE ASIGNACION 
        PA PC COMA PUNTOYCOMA MAS MENOS
 %left MAS MENOS
 %rigth ASIGNACION
 %type <cadena> ID INICIO FIN LEER ESCRIBIR ASIGNACION
 %type <num> sumar restar CONSTANTE 
 %type <caracter> PA PD COMA PUNTOYCOMA MAS MENOS
 %%
 sumar: CONSTANTE|
        sumar MAS sumar {mostrarResultado($1+$3);}
 ;
 %%
 int main(){
 yyparse();
 }
 void mostrarResultado(int a){
     printf("%d",a);
 }

 void yyerror(char* mensaje){
 printf("mi error era: %s", mensaje);
 }
 int yyrap(){
 return 1;
 }