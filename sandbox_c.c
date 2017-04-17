#include <stdio.h>
#include <stdlib.h>

extern int asm_called(int, int);
int c_callee(int i, int j, char * str)
{


    char c;

    scanf("%c", &c);

	int ret = asm_called(i, j);

	printf("i:(%d), j:(%d), ret:(%d), str:(%s)", i, j, ret, str);

	return ret;
}

