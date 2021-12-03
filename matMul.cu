/*
matMul.cu
author : Subed Lamichhane
Matrix multiplication
inputs: host A,B,C, n_rowA,n_colA, n_rowB, n_col_B
*/

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>


int matrix_multiply(float *A_h, float *B_h, float *C_h, int matArow,int matAcol,int matBrow, int matBcol)
{

  
    float *A_d, *B_d, *C_d;
    size_t A_sz, B_sz, C_sz;

    dim3 dim_grid, dim_block;
    cudaError_t cuda_ret;

    A_sz = matArow*matAcol;
    B_sz = matBrow*matBcol;
    C_sz = matArow*matBcol;


// Allocate device variables ----------------------------------------------

//    printf("Allocating device variables..."); 
    fflush(stdout);
//    startTime(&timer);

/*************************************************************************/

//INSERT CODE HERE

    cudaMalloc((void **) &A_d, A_sz*sizeof(float));
    cudaMalloc((void **) &B_d, B_sz*sizeof(float));
    cudaMalloc((void **) &C_d, C_sz*sizeof(float));


/*************************************************************************/

    cudaDeviceSynchronize();


// Copy host variables to device ------------------------------------------
//    printf("Copying data from host to device..."); 
    fflush(stdout);
//  startTime(&timer);

/*************************************************************************/
//INSERT CODE HERE

    cudaMemcpy(A_d, A_h, A_sz*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(B_d, B_h, B_sz*sizeof(float), cudaMemcpyHostToDevice);

/*************************************************************************/

    cudaDeviceSynchronize();
    
// Launch kernel using standard sgemm interface ---------------------------
//    printf("Launching kernel..."); 
    fflush(stdout);
//    startTime(&timer);


    basicSgemm(matArow, matBrow, matBcol, A_d, B_d, C_d);

  
    cuda_ret = cudaDeviceSynchronize();
    if(cuda_ret != cudaSuccess) printf("Unable to launch kernel");
//    stopTime(&timer); printf("%f s\n", elapsedTime(timer));

// Copy device variables from host ----------------------------------------
//    printf("Copying data from device to host..."); 
    fflush(stdout);
//    startTime(&timer);

/*************************************************************************/
//INSERT CODE HERE
    cudaMemcpy(C_h, C_d, C_sz*sizeof(float), cudaMemcpyDeviceToHost);

//    cudaDeviceSynchronize();

//    cudaMemcpy(D_h, D_d, C_sz*sizeof(float), cudaMemcpyDeviceToHost);
/*************************************************************************/

//    printf("C_h %f", C_h);
    cudaDeviceSynchronize();



   return 0;
}


