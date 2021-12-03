#include <stdio.h>

#define TILE_DIM 16
#define BLOCK_DIM 16



__global__ void myTransp(float *odata, float *idata, int width, int height)
{
	__shared__ float block[BLOCK_DIM][BLOCK_DIM+1];
	
	// read the matrix tile into shared memory
        // load one element per thread from device memory (idata) and store it
        // in transposed order in block[][]
	unsigned int xIndex = blockIdx.x * BLOCK_DIM + threadIdx.x;
	unsigned int yIndex = blockIdx.y * BLOCK_DIM + threadIdx.y;
	if((xIndex < width) && (yIndex < height))
	{
		unsigned int index_in = yIndex * width + xIndex;
		block[threadIdx.y][threadIdx.x] = idata[index_in];
	}

        // synchronise to ensure all writes to block[][] have completed
	__syncthreads();

	// write the transposed matrix tile to global memory (odata) in linear order
	xIndex = blockIdx.y * BLOCK_DIM + threadIdx.x;
	yIndex = blockIdx.x * BLOCK_DIM + threadIdx.y;
	if((xIndex < height) && (yIndex < width))
	{
		unsigned int index_out = yIndex * height + xIndex;
		odata[index_out] = block[threadIdx.x][threadIdx.y];
	}
}


void basicTransp(int k, int m,float *A, float *B){

    float *A_d, *B_d ;
    size_t A_sz, B_sz;

//    dim3 dim_grid, dim_block;
    cudaError_t cuda_ret;

    A_sz = m*k;
    B_sz = k*m;
    int gridx,gridy;

    fflush(stdout);
    
    cudaMalloc((void **) &A_d, A_sz*sizeof(float));
    cudaMalloc((void **) &B_d, B_sz*sizeof(float));

    cudaDeviceSynchronize();

    cudaMemcpy(A_d, A, A_sz*sizeof(float), cudaMemcpyHostToDevice);
//    cudaMemcpy(B_d, B_h, B_sz*sizeof(float), cudaMemcpyHostToDevice);

    cudaDeviceSynchronize();

    gridx=ceil(m/16.0);
    gridy=ceil(k/16.0);

//    printf("gridx : %d , gridy: %d",gridx,gridy);

    dim3 DimGrid(gridx,gridy,1); 
    dim3 DimBlock(16,16,1);


// Invoke CUDA kernel -----------------------------------------------------

    myTransp<<<DimGrid,DimBlock>>>(B_d,A_d,m,k);
	
   
    cuda_ret = cudaDeviceSynchronize();
    if(cuda_ret != cudaSuccess) printf("Unable to launch kernel");

    fflush(stdout);
    
    cudaMemcpy(B, B_d, B_sz*sizeof(float), cudaMemcpyDeviceToHost);
    cudaDeviceSynchronize();
   
     

 
}


