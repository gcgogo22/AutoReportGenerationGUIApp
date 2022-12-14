
/*

  imresize of UINT8 image I with bilinear interpolation

  Usage
  ------

  Y                                   = imresize(X , [ny , nx]);

  
  Inputs
  -------

  X                                    Image (Ny x Nx) in UINT8 format 
   

  Outputs
  -------
  
  Y                                    Interpolated image (ny x nx)                              

  To compile
  ----------


  mex  -g -output imresize.dll imresize.c

  mex  -f mexopts_intel10.bat -output imresize.dll imresize.c

  If compiled with the "OMP" compilation flag

  mex  -DOMP -f mexopts_intel10.bat -output imresize.dll imresize.c "C:\Program Files\Intel\Compiler\11.1\065\mkl\ia32\lib\mkl_core.lib" "C:\Program Files\Intel\Compiler\11.1\065\mkl\ia32\lib\mkl_intel_c.lib" "C:\Program Files\Intel\Compiler\11.1\065\mkl\ia32\lib\mkl_intel_thread.lib" "C:\Program Files\Intel\Compiler\11.1\065\lib\ia32\libiomp5md.lib"


  Example 1
  ---------

  
  clear, close all
  X     = rgb2gray(imread('class57.jpg'));
  Y     = imresize(X , [256 , 256]); 

  figure(1)
  imagesc(X)
  colormap(gray)


  figure(2)
  imagesc(Y)
  colormap(gray)



 Author : Sébastien PARIS : sebastien.paris@lsis.org
 -------  Date : 01/20/2009

 Changelog :  - Add OpenMP support
 ----------   

 Reference ""

*/

#include <math.h>
#include <mex.h>

#ifdef OMP 
 #include <omp.h>
#endif

#define tiny  1e-7

/*-------------------------------------------------------------------------------------------------------------- */
/* Function prototypes */

void imresize(unsigned char * , int , int , int , int  , unsigned char *);

/*-------------------------------------------------------------------------------------------------------------- */
void mexFunction( int nlhs, mxArray *plhs[] , int nrhs, const mxArray *prhs[] )
{
	unsigned char *X;
	double *size;
	int ny , nx;
	int Ny , Nx;
    unsigned char *Y;
	int *dimsY;

    /* Input 1  */
	
    if ((nrhs > 0) && !mxIsEmpty(prhs[0]) && mxIsUint8(prhs[0]))       
    {        
		X          = (unsigned char *)mxGetData(prhs[0]);
		Ny         = mxGetM(prhs[0]);
		Nx         = mxGetN(prhs[0]);	
    }
	else
	{
		mexErrMsgTxt("X must be (Ny x Nx) in UINT8 format");
	}
    
    /* Input 2  */

    if ((nrhs > 1) && !mxIsEmpty(prhs[1]) && mxIsDouble(prhs[1]))       
    {        
		size      = mxGetPr(prhs[1]);
		ny        = (int)size[0];
		nx        = (int)size[1];
	}

    /*------------------------ Output ----------------------------*/

    /* Output 1  */

	dimsY            = (int *) mxMalloc(2*sizeof(int));
	dimsY[0]         = ny;
	dimsY[1]         = nx;

	plhs[0]          = mxCreateNumericArray(2 , dimsY , mxUINT8_CLASS , mxREAL);
	Y                = (unsigned char *)mxGetData(plhs[0]);
	
    /*------------------------ Main Call ----------------------------*/
	
	imresize(X , Ny , Nx , ny , nx , Y);

	/*----------------- Free Memory --------------------------------*/

	mxFree(dimsY);
}

/*----------------------------------------------------------------------------------------------------------------------------------------- */
void imresize(unsigned char *X , int Ny , int Nx , int ny , int nx ,  unsigned char *Y)
{
	int i , j  , indny = 0 , indfx , idx , idx1 , fy  , fx;
	double deltay = (Ny-1)/((double)(ny-1) + tiny) , deltax = (Nx-1)/((double)(nx-1) + tiny) , x = 0.0 , y , tx , tx1 , ty , ty1;

#ifdef OMP 
#pragma omp parallel for default(none) firstprivate(j,fy,ty,ty1,idx,idx1) lastprivate(i,fx,tx,tx1,indfx) shared(X,Y,nx,ny,Ny,deltax,deltay) reduction(*:x,y,indny)
#endif

	for(i = 0 ; i < nx ; i++) /* Loop shift on x-axis */
	{
		x                 = i*deltax;
        indny             = i*ny;
		fx                = (int)floor(x);
		tx                = x - fx;
		tx1               = 1.0 - tx;
		indfx             = fx*Ny;
		y                 = 0.0;
		for(j = 0 ; j < ny ; j++)   /* Loop shift on y-axis  */
		{
			y             = j*deltay;
			fy            = (int)floor(y);
			ty            = y - fy;
			ty1           = 1.0 - ty;
			idx           = fy + indfx;
			idx1          = idx + Ny;
			Y[j + indny]  = (X[idx]*ty1 + X[idx + 1]*ty)*tx1 + ( X[idx1]*ty1 + X[idx1 + 1]*ty )*tx;
		}
	}
}
/*----------------------------------------------------------------------------------------------------------------------------------------- */
