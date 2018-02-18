#include <stdlib.h>
#include <sys/alt_stdio.h>
#include <sys/alt_alarm.h>
#include <sys/times.h>
#include <alt_types.h>
#include <system.h>
#include <stdio.h>
#include <unistd.h>
#include <math.h>
#define ALT_CI_FP_MULT_1(A,B) __builtin_custom_fnff(ALT_CI_FP_MULT_0_N,(A),(B))
#define ALT_CI_FP_ADDER_1(n,A,B) __builtin_custom_fnff(ALT_CI_FP_ADDER_0_N+(n&ALT_CI_FP_ADDER_0_N_MASK),(A),(B))

//Test case	1
#define step 5
#define N 52

//Test case 2
//#define step 0.1
//#define N 2551 //stops somewhere between 1500 and 2000 w/ 40kB memory, default value = 2551

//Test case 3
//#define step 0.001
//#define N	255001

//Generates	the	vector x and stores	it in the memory
void generateVector(float x[])
{
	int i;
	x[0] = 0.0;
	for (i=1; i<N; i++)
		x[i] = x[i-1] + step;
}

float sumVector(float x[])
{
	float at, m1, m2, a1, a2=0;
	int i;
	for(i = 0; i<N; i++){
		at=atan(floor(x[i]/4)-32);
		m1 = ALT_CI_FP_MULT_1(x[i],x[i]);
		m2 = ALT_CI_FP_MULT_1( at, m1);
		a1 = ALT_CI_FP_ADDER_1(1, x[i], m2);
		a2 = ALT_CI_FP_ADDER_1(1, a1, a2);
	}
	return a2;
}

int main()
		{
		float y;
		char buf[50];
		clock_t exec_t1, exec_t2;
		float x[N];
		int i;

		alt_putstr("N\ttime\tresult\n");
		generateVector(x);

		exec_t1	= times(NULL);
		y = sumVector(x);
		exec_t2	= times(NULL);

		gcvt( i, 10, buf);
		alt_putstr(buf);alt_putstr("\t");

		gcvt((exec_t2 - exec_t1),	10,	buf);
		alt_putstr(buf); alt_putstr("\t");

		gcvt( y, 10, buf);
		alt_putstr(buf);alt_putstr("\n");

	return 0;
}
