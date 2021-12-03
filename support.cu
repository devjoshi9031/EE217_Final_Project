#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>

#include "support.h"

//void verify(float *A, float *B, float *C, unsigned int n) {
//
//  const float relativeTolerance = 1e-2;
//
//  for(int i = 0; i < n; ++i) {
//      float sum = A[i]+B[i];
//      printf("\t%d:%f/%f",i,sum,C[i]);
//      float relativeError = (sum - C[i])/sum;
//      if (relativeError > relativeTolerance
//        || relativeError < -relativeTolerance) {
//        printf("\nTEST FAILED\n\n");
//        exit(0);
//      }
//  }
//  printf("\nTEST PASSED\n\n");
//
//}

void startTime(Timer* timer) {
    gettimeofday(&(timer->startTime), NULL);
}

void stopTime(Timer* timer) {
    gettimeofday(&(timer->endTime), NULL);
}

float elapsedTime(Timer timer) {
    return ((float) ((timer.endTime.tv_sec - timer.startTime.tv_sec) \
                + (timer.endTime.tv_usec - timer.startTime.tv_usec)/1.0e6));
}


void printMatrix(int m, int n, const double*A, int lda, const char* name)
{
    for(int row = 0 ; row < m ; row++){
        printf("\n");
        for(int col = 0 ; col < n ; col++){
            double Areg = A[row*lda+ col];
            printf("%s(%d,%d) = %f\t", name, row+1, col+1, Areg);
        }
    }
}

