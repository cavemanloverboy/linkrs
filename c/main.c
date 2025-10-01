#include <stdio.h>

typedef unsigned long ulong;

extern long kv_add( ulong a, ulong b);
extern long kv_sub( ulong a, ulong b);


int
main( void ) {
    ulong a = 10;
    ulong b = 5;
    
    /* results */
    ulong r1 = kv_add( a, b );
    ulong r2 = kv_sub( a, b );

    printf( "results:\n    add(%lu, %lu)=%lu\n    sub(%lu, %lu)=%lu\n", a, b, r1, a, b, r2 );
}
