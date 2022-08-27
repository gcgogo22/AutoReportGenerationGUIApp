/************************************************************************/
/* Filename:	plPrintPossibleValues.cpp								*/
/* Description: Source code for plPrintPossibleValues					*/
/* Authors:		M.A.E.Bakker, L.I.Oei									*/
/*				maarten@panic.et.tudelft.nl, l.i.oei@its.tudelft.nl		*/
/* Date:		2002/08/09												*/
/* Updates:																*/		
/************************************************************************/
/* plPrintPossibleValues: prints the possible values for 'parametername'*/
/* called when plSet gets 2 arguments									*/
/************************************************************************/
/* Input:	parametername (string) name of the parameter				*/
/* Output:	-															*/
/* Syntax:	plPrintPossibleValues(parametername)						*/
/************************************************************************/

#include <windows.h>

#include "Y:\soft95\matlab6\extern\include\mex.h"
/* with Y:\soft95\matlab6\extern\lib\win32\microsoft\msvc60\libmex.lib */
/* and  Y:\soft95\matlab6\extern\lib\win32\microsoft\msvc60\libmx.lib */

#include "Y:\software\framegrab\pixelink\api\pimmegaapiuser.h"
/* with Y:\software\framegrab\pixelink\api\pimmegaapi.lib */

