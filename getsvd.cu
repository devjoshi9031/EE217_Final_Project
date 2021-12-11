#include <stdio.h>
#include <stdlib.h> 
#include <math.h>
//#include "support.cu"
//#define DEBUG

__global__ void svd_kernel(double *A, double *V, double *U, double *sig,int m, int n){

   __shared__ double N[16][1];
   __shared__ double M[16][16];
  
//    unsigned int x = blockIdx.x * BLOCK_DIM + threadIdx.x;
//    unsigned int yIndex = blockIdx.y * BLOCK_DIM + threadIdx.y;

    unsigned int tx=threadIdx.x;
    unsigned int ty=threadIdx.y;
    unsigned int bx=blockIdx.x;
    unsigned int by=blockIdx.y;

    int row= by*blockDim.y+ty;
    int col= bx*blockDim.x+tx;
    
    for (int i=0; i<n;i++){
      double Pvalue=0.0;
      if (row<m && col<n){
		M[ty][tx]=A[(row*n+col)];
	}
	else{
		M[ty][tx]=0.0;
        }
	if (row<m){
		N[ty][i]=V[row*n+i] ;
	}
	else{
		N[ty][tx]=0.0;
	}  
       __syncthreads();

      if (row<m && col<1){
		for (int j=0;j<n;++i){
			Pvalue+=M[ty][j]*N[j][tx]/sig[j];

		}
       
	}
     
      __syncthreads();

       if (row<m){
          U[row*n+i]=Pvalue;
          }
      __syncthreads();

}


}

int rank=0;
void SVD(double *V1, double *W1, double *V2, double *U, double *Sig, double *VT,int m,int nn ){

     printf("inside SVD func");

//    float * UTr;
    
//    float *U2f;
    double *V;
    double *sig;
//    UTr=(float*)malloc(sizeof(float)*m*m);
//    U2f=(float*)malloc(sizeof(float)*m*m);
    V=(double*)malloc(sizeof(double)*nn*nn);
//    sig=(double*)malloc(sizeof(double)*nn);

    int k=nn-1;
    int l=0;
    for (int i=0; i<m; i++){
        for(int j=0;j<nn;j++){
            if (i==j&& W1[k]>0.0){
                Sig[i*nn+j]=sqrt(W1[k]);
                sig[l]=Sig[i*nn+j];
                k=k-1;
                l=l+1;
                if (Sig[i*nn+j]>0.0){rank=rank+1;}    
         }
             else{Sig[i*nn+j]=0.0;}
         }
    }
    
    rank=l;
//    for (int i=0;i<nn;i++){printf("\nsig(%d):%f\t",i,sig[i]);}
//    for (int i=0;i<m*m;i++){U2f[i]=(float)V1[i];}
//    basicTransp(m,m,U2f,UTr);
//    for (int i=0;i<m*m;i++){Ud[i]=(double)UTr[i];}

  
    k=0;
    for (int i=0;i<m;i++){
        for (int j=m-1;j>=0;j--){
            U[i*m+j]=V1[i+m*k];
            k=k+1;
        }
        k=0;
    }
//
//
//    k=0;
//    
//    for (int i=0;i<nn*nn;i++){V2f[i]=(float)V2[i];}
//    basicTransp(nn,nn,V2f,VTd);
//    for (int i=0;i<nn*nn;i++){VTr[i]=(double)VTd[i];}

//    printMatrix(nn,nn,VTr,nn,"VTr");


    


    for (int i=nn-1;i>=0;i--){
        for (int j=0;j<nn;j++){
            VT[i*nn+j]=V2[k*nn+j];
            V[i*nn+j]=V2[i+nn*j];
       }
        k=k+1;
    }
     
//    int gridx,gridy;
//
//    gridx=ceil(nn/16.0);
//    gridy=ceil(m/16.0);
//
//    dim3 DimGrid(gridx,gridy,1); 
//    dim3 DimBlock(16,16,1);
//
//    svd_kernel<<<DimGrid,DimBlock>>>(A,V,U,sig,m,nn);

//    free(UTr);free(U2f);free(Ud);

}  







void compressed(double *U, double *Sig, double *VT, double *Mc,int m, int nn,int r){


  float *Uf;
  float *Sigf;
  float *VTf;
  float *Mf;
  float *Mtf;
  r=rank;
  Uf=(float*)malloc(sizeof(float)*m*m);
  Sigf=(float*)malloc(sizeof(float)*m*nn); 
  VTf=(float*)malloc(sizeof(float)*nn*nn);
  Mf=(float*)malloc(sizeof(float)*m*nn);
  Mtf=(float*)malloc(sizeof(float)*r*nn); 
//  float Mcf[r*r];

  
//  for(int i=0;i<m*m;i++){Uf[i]=(float)U[i];}

//  for(int i=0;i<m*nn;i++){Sigf[i]=(float)Sig[i];} 
//  for(int i=0;i<nn*nn;i++){VTf[i]=(float)VT[i];}
//  for(int i=0;i<m*nn;i++){Mf[i]=(float)M[i];}
//  for(int i=0;i<m*nn;i++){Mcf[i]=(float)Mc[i];}

  for (int i=0;i<m;i++){
     for(int j=0;j<r;j++){
        Uf[i*r+j]=(float)U[i*r+j+(m-r)*i];
     }
  }

  for (int i=0;i<r;i++){
     for(int j=0;j<nn;j++){
        VTf[i*nn+j]=(float)VT[i*nn+j];
     }
  }
 
  for (int i=0;i<r;i++){
     for(int j=0;j<r;j++){

        Sigf[i*r+j]=(float)Sig[i*nn+j];
     }
  }

//  #ifdef DEBUG

  printf("\nrank:  %d", r);
//
  printf("\n");
  printMatrixFloat(m,r,Uf,r,"Uf");
//
  printf("\n");
  printMatrixFloat(r,r,Sigf,r,"Sigf");
//
  printf("\n");
  printMatrixFloat(r,nn,VTf,nn,"VTf");
//  #endif 


  matrix_multiply(Sigf,VTf,Mtf,r,r,r,nn);
 
//  #ifdef DEBUG
//  printf("\n");
//  printMatrixFloat(r,nn,Mtf,nn,"Mtf");
//  #endif
 
  matrix_multiply(Uf,Mtf,Mf,m,r,r,nn);

//  #ifdef DEBUG 
//  printf("\n");
//  printMatrixFloat(m,nn,Mf,nn,"Mf");
//  #endif

  for (int i=0;i<m*nn;i++){Mc[i]=(double)Mf[i];}
  
  free(Uf);free(Sigf);free(VTf);free(Mf);free(Mtf);  

}


float rmse(double *M1, int row, int col){

  float square=0;
  float sum=0;
  float mean=0;
  float rms=0;

  for(int i=0; i<row;i++){
     for(int j=0;j<col;j++){
           square=M1[i*col+j]*M1[i*col+j];
//           printf("\n%f",square);
           sum=sum+square;
     }

   }

//   printf("\n%f",sum);
   mean=sum/(row*col);
//   printf("\nmean:%f",mean);
   rms=sqrt(mean);
//   printf("\nrms: %f",rms);
   return rms; 

}
   
