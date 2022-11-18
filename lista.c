#include <stdio.h>
#include <stdlib.h>

int main() {
	int lista [100];
	int i;
	lista[0] = 1;
	lista[1] = 2;
	lista[2] = 3;

	for(i=0; lista[i]!=NULL; i++){
		printf("valor %d", lista[i]);
	}

	return 0;
}