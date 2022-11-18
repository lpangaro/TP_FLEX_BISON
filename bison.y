%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int yylex();
int yyerror();

void asignar(char * nombre, int valor);
void leer_id(char * nombre);
void escribir_exp(int valor);

%}

%union {
	int num;
	char* caracteres;
}

%token  <num> CONSTANTE
%token  SUMA    RESTA   NL  FDT
%token  ABRIR_PARENTESIS	CERRAR_PARENTESIS   IDENTIFICADOR 
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
		 | INICIO listaSentencias FIN 	{exit(0);}
;

/* <listaSentencias> -> <sentencia> {<sentencia>} */
listaSentencias : listaSentencias sentencia		{}
				| sentencia						{}
;

/* <sentencia> -> <identificador> := <expresion> #asignar; 	| 
				  leer(<listadeIndentificadores>); 			|
				  escribir(<listaExpresiones>); */
sentencia : IDENTIFICADOR ASIGNACION expresion PUNTOYCOMA 								{printf("Asignacion\n"); asignar($1, $3);}
		  | LEER ABRIR_PARENTESIS listaIdentificadores CERRAR_PARENTESIS PUNTOYCOMA		{printf("Lectura\n");}
		  | ESCRIBIR ABRIR_PARENTESIS listaExpresiones CERRAR_PARENTESIS PUNTOYCOMA		{printf("Escritura\n");}
;

/* <listaIdentificadores> -> <identificador> #leer_id {, <identificador> #leer_id} */
listaIdentificadores : listaIdentificadores COMA IDENTIFICADOR 	{leer_id($3);}
					 | IDENTIFICADOR							{leer_id($1);}
;

/* <listaExpresiones> -> <expresion> #escribir_exp 
					  {, <expresion> #escribir_exp} */
listaExpresiones : listaExpresiones COMA expresion 	{escribir_exp($3);}
				 | expresion						{escribir_exp($1);}
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
primaria : IDENTIFICADOR 								{leer_id($1);} //imprimo el valor del identificador
		 | CONSTANTE 									{$$ = $1;}
		 | ABRIR_PARENTESIS expresion CERRAR_PARENTESIS {$$ = $2;}
;

/* <operadorAditivo> -> SUMA #procesar_op |
						RESTA #procesar_op 
operadorAditivo : SUMA 	{$$ = procesar_op($1);}  
				| RESTA {$$ = procesar_op($1);}
;*/
%%
FILE *yyin;
#define largo 33

typedef struct Identificador {
		char nombre[largo]; //nombre de la variable
		int valor;		    //valor de la variable
} Identificador;

Identificador buffer[500]; //Armo una lista de identificadores para irlos guardando ahi
int tope = 0; //me dice cuantos identificadores tengo en la lista
int buscar(char* nombre);
void asignar(char* nombre, int valor);
void escribir_exp(int valor);
void leer_id(char* nombre);
char procesar_op(char operador);
void listarIdentificadores (void);

/*char procesar_op(char operador){
	if(operador == '+')
		return '+';

	return '-';
}*/


int yyerror(char* s) {
	if(!strcmp(s, "syntax error"))
		printf("Error de sintaxis.\n");

	else
		printf("Error: %s.\n", s);
	exit(-1);
}

int buscar(char* nombre) {
	int i;
	for(i = 0; i < tope; i++) {
		if(!strcmp(buffer[i].nombre, nombre)){
			return i;
		}
	}
	return -1;
}

void asignar(char* nombre, int valor) {	
	int indice = buscar(nombre);
	if(indice < 0) { // el identificador no esta en el buffer
		//Lo agrego al final
		strcpy(buffer[tope].nombre, nombre);
		buffer[tope].valor = valor;
		tope++;
	} 
	else { //El identificador estaba en el buffer
		buffer[indice].valor = valor;	//cambio su valor
	}	
}

void leer_id(char* nombre) {
	int indice = buscar(nombre);
	if(indice < 0) { 
		printf("ERROR SEMANTICO! Aun no se encuentra definido el identificador %s\n", nombre); 
	}
	else{
		printf("%s = %d\n", nombre, buffer[indice].valor);
	}
}

void listarIdentificadores(){
	int i;
	printf("Los Identificadores declarados son:\n");
	for(i=0; i<tope; i++) {
		leer_id(buffer[i].nombre);
	}
}

void escribir_exp(int valor) {
	char nombre[largo];
	listarIdentificadores();
	printf("A que identificador le quiere asignar el valor %d (puede ser uno nuevo o reescribir uno de los anteriores): ", valor);
	scanf("%s", nombre);

	asignar(nombre, valor);
}

int main(int argc, char* argv[]) {
	int menu = 0;
	char file [30];
	if(argc == 1) {
		system("clear");
		printf("Ingrese 1 para escribir el nombre del archivo que desea abrir\n");
		printf("Ingrese 2 para escribir el codigo micro. (no olvides comenzar con 'inicio' y terminar con 'fin'\n OPCION: ");
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
				printf("Opcion invalida! \n0) para salir, \n1) para el ingresar el codigo a traves de un archivo, \n2) para ingresarlo de forma manual\n");
			}
		}
	} 

	else if (argc == 2){
		if((yyin=fopen(argv[1], "rb"))){
			yyparse();
		} else {
			printf("Error al abrir el archivo %s\n", argv[1]);
		}
	}

	else {
		printf("Error en los argumentos del main!");
	}

return 0;
}


