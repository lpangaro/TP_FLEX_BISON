%{
#include <stdio.h>
#include <stdlib.h>	
#include <string.h>
#include "y.tab.h"

void errorLexico(void);
void excesoCaracteres(void);

#ifndef yywrap
static int yywrap(void) {return 1;}
#endif
%}

%option noyywrap
separador		[ \t]+
DIGITO			[0-9]
LETRAS			[a-zA-Z]
ID	{LETRAS}({LETRAS}|{DIGITO})*

%%
{separador}     { /* Ignoramos los separadores */ }

"inicio"        {return(INICIO);}
"fin"           {return(FIN);}
"leer"          {return(LEER);}
"escribir"      {return(ESCRIBIR);}

{DIGITO}+	    { yylval.num=atoi(yytext); return(CONSTANTE);}
{ID} 			{   if(strlen(yytext) >= 32) {
						excesoCaracteres();
					} else {
						yylval.caracteres = strdup(yytext);	
						return (IDENTIFICADOR);
					}
				}
":="            {return(ASIGNACION);}
","             {return(COMA);}
";"             {return(PUNTOYCOMA);}
"+"             {return(SUMA);}
"-"             {return(RESTA);}
"("             {return(ABRIR_PARENTESIS);}
")"             {return(CERRAR_PARENTESIS);}
.				{errorLexico();}
%%
void errorLexico(void){
   printf("ERROR LÉXICO: caracter \"%s\" inválido.\n", yytext);
}
void excesoCaracteres(void){
	printf("ERROR SINTÁCTICO: Longitud de identificador demasiado larga\n");
}
