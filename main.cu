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
#include <math.h>
#include "getsvd.cu"
#include "svdcalc.cu"
#include "imageread.c"
////Matrix Print ; not working as expected right now
//void printMatrixFloat(int m, int n, const float*A, int lda, const char* name)
//{
//    for(int row = 0 ; row < m ; row++){
//        printf("\n");
//        for(int col = 0 ; col < n ; col++){
//            float Areg = A[row*lda + col];
//            printf("%s(%d,%d) = %f\t", name, row+1, col+1, Areg);
//        }
//    }
//}


//#define DEBUG
int main(int argc, char*argv[])
{

   Timer timer;

   float *M;
   int row=4;
   int  col=3;
   int M_sz=row*col;
   float image_part1[M_sz];

   int rocol[2];

//   readarray(image_part1,rocol);

//   printf("\nrow and column \t");

//   for (int i=0; i<2;i++){printf("%d\t",rocol[i]);}  

//   size_t n = sizeof(image_part1)/sizeof(image_part1[0]);
//   printf("\n Number of elements: %d",n); 

//  printf("\n image part\n");
 
//   for(int i=0; i<rocol[0]-1; i++){
//        for(int j=0; j<rocol[1]; j++){
//         printf("%f ", image_part1[i*rocol[1]+j]);
//        }
//        printf("\n");
//    }


   int lower=0;int upper=255;

   M = (float*) malloc( sizeof(float)*M_sz );

//  for (unsigned int i=0; i < M_sz; i++) { M[i] = (rand()%(upper-lower+1)/1.0)+lower; }


   M[0] =1.0;
   M[1] =2.0;
   M[2] =3.0;
   M[3] =2.0;
   M[4] =3.0;
   M[5] =4.0;
   M[6] =3.0;
   M[7] =4.0;
   M[8] =5.0;
   M[9] =4.0;
   M[10] =5.0;
   M[11] =6.0;
 
   int m=row;
   int nn=col;
   int r=3; 
   double *Mc;
   double *Sig;
   double *U;
   double *VT;

   float rms=0.0; 
 
   Mc=(double*)malloc(sizeof(double)*m*nn);
   Sig=(double*)malloc(sizeof(double)*m*nn);
   U=(double*)malloc(sizeof(double)*m*m);
   VT=(double*)malloc(sizeof(double)*nn*nn);   

   startTime(&timer); 
   svdCalc(M,row,col,U,Sig,VT);   
  
   stopTime(&timer); printf("%f s\n", elapsedTime(timer)); 

   compressed(U,Sig,VT,Mc,m,nn,r);   
   
//   stopTime(&timer); printf("%f s\n", elapsedTime(timer));
  
   
   printf("Compressing........ \n");
//   printMatrix(m,nn,Mc,nn,"Mc");

   double diff[m*nn];

   for(int i=0;i<M_sz;i++){diff[i]=(double)M[i]-Mc[i];}


   printf("\n");
//   printMatrix(m,nn,diff,nn,"diff");

   float  eper;

   rms=rmse(diff,m,nn);
   eper=rms/upper*100;

   printf("\n rms: %f , error percent: %f\n",rms,eper);


   free(Mc);free(Sig);free(U);free(VT);


////   float *A_d, *B_d, *C_d,*D_d;
//    size_t A_sz, B_sz, C_sz,D_sz;
//    unsigned matArow, matAcol;
//    unsigned matBrow, matBcol;
////  dim3 dim_grid, dim_block;
////  cudaError_t cuda_ret;
//    double *C_hd,*D_hd;
//
//    int mm,n,k;
//
//    matArow=2;
//    matAcol=3;
//    matBrow=matAcol;
//    matBcol=matArow;
//
//    A_sz = matArow*matAcol;
//    B_sz = matBrow*matBcol;
//    C_sz = matArow*matBcol;
//    D_sz = matBrow*matAcol;
// 
//// toy matrices initialization
//   A_h = (float*) malloc( sizeof(float)*A_sz );
//
//
//    A_h[0] =1.0;
//    A_h[1] =2.0;
//    A_h[2] =3.0;
//    A_h[3] =2.0;
//    A_h[4] =3.0;
//    A_h[5] =4.0;
//
//// B is A transpose
//    B_h = (float*) malloc( sizeof(float)*B_sz );
//    
//
////    B_h[0] =1.0;
////    B_h[1] =2.0;
////    B_h[2] =2.0;
////    B_h[3] =3.0;
////    B_h[4] =3.0;
////    B_h[5] =4.0;
//
//    basicTransp(matArow,matAcol,A_h,B_h);
//
//// C_hd and D_hd are double version of C_h and D_h
//
//    C_h = (float*) malloc( sizeof(float)*C_sz );
//    C_hd = (double*) malloc( sizeof(double)*C_sz );
//
//    D_h = (float*) malloc( sizeof(float)*D_sz );
//    D_hd = (double*) malloc( sizeof(double)*D_sz );
//
//
//    printMatrixFloat(matArow, matAcol, A_h, matAcol, "A");
//    printf("\n");
//    printMatrixFloat(matBrow, matBcol, B_h, matBcol, "B");
//
//
//    mm=matArow;
//    n=matAcol;
//    k=matBcol;
//
//// matric multiplication for AA' or vice versa
//    matrix_multiply(A_h,B_h,C_h,mm,n,n,k);
//  
//   
//    mm=matAcol;
//    n=matArow;
//    k=matBrow;
//
//// matrix multiplication for A'A
//    matrix_multiply(B_h,A_h,D_h,mm,n,n,k);
//
//
//    for (int i=0;i<C_sz;i++){C_hd[i]=(double)C_h[i];}
//    for (int i=0;i<D_sz;i++){D_hd[i]=(double)D_h[i];}
//
//    printf("\nresulting matrix AA'  in double format is \n");
//    printMatrix(matArow, matBcol, C_hd, matArow, "C");     
//
//    printf("\nresulting matrix A'A  in double format is \n");
//    printMatrix(matBrow, matAcol, D_hd, matBrow, "D");    
//
//    
//// cusolver call starts
//
//    int  m= matArow;
//    int lda=m;
////    double lambda[m] = {22,2};
//    double V1[lda*m]; // eigenvectors
//    double W1[m]; // eigenvalues
//   
//// C_hd is the matrix input, W gives diagonal eigen value matrix and V gives right eigen vectors
//    printf("\n Eigen decomposition for AA'\n");
//    solver_eigen(C_hd,W1,V1,m);
//
//    int nn=matAcol;
//    lda=nn;
//    double V2[lda*nn]; // eigenvectors
//    double W2[nn]; // eigenvalues
//
//// C_hd is the matrix input, W gives diagonal eigen value matrix and V gives right eigen vectors
//    printf("\n Eigen decomposition for A'A \n");
//    solver_eigen(D_hd,W2,V2,nn);
//   
////    double S[m*nn];
////    k=nn-1;
////    for (int i=0; i<m; i++){
////        for(int j=0;j<nn;j++){
////            if (i==j){
////                S[i*nn+j]=sqrt(W2[k]);
////                k=k-1;
////            } 
////        }   
////    }
////   
//////   printMatrix(1,nn,W2,nn,"W2"); 
////   printf("\n the singular values matrix is \n");
////   printMatrix(m,nn,S,nn,"S");
////   printf("\n");
//
//   printf("\n Extrcting USigVT \n");
//
//   double Sig[m*nn];
//   double U[m*m];
//   double VT[nn*nn];
//
//   SVD(V1,W1,V2,U,Sig,VT,m,nn);
//
//   printf("\n Left  Singular Matrix U\n");
//   printMatrix(m,m,U,m,"U");
//
//   printf("\n Singular values  Matrix Sig \n");
//   printMatrix(m,nn,Sig,nn,"Sig");
//
//   printf("\n Right  Singular Matrix U\n");
//   printMatrix(nn,nn,VT,nn,"VT");


 
    return 0;
}