void plPrintPossibleValues(char* parametername)
{
	/* BlueGain */
	if (!strcmp(parametername, "BlueGain"))
	{
		mexPrintf("BlueGain: U32\n");
		mexPrintf("Value should not exceed %lu.\n", PCS2112_MAX_GAIN);
	}
	/* DataTransferSize */
	else if (!strcmp(parametername, "DataTransferSize"))
	{
		mexPrintf("DataTransferSize: string\n");
		mexPrintf("Valid values are 'DATA_8BIT_SIZE' and 'DATA_16BIT_SIZE'.\n");
	}
	/* Exposure */
	else if (!strcmp(parametername, "Exposure"))
	{
		mexPrintf("Exposure: U32\n");
		mexPrintf("Value must not exceed %lu.\n", PCS2112_MAX_EXPOSURE);
	}
	/* ExposureTime */
	else if (!strcmp(parametername, "ExposureTime"))
	{
		mexPrintf("ExposureTime: float fExposure, string bChangeClockSpeed='FALSE'\n");
		mexPrintf("fExposure is the exposure time, in milliseconds.\n");
		mexPrintf("bChangeClockSpeed should be a string with value 'TRUE' or 'FALSE'.\n");
		mexPrintf("if no bChangeClockSpeed argument is given, the default 'FALSE' will be used.\n");
	}
	/* Gamma */
	else if (!strcmp(parametername, "Gamma"))
	{
		mexPrintf("Gamma: float\n");
		mexPrintf("To turn of gamma correction, specify a value of 0 or 1.\n");
	}
	/* Gpo */
	else if (!strcmp(parametername, "Gpo"))
	{
		mexPrintf("Gpo: string Value, float PulseLength\n");
		mexPrintf("Value should be 'On' or 'Off'.\n");
		mexPrintf("If PulseLength = 0, GPO is set to Value.\n");
		mexPrintf("If PulseLength > 0, A pulse of PulseLength milliseconds is sent via the GPO;\n");
		mexPrintf("  the value of the pulse is set by Value.\n");
	}
	/* GreenGain */
	else if (!strcmp(parametername, "GreenGain"))
	{
		mexPrintf("GreenGain: U32\n");
		mexPrintf("Value should not exceed %lu.\n", PCS2112_MAX_GAIN);
	}
	/* ImagerClocking */
	else if (!strcmp(parametername, "ImagerClocking"))
	{
		mexPrintf("ImagerClocking: string\n");
		mexPrintf("Valid values are:\n");
		mexPrintf("'0x00' Oscilator type: External (16MHz)\n");
		mexPrintf("       Max clock rate divided by: (no division)\n");
		mexPrintf("'0x01' Oscilator type: External (16MHz)\n");
		mexPrintf("       Max clock rate divided by: 2\n");
		mexPrintf("'0x02' Oscilator type: External (16MHz)\n");
		mexPrintf("       Max clock rate divided by: 4\n");
		mexPrintf("'0x80' Oscilator type: Internal (24MHz)\n");
		mexPrintf("       Max clock rate divided by: (no division)\n");
		mexPrintf("'0x81' Oscilator type: Internal (24MHz)\n");
		mexPrintf("       Max clock rate divided by: 2\n");
		mexPrintf("'0x82' Oscilator type: Internal (24MHz)\n");
		mexPrintf("       Max clock rate divided by: 4\n");
	}
	/* ImagerName */
	else if (!strcmp(parametername, "ImagerName"))
	{
		mexPrintf("ImagerName: string (max. 80 characters)\n");
	}
	/* MonoGain */
	else if (!strcmp(parametername, "MonoGain"))
	{
		mexPrintf("MonoGain: U32\n");
		mexPrintf("Value should not exceed %lu.\n", PCS2112_MAX_GAIN);
	}
	/* OverlayCallBack */
	else if (!strcmp(parametername, "OverlayCallBack"))
	{
		/* TODO */
		mexPrintf("PimMegaSetOverlayCallBack not supported yet.\n");
	}
	/* PreviewColorConversion */
	else if (!strcmp(parametername, "PreviewColorConversion"))
	{
		mexPrintf("PreviewColorConversion: string\n");
		mexPrintf("Valid values are:\n");
		mexPrintf("'BAYER_2BY2_COLOR'        Fastest\n");
		mexPrintf("'BAYER_3BY3_COLOR'        Fast--default\n");
		mexPrintf("'BAYER_3BY3GGRAD_COLOR'   Best quality for real-time\n");
		mexPrintf("'BAYER_2PASSGRAD_COLOR'   Best for captured images\n");
		mexPrintf("'BAYER_2PASSADAPT_COLOR'  Best for captured images\n");
		mexPrintf("'BAYER_VARGRAD_COLOR'     Best for captured images\n");
		mexPrintf("'BAYER_2BY2_MONO'         Fastest (converts to monochrome)\n");
		mexPrintf("'BAYER_3BY3_MONO'         Best quality for real-time (to mono)\n");
		mexPrintf("'BAYER_ADAPT_MONO'        Best for caputured images (to mono)\n");
		mexPrintf("'BAYER_NO_CONVERSION'     No Bayer conversion\n");
	}
	/* PreviewWindow */
	else if (!strcmp(parametername, "PreviewWindow"))
	{
		/* TODO */
		mexPrintf("PimMegaSetPreviewWindow not supported yet.\n");
	}
	/* RedGain */
	else if (!strcmp(parametername, "RedGain"))
	{
		mexPrintf("RedGain: U32\n");
		mexPrintf("Value should not exceed %lu.\n", PCS2112_MAX_GAIN);
	}
	/* Saturation */
	else if (!strcmp(parametername, "Saturation"))
	{
		mexPrintf("Saturation: U32\n");
		mexPrintf("Value should not exceed 0xFF.\n");
	}
	/* SubWindow */
	else if (!strcmp(parametername, "SubWindow"))
	{
		mexPrintf("SubWindow: string uDecimation\n");
		mexPrintf("           U32 uStartRow\n");
		mexPrintf("           U32 uStartColumn\n");
		mexPrintf("           U32 uNumberRows\n");
		mexPrintf("           U32 uNumberColumns\n");
		mexPrintf("uDecimation should be 'PCS2112_NO_DECIMATION',\n");
		mexPrintf("  'PCS2112_DECIMATE_BY_2' or 'PCS2112_DECIMATE_BY_4'\n");
	}
	/* SubWindowPos */
	else if (!strcmp(parametername, "SubWindowPos"))
	{
		mexPrintf("SubWindowPos: U32 uStartRow, U32 uStartColumn\n");
	}
	/* SubWindowSize */
	else if (!strcmp(parametername, "SubWindowSize"))
	{
		mexPrintf("SubWindowSize: string uDecimation\n");
		mexPrintf("               U32 uHeight\n");
		mexPrintf("               U32 uWidth\n");
		mexPrintf("uDecimation should be 'PCS2112_NO_DECIMATION',\n");
		mexPrintf("  'PCS2112_DECIMATE_BY_2' or 'PCS2112_DECIMATE_BY_4'\n");
	}
	/* Timeout */
	else if (!strcmp(parametername, "Timeout"))
	{
		mexPrintf("Timeout: U32\n");
	}
	/* VideoMode */
	else if (!strcmp(parametername, "VideoMode"))
	{
		mexPrintf("VideoMode: string\n");
		mexPrintf("Valid values are 'STILL_MODE' and 'VIDEO_MODE',\n");
	}
	/* GrabColorConversion */
	else if (!strcmp(parametername, "GrabColorConversion"))
	{
		mexPrintf("GrabColorConversion: string\n");
		mexPrintf("Valid values are:\n");
		mexPrintf("'BAYER_2BY2_COLOR'        Fastest\n");
		mexPrintf("'BAYER_3BY3_COLOR'        Fast--default\n");
		mexPrintf("'BAYER_3BY3GGRAD_COLOR'   Best quality for real-time\n");
		mexPrintf("'BAYER_2PASSGRAD_COLOR'   Best for captured images\n");
		mexPrintf("'BAYER_2PASSADAPT_COLOR'  Best for captured images\n");
		mexPrintf("'BAYER_VARGRAD_COLOR'     Best for captured images\n");
		mexPrintf("'BAYER_2BY2_MONO'         Fastest (converts to monochrome)\n");
		mexPrintf("'BAYER_3BY3_MONO'         Best quality for real-time (to mono)\n");
		mexPrintf("'BAYER_ADAPT_MONO'        Best for caputured images (to mono)\n");
		mexPrintf("'BAYER_NO_CONVERSION'     No Bayer conversion\n");
	}
	/* GrabOutputType */
	else if (!strcmp(parametername, "GrabOutputType"))
	{
		mexPrintf("GrabOutputType: string\n");
		mexPrintf("Valid values are:\n");
		mexPrintf("'RAW'    Image exactly as produced by the camera\n");
		mexPrintf("'IMAGE'  24 bpp colour bitmap converted to Matlab image format\n");
		mexPrintf("'RGB24'  24 bpp colour bitmap in RGB24 format\n");
	}
	else
	{
		mexPrintf("plSet: Unknown parameter name.\n");
		mexErrMsgTxt("\n");
	}
}
