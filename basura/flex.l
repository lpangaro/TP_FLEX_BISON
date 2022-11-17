/*PARA COMPILAR	: bison -yd bison.y 					*/
/*				: flex flex.l							*/
/*				: gcc lex.yy.c y.tab.c -o ejecutable	*/
%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	#include "y.tab.h"
#ifndef yywrap
static int yywrap(void) { return 1;}
#endif
%}
DIGITO [0-9]
LETRAS [a-zA-Z]
IDENTIFICADOR {LETRAS}({LETRAS}|{DIGITO})*
%%
{DIGITO}+  {yylval.num=atoi(yytext);  return (CONSTANTE);};
{IDENTIFICADOR} {strcpy(yylval.cadena, yytext);	return (ID);};

"inicio"        {return(INICIO);}
"fin"           {return(FIN);}
"leer"          {return(LEER);}
"escribir"      {return(ESCRIBIR);}
"-" 			{return (MENOS);}
"+" 			{return (MAS);}
":="			{return (ASIGNACION);}
"("				{return (PA);}
")"				{return (PC);}
","				{return (COMA);}
";"				{return (PUNTOYCOMA);}
":"				{return (DOSPUNTOS);}
.     			{printf("ES UN ERROR LEXICO\n");};
%%
