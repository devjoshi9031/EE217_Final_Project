#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <cuda_runtime.h>
#include <cusolverDn.h>
#include "kernel.cu"
#include "support.cu"
#include "getEigen.cu"
#include "matMul.cu"
#include "transpose.cu"


//Matrix Print ; not working as expected right now
void printMatrixFloat(int m, int n, const float*A, int lda, const char* name)
{
    for(int row = 0 ; row < m ; row++){
        printf("\n");
        for(int col = 0 ; col < n ; col++){
            float Areg = A[row*lda + col];
            printf("%s(%d,%d) = %f\t", name, row+1, col+1, Areg);
        }
    }
}



int main(int argc, char*argv[])
{

   float *A_h,*B_h,*C_h,*D_h;
//   float *A_d, *B_d, *C_d,*D_d;
    size_t A_sz, B_sz, C_sz,D_sz;
    unsigned matArow, matAcol;
    unsigned matBrow, matBcol;
//  dim3 dim_grid, dim_block;
//  cudaError_t cuda_ret;
    double *C_hd,*D_hd;

    int mm,n,k;

    matArow=2;
    matAcol=3;
    matBrow=matAcol;
    matBcol=matArow;

    A_sz = matArow*matAcol;
    B_sz = matBrow*matBcol;
    C_sz = matArow*matBcol;
    D_sz = matBrow*matAcol;
 
// toy matrices initialization
   A_h = (float*) malloc( sizeof(float)*A_sz );


    A_h[0] =1.0;
    A_h[1] =2.0;
    A_h[2] =3.0;
    A_h[3] =2.0;
    A_h[4] =3.0;
    A_h[5] =4.0;

// B is A transpose
    B_h = (float*) malloc( sizeof(float)*B_sz );
    

//    B_h[0] =1.0;
//    B_h[1] =2.0;
//    B_h[2] =2.0;
//    B_h[3] =3.0;
//    B_h[4] =3.0;
//    B_h[5] =4.0;

    basicTransp(matArow,matAcol,A_h,B_h);

// C_hd and D_hd are double version of C_h and D_h

    C_h = (float*) malloc( sizeof(float)*C_sz );
    C_hd = (double*) malloc( sizeof(double)*C_sz );

    D_h = (float*) malloc( sizeof(float)*D_sz );
    D_hd = (double*) malloc( sizeof(double)*D_sz );


    printMatrixFloat(matArow, matAcol, A_h, matAcol, "A");
    printf("\n");
    printMatrixFloat(matBrow, matBcol, B_h, matBcol, "B");


    mm=matArow;
    n=matAcol;
    k=matBcol;

// matric multiplication for AA' or vice versa
    matrix_multiply(A_h,B_h,C_h,mm,n,n,k);
  
   
    mm=matAcol;
    n=matArow;
    k=matBrow;

// matrix multiplication for A'A
    matrix_multiply(B_h,A_h,D_h,mm,n,n,k);


    for (int i=0;i<C_sz;i++){C_hd[i]=(double)C_h[i];}
    for (int i=0;i<D_sz;i++){D_hd[i]=(double)D_h[i];}

    printf("\nresulting matrix AA'  in double format is \n");
    printMatrix(matArow, matBcol, C_hd, matArow, "C");     

    printf("\nresulting matrix A'A  in double format is \n");
    printMatrix(matBrow, matAcol, D_hd, matBrow, "D");    

    
// cusolver call starts

    int  m= matArow;
    int lda=m;
//    double lambda[m] = {22,2};
    double V[lda*m]; // eigenvectors
    double W[m]; // eigenvalues
   
// C_hd is the matrix input, W gives diagonal eigen value matrix and V gives right eigen vectors
    solver_eigen(C_hd,W,V,m);

    return 0;
}


