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
        PARENIZQUIERDO PARENDERECHO COMA PUNTOYCOMA MAS MENOS
 %left MAS MENOS
 %type <cadena> ID INICIO FIN LEER ESCRIBIR ASIGNACION
 %type <num> sumar restar CONSTANTE 
 %type <caracter> PARENIZQUIERDO PARENDERECHO COMA PUNTOYCOMA MAS MENOS
 %%
 sumar: CONSTANTE|
        sumar MAS sumar {mostrarResultado($1+$3);}
 ;
 restar: CONSTANTE|
        restar MENOS restar {mostrarResultado($1+$3);}
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