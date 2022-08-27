/************************************************************************/
/* Filename:	plSetValue.cpp											*/
/* Description: Source code for plSetValue								*/
/* Authors:		M.A.E.Bakker, L.I.Oei									*/
/*				maarten@panic.et.tudelft.nl, l.i.oei@its.tudelft.nl		*/
/* Date:		2002/08/09												*/
/* Updates:																*/		
/************************************************************************/
/* plSetValue sets the value of a given parameter.						*/
/************************************************************************/
/* Input:	serialNumber (U32)		serialNumber of the device			*/
/*			parametername (string)	name of the parameter				*/
/*			nvalues (int)			number of values					*/
/*			values (mxArray)		mxArray with values					*/
/* Output:	-															*/
/* Syntax:	plSetValue(serialNumber, parametername, nvalues, values)	*/
/************************************************************************/

#include <windows.h>
#include "Y:\soft95\matlab6\extern\include\mex.h"
#include "Y:\software\framegrab\pixelink\api\pimmegaapiuser.h"

#include "plError.h"
#include "plTypes.h"
#include "plPrintPossibleValues.h"


void plSetValue(U32 serialNumber, char* parametername, int nvalues, mxArray *values[])
{
	/* m = mxArray structure to be returned as device handle */
	mxArray *lhs[1], *rhs[4];
	double *px;
	HANDLE deviceId;

	/* variable for receiving the error codes the pixelink api functions return */
	PXL_RETURN_CODE nRetValue;	

	int		buflen, i;
	U32		tmpU32, tmpU322, tmpU323, tmpU324, tmpU325;
	char*	tmpstring;
	float	tmpfloat;
	BOOL	tmpBOOL;

    /********************************************************************/
	/*          Get the deviceId										*/
    /********************************************************************/
	rhs[0] = mxCreateString("get");

	rhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
	px = mxGetPr(rhs[1]);
	px[0] = (U32)serialNumber;

	mexCallMATLAB(1, lhs, 2, rhs, "plDevices");

	deviceId = (HANDLE)(int)mxGetScalar(lhs[0]);

    /********************************************************************/
	/*          Check whether the correct parameters are given.			*/
    /********************************************************************/

	/* U32 */
	if (!strcmp(parametername, "BlueGain") ||
		!strcmp(parametername, "Exposure") ||
		!strcmp(parametername, "GreenGain") ||
		!strcmp(parametername, "MonoGain") ||
		!strcmp(parametername, "RedGain") ||
		!strcmp(parametername, "Saturation") ||
		!strcmp(parametername, "Timeout"))
	{
		if (! ( (nvalues == 1) && mxIsDouble(values[0]) ) )
		{
			mexPrintf("plSetValue: wrong number of parameters given or wrong parametertype.\n");
			mexPrintf("%s expects 1 parameter of type U32.\n", parametername);
			mexErrMsgTxt("\n");
		}
	}
	/* string */
	else if (!strcmp(parametername, "DataTransferSize") ||
		!strcmp(parametername, "ImagerClocking") ||
		!strcmp(parametername, "ImagerName") ||
		!strcmp(parametername, "PreviewColorConversion") ||
		!strcmp(parametername, "VideoMode") ||
		!strcmp(parametername, "GrabColorConversion") ||
		!strcmp(parametername, "GrabOutputType"))
	{
		if (! ( (nvalues == 1) && mxIsChar(values[0]) ) )
		{
			mexPrintf("plSetValue: wrong number of parameters given or wrong parametertype.\n");
			mexPrintf("%s expects 1 parameter of type string.\n", parametername);
			mexErrMsgTxt("\n");
		}
	}
	/* float, [string] */
	else if (!strcmp(parametername, "ExposureTime"))
	{
		if (! ((nvalues == 1) || (nvalues == 2)))
		{
			mexPrintf("plSetValue: wrong number of parameters given.\n");
			mexPrintf("%s expects 1 or 2 parameters.\n", parametername);
			mexErrMsgTxt("\n");
		}
		if (! mxIsDouble(values[0]) ) 
		{
			mexPrintf("plSetValue: wrong parametertype given.\n");
			mexPrintf("%s expects a float as 1st argument.\n", parametername);
			mexErrMsgTxt("\n");
		}
		if ((nvalues == 2) && ! mxIsChar(values[0]) ) 
		{
			mexPrintf("plSetValue: wrong parametertype given.\n");
			mexPrintf("%s expects a string as 2nd argument.\n", parametername);
			mexErrMsgTxt("\n");
		}
	}
	/* float */
	if (!strcmp(parametername, "Gamma"))
	{
		if (! ( (nvalues == 1) && mxIsDouble(values[0]) ) )
		{
			mexPrintf("plSetValue: wrong number of parameters given or wrong paramtertype.\n");
			mexPrintf("%s expects 1 parameter of type float.\n", parametername);
			mexErrMsgTxt("\n");
		}
	}
	/* U32, [float] */
	else if (!strcmp(parametername, "Gpo"))
	{
		if (! ((nvalues == 1) || (nvalues == 2)))
		{
			mexPrintf("plSetValue: wrong number of parameters given.\n");
			mexPrintf("%s expects 1 or 2 parameters.\n", parametername);
			mexErrMsgTxt("\n");
		}
		if (! mxIsDouble(values[0]) ) 
		{
			mexPrintf("plSetValue: wrong parametertype given.\n");
			mexPrintf("%s expects a U32 as 1st argument.\n", parametername);
			mexErrMsgTxt("\n");
		}
		if ((nvalues == 2) && ! mxIsDouble(values[0]) ) 
		{
			mexPrintf("plSetValue: wrong parametertype given.\n");
			mexPrintf("%s expects a float as 2nd argument.\n", parametername);
			mexErrMsgTxt("\n");
		}
	}
	/* string, U32, U32, U32, U32 */
	if (!strcmp(parametername, "SubWindow"))
	{
		if (! (nvalues == 5))
		{
			mexPrintf("plSetValue: wrong number of parameters given.\n");
			mexPrintf("%s expects 5 parameters of types string, U32, U32, U32, U32.\n", parametername);
			mexErrMsgTxt("\n");
		}
		if (! mxIsChar(values[0]))
		{
			mexPrintf("plSetValue: wrong parametertype given.\n");
			mexPrintf("%s expects 5 parameters of types string, U32, U32, U32, U32.\n", parametername);
			mexErrMsgTxt("\n");
		}
		for (i = 1; i < 5; i++)
		{
			if (! mxIsDouble(values[i]) )
			{
				mexPrintf("plSetValue: wrong parametertype given.\n");
				mexPrintf("%s expects 5 parameters of types string, U32, U32, U32, U32.\n", parametername);
				mexErrMsgTxt("\n");
			}
		}
	}
	/* U32, U32 */
	else if (!strcmp(parametername, "SubWindowPos"))
	{
		if (! (nvalues == 2))
		{
			mexPrintf("plSetValue: wrong number of parameters given.\n");
			mexPrintf("%s expects 2 parameters.\n", parametername);
			mexErrMsgTxt("\n");
		}
		if (! (mxIsDouble(values[0]) && mxIsDouble(values[1]))) 
		{
			mexPrintf("plSetValue: wrong parametertype given.\n");
			mexPrintf("%s expects a two arguments of type U32.\n", parametername);
			mexErrMsgTxt("\n");
		}
	}
	/* string, U32, U32 */
	else if (!strcmp(parametername, "SubWindowSize"))
	{
		if (! (nvalues == 3))
		{
			mexPrintf("plSetValue: wrong number of parameters given.\n");
			mexPrintf("%s expects 3 parameters.\n", parametername);
			mexErrMsgTxt("\n");
		}
		if (! mxIsChar(values[0])) 
		{
			mexPrintf("plSetValue: wrong parametertype given.\n");
			mexPrintf("%s expects a 3 arguments of types string, U32, U32.\n", parametername);
			mexErrMsgTxt("\n");
		}
		if (! (mxIsDouble(values[1]) && mxIsDouble(values[2]))) 
		{
			mexPrintf("plSetValue: wrong parametertype given.\n");
			mexPrintf("%s expects a 3 arguments of types string, U32, U32.\n", parametername);
			mexErrMsgTxt("\n");
		}
	}

    /********************************************************************/
	/*          Set the value of the given parameter					*/
    /********************************************************************/

	/* Blue Gain */
	if (!strcmp(parametername, "BlueGain"))
	{
		tmpU32 = (U32)mxGetScalar(values[0]);

		/* check whether the given value is within the correct range */
		if (tmpU32 > PCS2112_MAX_GAIN)
		{
			mexPrintf("plSetValue: Error setting BlueGain: value too large.\n");
			mexPrintf("BlueGain value should not exceed %lu.\n", PCS2112_MAX_GAIN);
			mexErrMsgTxt("\n");
		}

		/* set the value */
		nRetValue = PimMegaSetBlueGain(deviceId, tmpU32);

		if (plError(nRetValue, "setting BlueGain"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* DataTransferSize */
	else if (!strcmp(parametername, "DataTransferSize"))
	{
		buflen = (mxGetM(values[0]) * mxGetN(values[0]) * sizeof(mxChar)) + 1;
		tmpstring = (char *)mxCalloc(buflen, sizeof(char));
		mxGetString(values[0], tmpstring, buflen);

		/* check whether this is a known value */
		if (!strcmp(tmpstring, "DATA_8BIT_SIZE"))
		{
			tmpU32 = DATA_8BIT_SIZE;
		}
		else if (!strcmp(tmpstring, "DATA_16BIT_SIZE"))
		{
			tmpU32 = DATA_16BIT_SIZE;
		}
		else
		{
			mexPrintf("plSetValue: Error setting DataTransferSize: unknown value.\n");
			mexPrintf("Valid values are 'DATA_8BIT_SIZE' and 'DATA_16BIT_SIZE'\n");
			mexErrMsgTxt("\n");
		}

		/* set the value */
		nRetValue = PimMegaSetDataTransferSize(deviceId, tmpU32);

		if (plError(nRetValue, "setting DataTransferSize"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* Exposure */
	else if (!strcmp(parametername, "Exposure"))
	{
		tmpU32 = (U32)mxGetScalar(values[0]);

		/* check whether the given value is within the correct range */
		if (tmpU32 > PCS2112_MAX_EXPOSURE)
		{
			mexPrintf("plSetValue: Error setting Exposure: value too large.\n");
			mexPrintf("Exposure value should not exceed %lu.\n", PCS2112_MAX_EXPOSURE);
			mexErrMsgTxt("\n");
		}

		/* set the value */
		nRetValue = PimMegaSetExposure(deviceId, tmpU32);

		if (plError(nRetValue, "setting Exposure"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* ExposureTime */
	else if (!strcmp(parametername, "ExposureTime"))
	{
		tmpfloat = (float)mxGetScalar(values[0]);
		tmpBOOL = FALSE;

		if (nvalues >= 2) /* if a second value is given, get the value */
		{
			buflen = (mxGetM(values[1]) * mxGetN(values[1]) * sizeof(mxChar)) + 1;
			tmpstring = (char *)mxCalloc(buflen, sizeof(char));
			mxGetString(values[1], tmpstring, buflen);

			/* check whether this is a known value */
			if (!strcmp(tmpstring, "FALSE"))
			{
				tmpBOOL = FALSE;
			}
			else if (!strcmp(tmpstring, "TRUE"))
			{
				tmpBOOL = TRUE;
			}
			else
			{
				mexPrintf("plSetValue: Error setting ExposureTime: unknown value.\n");
				mexPrintf("Second value should be 'TRUE' or 'FALSE'.\n");
				mexErrMsgTxt("\n");
			}
		}

		/* set the value */
		nRetValue = PimMegaSetExposureTime(deviceId, tmpfloat, tmpBOOL);

		if (plError(nRetValue, "setting ExposureTime"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* Gamma */
	else if (!strcmp(parametername, "Gamma"))
	{
		tmpfloat = (float)mxGetScalar(values[0]);

		nRetValue = PimMegaSetGamma(deviceId, tmpfloat);

		if (plError(nRetValue, "setting Gamma"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* GPO */
	else if (!strcmp(parametername, "Gpo"))
	{
		tmpU32 = 0;

		/* get Value */
		buflen = (mxGetM(values[0]) * mxGetN(values[0]) * sizeof(mxChar)) + 1;
		tmpstring = (char *)mxCalloc(buflen, sizeof(char));
		mxGetString(values[0], tmpstring, buflen);

		if (!strcmp(tmpstring, "On"))
		{
			tmpU32 = 1;
		}
		else if (!strcmp(tmpstring, "Off"))
		{
			tmpU32 = 0;
		}
		else
		{
			mexPrintf("plSetValue: Error setting Gpo: unknown value.\n");
			mexPrintf("First value should be 'On' or 'Off'.\n");
			mexErrMsgTxt("\n");
		}

		/* get PulseLength */
		tmpfloat = 0;

		if (nvalues >= 2)
		{
			tmpfloat = (float)mxGetScalar(values[1]);
		}

		/* set the value */
		nRetValue = PimMegaSetGpo(deviceId, tmpU32, tmpfloat);

		if (plError(nRetValue, "setting Gpo"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* Green Gain */
	else if (!strcmp(parametername, "GreenGain"))
	{
		tmpU32 = (U32)mxGetScalar(values[0]);

		/* check whether the given value is within the correct range */
		if (tmpU32 > PCS2112_MAX_GAIN)
		{
			mexPrintf("plSetValue: Error setting GreenGain: value too large.\n");
			mexPrintf("GreenGain value should not exceed %lu.\n", PCS2112_MAX_GAIN);
			mexErrMsgTxt("\n");
		}

		/* set the value */
		nRetValue = PimMegaSetGreenGain(deviceId, tmpU32);

		if (plError(nRetValue, "setting GreenGain"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* ImagerClocking */
	else if (!strcmp(parametername, "ImagerClocking"))
	{
		tmpU32 = 0x00;

		buflen = (mxGetM(values[0]) * mxGetN(values[0]) * sizeof(mxChar)) + 1;
		tmpstring = (char *)mxCalloc(buflen, sizeof(char));
		mxGetString(values[0], tmpstring, buflen);

		/* check whether this is a known value */
		if (!strcmp(tmpstring, "0x00"))
		{
			tmpU32 = 0x00;
		}
		else if (!strcmp(tmpstring, "0x01"))
		{
			tmpU32 = 0x01;
		}
		else if (!strcmp(tmpstring, "0x02"))
		{
			tmpU32 = 0x02;
		}
		else if (!strcmp(tmpstring, "0x80"))
		{
			tmpU32 = 0x80;
		}
		else if (!strcmp(tmpstring, "0x81"))
		{
			tmpU32 = 0x81;
		}
		else if (!strcmp(tmpstring, "0x82"))
		{
			tmpU32 = 0x82;
		}
		else
		{
			mexPrintf("plSetValue: Error setting ImagerClocking: unknown value.\n");
			mexPrintf("Valid values are: '0x00', '0x01', '0x02', '0x80', '0x81' and '0x82'.\n");
			mexErrMsgTxt("\n");
		}

		/* set the value */
		nRetValue = PimMegaSetImagerClocking(deviceId, tmpU32);

		if (plError(nRetValue, "setting ImagerClocking"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* ImagerName */
	else if (!strcmp(parametername, "ImagerName"))
	{
		buflen = (mxGetM(values[0]) * mxGetN(values[0]) * sizeof(mxChar)) + 1;
		tmpstring = (char *)mxCalloc(buflen, sizeof(char));
		mxGetString(values[0], tmpstring, buflen);

		if (buflen > 81)
		{
			mexPrintf("plSetValue: Error setting ImagerName: string too long.\n");
			mexPrintf("ImagerName should not exceed 80 characters.\n");
			mexErrMsgTxt("\n");
		}

		/* set the value */
		nRetValue = PimMegaSetImagerName(deviceId, tmpstring);

		if (plError(nRetValue, "setting ImagerName"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* MonoGain */
	else if (!strcmp(parametername, "MonoGain"))
	{
		tmpU32 = (U32)mxGetScalar(values[0]);

		/* check whether the given value is within the correct range */
		if (tmpU32 > PCS2112_MAX_GAIN)
		{
			mexPrintf("plSetValue: Error setting MonoGain: value too large.\n");
			mexPrintf("MonoGain value should not exceed %lu.\n", PCS2112_MAX_GAIN);
			mexErrMsgTxt("\n");
		}

		/* set the value */
		nRetValue = PimMegaSetMonoGain(deviceId, tmpU32);

		if (plError(nRetValue, "setting MonoGain"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* OverlayCallBack */
	else if (!strcmp(parametername, "OverlayCallBack"))
	{
		/* TODO */
		mexErrMsgTxt("PimMegaSetOverlayCallBack not supported yet.\n");
	}
	/* PreviewColorConversion */
	else if (!strcmp(parametername, "PreviewColorConversion"))
	{
		tmpU32 = BAYER_3BY3_COLOR;

		buflen = (mxGetM(values[0]) * mxGetN(values[0]) * sizeof(mxChar)) + 1;
		tmpstring = (char *)mxCalloc(buflen, sizeof(char));
		mxGetString(values[0], tmpstring, buflen);

		/* check whether this is a known value */
		if (!strcmp(tmpstring, "BAYER_2BY2_COLOR"))
			tmpU32 = BAYER_2BY2_COLOR;
		else if (!strcmp(tmpstring, "BAYER_3BY3_COLOR"))
			tmpU32 = BAYER_3BY3_COLOR;
		else if (!strcmp(tmpstring, "BAYER_3BY3GGRAD_COLOR"))
			tmpU32 = BAYER_3BY3GGRAD_COLOR;
		else if (!strcmp(tmpstring, "BAYER_2PASSGRAD_COLOR"))
			tmpU32 = BAYER_2PASSGRAD_COLOR;
		else if (!strcmp(tmpstring, "BAYER_2PASSADAPT_COLOR"))
			tmpU32 = BAYER_2PASSADAPT_COLOR;
		else if (!strcmp(tmpstring, "BAYER_VARGRAD_COLOR"))
			tmpU32 = BAYER_VARGRAD_COLOR;
		else if (!strcmp(tmpstring, "BAYER_2BY2_MONO"))
			tmpU32 = BAYER_2BY2_MONO;
		else if (!strcmp(tmpstring, "BAYER_3BY3_MONO"))
			tmpU32 = BAYER_3BY3_MONO;
		else if (!strcmp(tmpstring, "BAYER_ADAPT_MONO"))
			tmpU32 = BAYER_ADAPT_MONO;
		else if (!strcmp(tmpstring, "BAYER_NO_CONVERSION"))
			tmpU32 = BAYER_NO_CONVERSION;
		else
		{
			mexPrintf("plSetValue: Error setting PreviewColorConversion: unknown value.\n");
			plPrintPossibleValues("PreviewColorConversion");
			mexErrMsgTxt("\n");
		}

		/* set the value */
		nRetValue = PimMegaSetImagerClocking(deviceId, tmpU32);

		if (plError(nRetValue, "setting PreviewColorConversion"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* PreviewWindow */
	else if (!strcmp(parametername, "PreviewWindow"))
	{
		/* TODO */
		mexErrMsgTxt("PimMegaSetPreviewWindow not supported yet.\n");
	}
	/* RedGain */
	else if (!strcmp(parametername, "RedGain"))
	{
		tmpU32 = (U32)mxGetScalar(values[0]);

		/* check whether the given value is within the correct range */
		if (tmpU32 > PCS2112_MAX_GAIN)
		{
			mexPrintf("plSetValue: Error setting RedGain: value too large.\n");
			mexPrintf("RedGain value should not exceed %lu.\n", PCS2112_MAX_GAIN);
			mexErrMsgTxt("\n");
		}

		/* set the value */
		nRetValue = PimMegaSetRedGain(deviceId, tmpU32);

		if (plError(nRetValue, "setting RedGain"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* Saturation */
	else if (!strcmp(parametername, "Saturation"))
	{
		tmpU32 = (U32)mxGetScalar(values[0]);

		/* check whether the given value is within the correct range */
		if (tmpU32 > 0xFF)
		{
			mexPrintf("plSetValue: Error setting Saturation: value too large.\n");
			mexPrintf("Saturation value should not exceed 0xFF.\n");
			mexErrMsgTxt("\n");
		}

		/* set the value */
		nRetValue = PimMegaSetSaturation(deviceId, tmpU32);

		if (plError(nRetValue, "setting Saturation"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* SubWindow */
	else if (!strcmp(parametername, "SubWindow"))
	{
		tmpU32 = PCS2112_NO_DECIMATION;

		/* uDecimation */
		buflen = (mxGetM(values[0]) * mxGetN(values[0]) * sizeof(mxChar)) + 1;
		tmpstring = (char *)mxCalloc(buflen, sizeof(char));
		mxGetString(values[0], tmpstring, buflen);

		if (!strcmp(tmpstring, "PCS2112_NO_DECIMATION"))
		{
			tmpU32 = PCS2112_NO_DECIMATION;
		}
		else if (!strcmp(tmpstring, "PCS2112_DECIMATE_BY_2"))
		{
			tmpU32 = PCS2112_DECIMATE_BY_2;
		}
		else if (!strcmp(tmpstring, "PCS2112_DECIMATE_BY_4"))
		{
			tmpU32 = PCS2112_DECIMATE_BY_4;
		}
		else
		{
			mexPrintf("plSetValue: Error setting SubWindow: unknown value.\n");
			mexPrintf("uDecimation should be 'PCS2112_NO_DECIMATION',\n");
			mexPrintf("  'PCS2112_DECIMATE_BY_2' or 'PCS2112_DECIMATE_BY_4'\n");
			mexErrMsgTxt("\n");
		}

		tmpU322 = (U32)mxGetScalar(values[2]); /* uStartColumn */
		tmpU323 = (U32)mxGetScalar(values[1]); /* uStartRow */
		tmpU324 = (U32)mxGetScalar(values[4]); /* uNumberColumns */
		tmpU325 = (U32)mxGetScalar(values[3]); /* uNumberRows */

		/* check whether the given values are within the correct range */
		if ((tmpU322 + tmpU324) > PCS2112_MAX_WIDTH)
		{
			mexPrintf("plSetValue: Error setting SubWindow: value too large.\n");
			mexPrintf("(uStartColumn + uNumberColumns) should not exceed %lu.\n", PCS2112_MAX_WIDTH);
			mexErrMsgTxt("\n");
		}
		if ((tmpU323 + tmpU325) > PCS2112_MAX_HEIGHT)
		{
			mexPrintf("plSetValue: Error setting SubWindow: value too large.\n");
			mexPrintf("(uStartRow + uNumberRows) should not exceed %lu.\n", PCS2112_MAX_HEIGHT);
			mexErrMsgTxt("\n");
		}
		if (tmpU324 < PCS2112_MIN_WIDTH)
		{
			mexPrintf("plSetValue: Error setting SubWindow: value too small.\n");
			mexPrintf("uNumberColumns must be at least %lu.\n", PCS2112_MIN_WIDTH);
			mexErrMsgTxt("\n");
		}
		if (tmpU325 < PCS2112_MIN_HEIGHT)
		{
			mexPrintf("plSetValue: Error setting SubWindow: value too small.\n");
			mexPrintf("uNumberRows must be at least %lu.\n", PCS2112_MIN_HEIGHT);
			mexErrMsgTxt("\n");
		}

		/* set the values */
		nRetValue = PimMegaSetSubWindow(deviceId, tmpU32, tmpU322, tmpU323, tmpU324, tmpU325);

		if (plError(nRetValue, "setting SubWindow"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* SubWindowPos */
	else if (!strcmp(parametername, "SubWindowPos"))
	{
		tmpU32 = (U32)mxGetScalar(values[1]); /* uStartColumn */
		tmpU322 = (U32)mxGetScalar(values[0]); /* uStartRow */

		/* tmpU323 = subWindowSizeDecimationValue */
		/* tmpU324 = subWindowSizeWidthValue (number of columns) */
		/* tmpU325 = subWindowSizeHeightValue (number of rows) */
		nRetValue = PimMegaGetSubWindowSize(deviceId, &tmpU323, &tmpU324, &tmpU325);

		/* check whether the given values are within the correct range */
		if ((tmpU32 + tmpU324) > PCS2112_MAX_WIDTH)
		{
			mexPrintf("plSetValue: Error setting SubWindowPos: value too large.\n");
			mexPrintf("(uStartColumn + current number of columns) should not exceed %lu.\n", PCS2112_MAX_WIDTH);
			mexErrMsgTxt("\n");
		}
		if ((tmpU322 + tmpU325) > PCS2112_MAX_HEIGHT)
		{
			mexPrintf("plSetValue: Error setting SubWindowPos: value too large.\n");
			mexPrintf("(uStartRow + current number of rows) should not exceed %lu.\n", PCS2112_MAX_HEIGHT);
			mexErrMsgTxt("\n");
		}

		/* set the values */
		nRetValue = PimMegaSetSubWindowPos(deviceId, tmpU32, tmpU322);

		if (plError(nRetValue, "setting SubWindowPos"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* SubWindowSize */
	else if (!strcmp(parametername, "SubWindowSize"))
	{
		tmpU32 = PCS2112_NO_DECIMATION;

		/* uDecimation */
		buflen = (mxGetM(values[0]) * mxGetN(values[0]) * sizeof(mxChar)) + 1;
		tmpstring = (char *)mxCalloc(buflen, sizeof(char));
		mxGetString(values[0], tmpstring, buflen);

		if (!strcmp(tmpstring, "PCS2112_NO_DECIMATION"))
		{
			tmpU32 = PCS2112_NO_DECIMATION;
		}
		else if (!strcmp(tmpstring, "PCS2112_DECIMATE_BY_2"))
		{
			tmpU32 = PCS2112_DECIMATE_BY_2;
		}
		else if (!strcmp(tmpstring, "PCS2112_DECIMATE_BY_4"))
		{
			tmpU32 = PCS2112_DECIMATE_BY_4;
		}
		else
		{
			mexPrintf("plSetValue: Error setting SubWindowSize: unknown value.\n");
			mexPrintf("uDecimation should be 'PCS2112_NO_DECIMATION',\n");
			mexPrintf("  'PCS2112_DECIMATE_BY_2' or 'PCS2112_DECIMATE_BY_4'\n");
			mexErrMsgTxt("\n");
		}

		tmpU322 = (U32)mxGetScalar(values[2]); /* uWidth */
		tmpU323 = (U32)mxGetScalar(values[1]); /* uHeight */

		/* check whether the given values are within the correct range */

		/* tmpU324 = subWindowPosStartColumnValue */
		/* tmpU325 = subWindowPosStartRowValue */
		nRetValue = PimMegaGetSubWindowPos(deviceId, &tmpU324, &tmpU325);

		if ((tmpU324 + tmpU322) > PCS2112_MAX_WIDTH)
		{
			mexPrintf("plSetValue: Error setting Subwindow size: value too large.\n");
			mexPrintf("(Current start column + uWidth) should not exceed %lu.\n", PCS2112_MAX_WIDTH);
			mexErrMsgTxt("\n");
		}
		if ((tmpU325 + tmpU323) > PCS2112_MAX_HEIGHT)
		{
			mexPrintf("plSetValue: Error setting Subwindow size: value too large.\n");
			mexPrintf("(Current start row + uHeight) should not exceed %lu.\n", PCS2112_MAX_HEIGHT);
			mexErrMsgTxt("\n");
		}
		if (tmpU322 < PCS2112_MIN_WIDTH)
		{
			mexPrintf("plSetValue: Error setting Subwindow size: value too small.\n");
			mexPrintf("uWidth must be at least %lu.\n", PCS2112_MIN_WIDTH);
			mexErrMsgTxt("\n");
		}
		if (tmpU323 < PCS2112_MIN_HEIGHT)
		{
			mexPrintf("plSetValue: Error setting Subwindow size: value too small.\n");
			mexPrintf("uHeight must be at least than %lu.\n", PCS2112_MIN_HEIGHT);
			mexErrMsgTxt("\n");
		}

		/* set the values */
		nRetValue = PimMegaSetSubWindowSize(deviceId, tmpU32, tmpU322, tmpU323);

		if (plError(nRetValue, "setting SubWindowSize"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* Timeout */
	else if (!strcmp(parametername, "Timeout"))
	{
		tmpU32 = (U32)mxGetScalar(values[0]);

		nRetValue = PimMegaSetTimeout(deviceId, tmpU32);

		if (plError(nRetValue, "setting Timeout"))
		{
			mexErrMsgTxt("\n");
		}
	}
	/* VideoMode */
	else if (!strcmp(parametername, "VideoMode"))
	{
		tmpU32 = STILL_MODE;

		buflen = (mxGetM(values[0]) * mxGetN(values[0]) * sizeof(mxChar)) + 1;
		tmpstring = (char *)mxCalloc(buflen, sizeof(char));
		mxGetString(values[0], tmpstring, buflen);

		/* check whether this is a known value */
		if (!strcmp(tmpstring, "STILL_MODE"))
		{
			tmpU32 = STILL_MODE;
		}
		else if (!strcmp(tmpstring, "VIDEO_MODE"))
		{
			tmpU32 = VIDEO_MODE;
		}
		else
		{
			mexPrintf("plSetValue: Error setting VideoMode: unknown value.\n");
			mexPrintf("Valid values are 'STILL_MODE' and 'VIDEO_MODE',\n");
			mexErrMsgTxt("\n");
		}

		/* set the value */
		nRetValue = PimMegaSetVideoMode(deviceId, tmpU32);

		if (plError(nRetValue, "setting VideoMode"))
		{
			mexErrMsgTxt("\n");
		}
	}
	else if (!strcmp(parametername, "GrabColorConversion"))
	{
		tmpU32 = BAYER_3BY3_COLOR;

		buflen = (mxGetM(values[0]) * mxGetN(values[0]) * sizeof(mxChar)) + 1;
		tmpstring = (char *)mxCalloc(buflen, sizeof(char));
		mxGetString(values[0], tmpstring, buflen);

		/* check whether this is a known value */
		if (!strcmp(tmpstring, "BAYER_2BY2_COLOR"))
			tmpU32 = BAYER_2BY2_COLOR;
		else if (!strcmp(tmpstring, "BAYER_3BY3_COLOR"))
			tmpU32 = BAYER_3BY3_COLOR;
		else if (!strcmp(tmpstring, "BAYER_3BY3GGRAD_COLOR"))
			tmpU32 = BAYER_3BY3GGRAD_COLOR;
		else if (!strcmp(tmpstring, "BAYER_2PASSGRAD_COLOR"))
			tmpU32 = BAYER_2PASSGRAD_COLOR;
		else if (!strcmp(tmpstring, "BAYER_2PASSADAPT_COLOR"))
			tmpU32 = BAYER_2PASSADAPT_COLOR;
		else if (!strcmp(tmpstring, "BAYER_VARGRAD_COLOR"))
			tmpU32 = BAYER_VARGRAD_COLOR;
		else if (!strcmp(tmpstring, "BAYER_2BY2_MONO"))
			tmpU32 = BAYER_2BY2_MONO;
		else if (!strcmp(tmpstring, "BAYER_3BY3_MONO"))
			tmpU32 = BAYER_3BY3_MONO;
		else if (!strcmp(tmpstring, "BAYER_ADAPT_MONO"))
			tmpU32 = BAYER_ADAPT_MONO;
		else if (!strcmp(tmpstring, "BAYER_NO_CONVERSION"))
			tmpU32 = BAYER_NO_CONVERSION;
		else
		{
			mexPrintf("plSetValue: Error setting GrabColorConversion: unknown value.\n");
			plPrintPossibleValues("GrabColorConversion");
			mexErrMsgTxt("\n");
		}

		/* set the value */
		rhs[0] = mxCreateString("setpar");
		rhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
		px = mxGetPr(rhs[1]);
		px[0] = (U32)serialNumber;
		rhs[2] = mxCreateString("GrabColorConversion");
		rhs[3] = mxCreateDoubleMatrix(1, 1, mxREAL);
		px = mxGetPr(rhs[3]);
		px[0] = tmpU32;
		mexCallMATLAB(0, lhs, 4, rhs, "plDevices");
	}
	else if (!strcmp(parametername, "GrabOutputType"))
	{
		buflen = (mxGetM(values[0]) * mxGetN(values[0]) * sizeof(mxChar)) + 1;
		tmpstring = (char *)mxCalloc(buflen, sizeof(char));
		mxGetString(values[0], tmpstring, buflen);

		/* check whether this is a known value */
		if (!strcmp(tmpstring, "RAW"))
			tmpU32 = RAW;
		else if (!strcmp(tmpstring, "IMAGE"))
			tmpU32 = IMAGE;
		else if (!strcmp(tmpstring, "RGB24"))
			tmpU32 = RGB24;
		else
		{
			mexPrintf("plSetValue: Error setting GrabOutputType: unknown value.\n");
			plPrintPossibleValues("GrabOutputType");
			mexErrMsgTxt("\n");
		}

		/* set the value */
		rhs[0] = mxCreateString("setpar");
		rhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
		px = mxGetPr(rhs[1]);
		px[0] = (U32)serialNumber;
		rhs[2] = mxCreateString("GrabOutputType");
		rhs[3] = mxCreateDoubleMatrix(1, 1, mxREAL);
		px = mxGetPr(rhs[3]);
		px[0] = tmpU32;
		mexCallMATLAB(0, lhs, 4, rhs, "plDevices");
	}
	else
	{
		mexPrintf("plSetValue: Unknown parameter name.\n");
		mexErrMsgTxt("\n");
	}
}
