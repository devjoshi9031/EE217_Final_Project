#include <stdio.h>

#define TILE_SIZE 16

__global__ void mysgemm(int m, int n, int k, const float *A, const float *B, float* C) {

    /********************************************************************
     *
     * Compute C = A x B
     *   where A is a (m x k) matrix
     *   where B is a (k x n) matrix
     *   where C is a (m x n) matrix
     *
     * Use shared memory for tiling
     *
     ********************************************************************/

    /*************************************************************************/
    // INSERT KERNEL CODE HERE

     __shared__  float M[TILE_SIZE][TILE_SIZE];
     __shared__  float N[TILE_SIZE][TILE_SIZE];

     unsigned int tx=threadIdx.x;
     unsigned int ty=threadIdx.y;
     unsigned int bx=blockIdx.x;
     unsigned int by=blockIdx.y;

     int row= by*blockDim.y+ty;
     int col= bx*blockDim.x+tx;

     float Pvalue=0.0;
     int phases;
     phases=(TILE_SIZE+n-1)/TILE_SIZE;  
     for (int p=0;p<phases;p++){
//        Pvalue=0;
	if (row<m && (p*TILE_SIZE+tx)<n){
		M[ty][tx]=A[(row*n+p*TILE_SIZE+tx)];
	}
	else{
		M[ty][tx]=0.0;
        }
	if ((p*TILE_SIZE+ty)<n && col<k){
		N[ty][tx]= B[(p*TILE_SIZE+ty)*k+col];
	}
	else{
		N[ty][tx]=0.0;
	}
	__syncthreads();

	if (row<m && col<k){
		for (int i=0;i<TILE_SIZE;++i){
			Pvalue+=M[ty][i]*N[i][tx];
		}
	}
	__syncthreads();

    }
    if (row< m && col< k){
	C[row*k+col]=Pvalue;
    }
     
        
    /*************************************************************************/
}

void basicSgemm(int m, int n, int k, const float *A, const float *B, float *C){
    // Initialize thread block and kernel grid dimensions ---------------------

//    const unsigned int BLOCK_SIZE = TILE_SIZE;
	
    /*************************************************************************/
    //INSERT CODE HERE
//    int max=0,max_mn=0;

    int gridx,gridy;
//    max_mn=(m>n)? m:n;
//    max=(max_mn>k)? max_mn:k;
//    dim3 dimGrid.x(ceil(max/TILE_SIZE));
 //   dim3 dimGrid.y(ceil(max/TILE_SIZE));
    
    gridx=ceil(k/16.0);
    gridy=ceil(m/16.0);
 
//    printf("k  %d, gridx %d  gridy %d    ",k,gridx,gridy);
    dim3 DimGrid(gridx,gridy,1); 
    dim3 DimBlock(16,16,1);


    /*************************************************************************/

    // Invoke CUDA kernel -----------------------------------------------------

    /*************************************************************************/
    //INSERT CODE HERE

     mysgemm<<<DimGrid,DimBlock>>>(m,n,k,A,B,C);
	
    /*************************************************************************/
}


