%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
int yyerror();

void asignar(char * nombre, int valor);
void leer_id(char * nombre);
int  devolverValor(char * nombre);
%}

%union {
	int num;
	char* caracteres;
}

%token  <num> CONSTANTE
%token  SUMA    RESTA   NL  FDT
%token  PABIERTO	PCERRADO   IDENTIFICADOR 
%token  INICIO  FIN  LEER  ESCRIBIR  ASIGNACION  COMA PUNTOYCOMA

%left   SUMA    RESTA	COMA
%right  ASIGNACION	

%type <num> expresion primaria
%type <caracteres> IDENTIFICADOR sentencia

%start objetivo

%%
/* <objetivo> -> <programa> FDT #terminar */
objetivo : programa FDT {exit(0);};

/* <programa> -> #comenzar inicio <listaSentencias> fin */
programa : INICIO FIN 					{exit(0);}
		 |  INICIO listaSentencias FIN 	{}
;

/* <listaSentencias> -> <sentencia> {<sentencia>} */
listaSentencias : listaSentencias sentencia		{}
				| sentencia						{}
;

/* <sentencia> -> <identificador> := <expresion> #asignar; 	| 
				  leer(<listadeIndentificadores>); 			|
				  escribir(<listaExpresiones>); */
sentencia : IDENTIFICADOR ASIGNACION expresion PUNTOYCOMA 				{printf("\nIdentificada operacion de asignacion\n%s:=%d;",$1,$3);asignar($1, $3); }
		  | LEER PABIERTO listado PCERRADO PUNTOYCOMA					{printf("\nIdentificada operacion de lectura\n");}
		  | ESCRIBIR PABIERTO listaExpresiones PCERRADO PUNTOYCOMA		{printf("\nIdentificada operacion de escritura\n");}
;

/* <listado> -> <identificador> #leer_id {, <identificador> #leer_id} */
listado : listado COMA IDENTIFICADOR 	{leer_id($3);}
		| IDENTIFICADOR					{leer_id($1);}
;

/* <listaExpresiones> -> <expresion> #escribir_exp 
					  {, <expresion> #escribir_exp} */
listaExpresiones : listaExpresiones COMA expresion 	{printf(", %d", $3);}
				 | expresion						{printf("%d", $1);}
;			

/* <expresion> -> <primaria> 
				  {<operadorAditivo> <primaria> #gen_infijo} */
expresion :	primaria					{$$ = $1;}
		  | primaria SUMA expresion		{$$ = $1 + $3;}
		  | primaria RESTA expresion	{$$ = $1 - $3;}
;

/* <primaria> -> <identificador> 		 |
				 CONSTANTE #procesar_cte | 
				 <expresion> */
primaria : IDENTIFICADOR 				{$$ = devolverValor($1);}
		 | CONSTANTE 					{$$ = $1;}
		 | PABIERTO expresion PCERRADO 	{$$ = $2;}
;

/* <operadorAditivo> -> SUMA #procesar_op |
						RESTA #procesar_op */
operadorAditivo : SUMA 	{$$ = '+';}  
				| RESTA {$$ = '-';}
;
%%
FILE *yyin;
#define largo 33

typedef struct Identificador {
		char nombre[largo]; //nombre de la variable
		int valor;		    //valor de la variable
} Identificador;

Identificador listado[500]; //Armo una lista de identificadores para irlos guardando ahi
int tope = 0; //me dice cuantos identificadores tengo en la lista
int buscar(char* nombre);
void asignar(char* nombre, int valor);
void leer_id(char* nombre);
int devolverValor(char* nombre);


int yyerror(char* s) {
	if(!strcmp(s, "syntax error")) printf("Error: Error de sintaxis.\n");
	else	printf("Error: %s.\n", s);
	exit(-1);
}

int buscar(char* nombre) {
	int i;
	for(i = 0; i < tope; i++) {
		if(!strcmp(listado[i].nombre, nombre)){
			return i;
		}
	}
	return -1;
}

int devolverValor(char* nombre) {
	int indice = buscar(nombre);
	if(indice < 0) { 
		yyerror("ERROR! Aun no se encuentra definido el identificador %s", nombre); 
	}
	return (listado[indice].valor);
}

void asignar(char* nombre, int valor) {	
	int indice = buscar(nombre);
	if(indice < 0) { // el identificador no esta en el listado
		//Lo agrego al final
		strcpy(listado[tope].nombre, nombre);
		listado[tope].valor = valor;
		tope++;
	} 
	else { //El identificador estaba en el listado
		listado[indice].valor = valor;	//cambio su valor
	}	
}

void leer_id(char* nombre) {
	int aux;
	printf("ingrese valor para %s: ", nombre);
	scanf("%d",&aux); 
	asignar(nombre, aux);	
}

int main(int argc, char* argv[]) {
	int menu = 0;
	char file [30];
	if(argc == 1) {
		printf("Ingrese 1 para escribir el nombre del archivo que desea abrir\n");
		printf("Ingrese 2 para escribir el codigo micro de forma manual. (no olvides comenzar con 'inicio' y terminar con 'fin'\n OPCION: ");
		scanf("%d", &menu);

		while (menu != 0) {
			if(menu == 1){
				printf("archivo: ");
				scanf("%s", file);
				if((yyin=fopen(file,"rb"))){
					yyparse();
				} else {
					printf("Error al abrir el archivo %s\n", file);
				}
			}
			else if (menu == 2) {
				printf("Ingrese el codigo micro:\n");
				yyparse();
			}
			else {
				printf("Opcion invalida! ingrese 0 para salir, 1 para el ingresar el codigo a traves de un archivo, y 2 para ingresarllo de forma manual\n");
			}
		}
	} 

	else if (argc == 2){
		if((yyin=fopen(argv[1],"rb"))){
			yyparse();
		} else {
			printf("Error al abrir el archivo %s\n", argv[1]);
		}
	}

	else {
		printf("Error en los argumentos del main!");
		return 0;
	}
}


