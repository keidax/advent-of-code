#include <stdlib.h>
#include <stdio.h>

int main() {
    int * last_spoken = malloc(sizeof(int) * 30000000);
    last_spoken[11] = 0;
    last_spoken[18] = 1;
    last_spoken[0]  = 2;
    last_spoken[20] = 3;
    last_spoken[1]  = 4;
    last_spoken[7]  = 5;
    last_spoken[16] = 6;

    int i = 7;
    int last = 16;
    int prev_turn = 0;

    while(i < 30000000) {
	prev_turn = last_spoken[last];
	last_spoken[last] = i - 1;

	if(prev_turn >= 0) {
	    last = (i - prev_turn - 1);
	} else {
	    last = 0;
	}

	i++;
    }

    printf("%i\n", i);

    free(last_spoken);
}
