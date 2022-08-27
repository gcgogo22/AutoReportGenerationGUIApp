/************************************************************************/
/* Filename:	plCreateDeviceHandle.cpp								*/
/* Description: Source code for plCreateDeviceHandle					*/
/* Authors:		M.A.E.Bakker, L.I.Oei									*/
/*				maarten@panic.et.tudelft.nl, l.i.oei@its.tudelft.nl		*/
/* Date:		2002/08/09												*/
/* Updates:																*/		
/************************************************************************/
/* plCreateDeviceHandle creates the device handle (i.e. the	structure	*/
/* with settings), which has to be returned to the matlab user.			*/
/************************************************************************/
/* Input:	returnarray (mxArray)	mxArray for receiving the structure	*/
/*			serialNumber (U32)		serial number of the device			*/
/* Output:	-															*/
/* Syntax:	plCreateDeviceHandle(returnArray, serialNumber)				*/
/************************************************************************/

#include <windows.h>
#include "Y:\soft95\matlab6\extern\include\mex.h"
#include "Y:\software\framegrab\pixelink\api\pimmegaapiuser.h"

#include "plTypes.h"

void plCreateDeviceHandle(mxArray *returnArray[], U32 serialNumber)
{
	/* m = mxArray structure to be returned as device handle */
	/* lhs, rhs used to call plDevices */
	mxArray *m, *lhs[1], *rhs[3];
	double *px;
	HANDLE deviceId;

	/* variable for receiving the error codes the pixelink api functions return */
	PXL_RETURN_CODE nRetValue;	

	int nof=40;	/* number of fields of the device handle structure */

	int rows=1;
	int cols=1;

	char *fieldnames[] =	/* names of the fields of the device handle structure */
	{
		"DeviceID",
		"BlueGain",					"CurrentFrameRate",			"DataTransferSize", 
		"Exposure",					"ExposureTime",				"Gamma",
		"Gpo",						"GreenGain",				"HardwareVersion.ProductID",
		"HardwareVersion.SerialNumber", "HardwareVersion.FirmwareVersion", "HardwareVersion.FpgaVersion",
		"ImagerChipId",				"ImagerClocking",			"ImagerName",
		"ImagerType",				"MonoGain",					"PreviewWindowPos.Top",
		"PreviewWindowPos.Left",	"PreviewWindowSize.Height",	"PreviewWindowSize.Width",
		"RedGain",					"Saturation",				"SerialNumber",
		"SoftwareVersion",			"SubWindow.Decimation",		"SubWindow.StartRow",
		"SubWindow.StartColumn",	"SubWindow.NumberRows",		"SubWindow.NumberColumns",
		"SubWindowPos.StartRow",	"SubWindowPos.StartColumn",	"SubWindowSize.Decimation",
		"SubWindowSize.Height",		"SubWindowSize.Width",		"Timeout",
		"VideoMode",				"GrabColorConversion",		"GrabOutputType"
	};

	mxArray *tmp, *tmp2, *tmp3, *tmp4, *tmp5;
	double *tmppr, *tmppr2, *tmppr3, *tmppr4, *tmppr5;

	/* variables used for receiving the settings */

	U32		blueGainValue = -1;
	float	currentFrameRateValue = -1;
	U32		dataTransferSizeValue = -1;
	U32		exposureValue = -1;
	float	exposureTimeValue = -1;
	float	gammaValue = -1;
	U32		gpoValue = -1;
	U32		greenGainValue = -1;
	HARDWARE_VERSION hardwareVersionValue;
	U32		imagerChipIdValue = -1;
	U32		imagerClockingValue = -1;
	LPSTR	imagerNameValue;
	U32		imagerTypeValue = -1;
	U32		monoGainValue = -1;

	long	previewWindowPosLeftValue = -1;
	long	previewWindowPosTopValue = -1;

	U32		previewWindowSizeWidthValue = -1;
	U32		previewWindowSizeHeightValue = -1;

	U32		redGainValue = -1;
	U32		saturationValue = -1;
	U32		serialNumberValue = -1;
	U32		softwareVersionValue = -1;

	U32		subWindowDecimationValue = -1;
	U32		subWindowStartColumnValue = -1;
	U32		subWindowStartRowValue = -1;
	U32		subWindowNumberColumnsValue = -1;
	U32		subWindowNumberRowsValue = -1;

	U32		subWindowPosStartColumnValue = -1;
	U32		subWindowPosStartRowValue = -1;

	U32		subWindowSizeDecimationValue = -1;
	U32		subWindowSizeWidthValue = -1;
	U32		subWindowSizeHeightValue = -1;

	U32		timeoutValue = -1;
	U32		videoModeValue = -1;

	U32		grabColorConversion = -1;
	U32		grabOutputType = -1;

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
	/*          Get all settings and store them in the mxArray			*/
    /********************************************************************/
	m = mxCreateStructMatrix(rows, cols, nof, (const char **)fieldnames);

	/* DeviceID */
	tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
	tmppr = mxGetPr(tmp);
	tmppr[0] = (int)deviceId;
	mxSetField(m, 0, "DeviceID", tmp);

	/* Blue Gain */
	nRetValue = PimMegaGetBlueGain(deviceId, &blueGainValue);
	
	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)blueGainValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "BlueGain", tmp);

	/* Current Frame Rate */
	nRetValue = PimMegaGetCurrentFrameRate(deviceId, &currentFrameRateValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = currentFrameRateValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "CurrentFrameRate", tmp);

	/* Data Transfer Size */
	nRetValue = PimMegaGetDataTransferSize(deviceId, &dataTransferSizeValue);

	if (ApiSuccess == nRetValue)
	{
		if (dataTransferSizeValue == DATA_8BIT_SIZE)
		{
			tmp = mxCreateString("DATA_8BIT_SIZE");
		}
		else if (dataTransferSizeValue == DATA_16BIT_SIZE)
		{
			tmp = mxCreateString("DATA_16BIT_SIZE");
		}
		else
		{
			tmp = mxCreateString("Unknown value");
		}
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "DataTransferSize", tmp);

	/* Exposure */
	nRetValue = PimMegaGetExposure(deviceId, &exposureValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)exposureValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "Exposure", tmp);

	/* Exposure Time */
	nRetValue = PimMegaGetExposureTime(deviceId, &exposureTimeValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = exposureTimeValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "ExposureTime", tmp);

	/* Gamma */
	nRetValue = PimMegaGetGamma(deviceId, &gammaValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = gammaValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "Gamma", tmp);

	/* Gpo */
	nRetValue = PimMegaGetGpo(deviceId, &gpoValue);

	if (ApiSuccess == nRetValue)
	{
		if (gpoValue == 0)
		{
			tmp = mxCreateString("Off");
		}
		else if (gpoValue == 1)
		{
			tmp = mxCreateString("On");
		}
		else
		{
			tmp = mxCreateString("Unknown value");
		}
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "Gpo", tmp);
	
	/* Green Gain */
	nRetValue = PimMegaGetGreenGain(deviceId, &greenGainValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)greenGainValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "GreenGain", tmp);

	/* Hardware Version */
	nRetValue = PimMegaGetHardwareVersion(deviceId, &hardwareVersionValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateString((const char *)hardwareVersionValue.ProductID);
		tmp2 = mxCreateString((const char *)hardwareVersionValue.SerialNumber);
		tmp3 = mxCreateString((const char *)hardwareVersionValue.FirmwareVersion);
		tmp4 = mxCreateString((const char *)hardwareVersionValue.FpgaVersion);
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
		tmp2 = mxCreateString("Unsupported");
		tmp3 = mxCreateString("Unsupported");
		tmp4 = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
		tmp2 = mxCreateString("Could not get value");
		tmp3 = mxCreateString("Could not get value");
		tmp4 = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "HardwareVersion.ProductID", tmp);
	mxSetField(m, 0, "HardwareVersion.SerialNumber", tmp2);
	mxSetField(m, 0, "HardwareVersion.FirmwareVersion", tmp3);
	mxSetField(m, 0, "HardwareVersion.FpgaVersion", tmp4);

	/* Imager Chip ID */
	nRetValue = PimMegaGetImagerChipId(deviceId, &imagerChipIdValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)imagerChipIdValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "ImagerChipId", tmp);

	/* Imager Clocking */
	nRetValue = PimMegaGetImagerClocking(deviceId, &imagerClockingValue);

	if (ApiSuccess == nRetValue)
	{
		if (imagerClockingValue == 0x00)
		{
			tmp = mxCreateString("0x00: External (16MHz) No division");
		}
		else if (imagerClockingValue == 0x01)
		{
			tmp = mxCreateString("0x01: External (16MHz) Division by 2");
		}
		else if (imagerClockingValue == 0x02)
		{
			tmp = mxCreateString("0x02: External (16MHz) Division by 4");
		}
		else if (imagerClockingValue == 0x80)
		{
			tmp = mxCreateString("0x80: Internal (24MHz) No division");
		}
		else if (imagerClockingValue == 0x81)
		{
			tmp = mxCreateString("0x81: Internal (24MHz) Division by 2");
		}
		else if (imagerClockingValue == 0x82)
		{
			tmp = mxCreateString("0x82: Internal (24MHz) Division by 4");
		}
		else
		{
			tmp = mxCreateString("Unknown value");
		}
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "ImagerClocking", tmp);

	/* Imager Name */
	imagerNameValue = (char *)mxCalloc(81, sizeof(char));

	nRetValue = PimMegaGetImagerName(deviceId, imagerNameValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateString(imagerNameValue);
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "ImagerName", tmp);

	/* Imager Type */
	nRetValue = PimMegaGetImagerType(deviceId, &imagerTypeValue);

	if (ApiSuccess == nRetValue)
	{
		if (imagerTypeValue == PCS2112M_IMAGER)
		{
			tmp = mxCreateString("PCS2112M_IMAGER (Monochrome Camera)");
		}
		else if (imagerTypeValue == PCS2112C_IMAGER)
		{
			tmp = mxCreateString("PCS2112C_IMAGER (Color Camera)");
		}
		else
		{
			tmp = mxCreateString("Unknown value");
		}
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "ImagerType", tmp);

	/* Mono Gain */
	nRetValue = PimMegaGetMonoGain(deviceId, &monoGainValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)monoGainValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "MonoGain", tmp);

	/* Preview Window Pos */
	nRetValue = PimMegaGetPreviewWindowPos(deviceId, &previewWindowPosLeftValue, &previewWindowPosTopValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (long)previewWindowPosLeftValue;
		tmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr2 = mxGetPr(tmp2);
		tmppr2[0] = (long)previewWindowPosTopValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
		tmp2 = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
		tmp2 = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "PreviewWindowPos.Left", tmp);
	mxSetField(m, 0, "PreviewWindowPos.Top", tmp2);

	/* Preview Window Size */
	nRetValue = PimMegaGetPreviewWindowSize(deviceId, &previewWindowSizeWidthValue, &previewWindowSizeHeightValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)previewWindowSizeWidthValue;
		tmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr2 = mxGetPr(tmp2);
		tmppr2[0] = (U32)previewWindowSizeHeightValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
		tmp2 = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
		tmp2 = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "PreviewWindowSize.Width", tmp);
	mxSetField(m, 0, "PreviewWindowSize.Height", tmp2);

	/* Red Gain */
	nRetValue = PimMegaGetRedGain(deviceId, &redGainValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)redGainValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "RedGain", tmp);

	/* Saturation */
	nRetValue = PimMegaGetSaturation(deviceId, &saturationValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)saturationValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "Saturation", tmp);

	/* Serial Number */
	nRetValue = PimMegaGetSerialNumber(deviceId, &serialNumberValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)serialNumberValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "SerialNumber", tmp);

	/* Software Version */
	nRetValue = PimMegaGetSoftwareVersion(deviceId, &softwareVersionValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)softwareVersionValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "SoftwareVersion", tmp);

	/* Sub Window */
	nRetValue = PimMegaGetSubWindow(deviceId, &subWindowDecimationValue, &subWindowStartColumnValue, &subWindowStartRowValue, &subWindowNumberColumnsValue, &subWindowNumberRowsValue);

	if (ApiSuccess == nRetValue)
	{
		if (subWindowDecimationValue == PCS2112_NO_DECIMATION)
		{
			tmp = mxCreateString("PCS2112_NO_DECIMATION");
		}
		else if (subWindowDecimationValue == PCS2112_DECIMATE_BY_2)
		{
			tmp = mxCreateString("PCS2112_DECIMATE_BY_2");
		}
		else if (subWindowDecimationValue == PCS2112_DECIMATE_BY_4)
		{
			tmp = mxCreateString("PCS2112_DECIMATE_BY_4");
		}
		else
		{
			tmp = mxCreateString("Unknown value");
		}

		tmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr2 = mxGetPr(tmp2);
		tmppr2[0] = (U32)subWindowStartColumnValue;
		tmp3 = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr3 = mxGetPr(tmp3);
		tmppr3[0] = (U32)subWindowStartRowValue;
		tmp4 = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr4 = mxGetPr(tmp4);
		tmppr4[0] = (U32)subWindowNumberColumnsValue;
		tmp5 = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr5 = mxGetPr(tmp5);
		tmppr5[0] = (U32)subWindowNumberRowsValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
		tmp2 = mxCreateString("Unsupported");
		tmp3 = mxCreateString("Unsupported");
		tmp4 = mxCreateString("Unsupported");
		tmp5 = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
		tmp2 = mxCreateString("Could not get value");
		tmp3 = mxCreateString("Could not get value");
		tmp4 = mxCreateString("Could not get value");
		tmp5 = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "SubWindow.Decimation", tmp);
	mxSetField(m, 0, "SubWindow.StartColumn", tmp2);
	mxSetField(m, 0, "SubWindow.StartRow", tmp3);
	mxSetField(m, 0, "SubWindow.NumberColumns", tmp4);
	mxSetField(m, 0, "SubWindow.NumberRows", tmp5);

	/* Sub Window Pos */
	nRetValue = PimMegaGetSubWindowPos(deviceId, &subWindowPosStartColumnValue, &subWindowPosStartRowValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)subWindowPosStartColumnValue;
		tmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr2 = mxGetPr(tmp2);
		tmppr2[0] = (U32)subWindowPosStartRowValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
		tmp2 = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
		tmp2 = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "SubWindowPos.StartColumn", tmp);
	mxSetField(m, 0, "SubWindowPos.StartRow", tmp2);

	/* Sub Window Size */
	nRetValue = PimMegaGetSubWindowSize(deviceId, &subWindowSizeDecimationValue, &subWindowSizeWidthValue, &subWindowSizeHeightValue);

	if (ApiSuccess == nRetValue)
	{
		if (subWindowSizeDecimationValue == PCS2112_NO_DECIMATION)
		{
			tmp = mxCreateString("PCS2112_NO_DECIMATION");
		}
		else if (subWindowSizeDecimationValue == PCS2112_DECIMATE_BY_2)
		{
			tmp = mxCreateString("PCS2112_DECIMATE_BY_2");
		}
		else if (subWindowSizeDecimationValue == PCS2112_DECIMATE_BY_4)
		{
			tmp = mxCreateString("PCS2112_DECIMATE_BY_4");
		}
		else
		{
			tmp = mxCreateString("Unknown value");
		}

		tmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr2 = mxGetPr(tmp2);
		tmppr2[0] = (U32)subWindowSizeWidthValue;
		tmp3 = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr3 = mxGetPr(tmp3);
		tmppr3[0] = (U32)subWindowSizeHeightValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
		tmp2 = mxCreateString("Unsupported");
		tmp3 = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
		tmp2 = mxCreateString("Could not get value");
		tmp3 = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "SubWindowSize.Decimation", tmp);
	mxSetField(m, 0, "SubWindowSize.Width", tmp2);
	mxSetField(m, 0, "SubWindowSize.Height", tmp3);

	/* Timeout */
	nRetValue = PimMegaGetTimeout(deviceId, &timeoutValue);

	if (ApiSuccess == nRetValue)
	{
		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)timeoutValue;
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "Timeout", tmp);

	/* Video Mode */
	nRetValue = PimMegaGetVideoMode(deviceId, &videoModeValue);

	if (ApiSuccess == nRetValue)
	{
		if (videoModeValue == STILL_MODE)
		{
			tmp = mxCreateString("STILL_MODE");
		}
		else if (videoModeValue == VIDEO_MODE)
		{
			tmp = mxCreateString("VIDEO_MODE");
		}
		else
		{
			tmp = mxCreateString("Unknown value");
		}
	}
	else if (ApiNotSupportedError == nRetValue)
	{
		tmp = mxCreateString("Unsupported");
	}
	else
	{
		tmp = mxCreateString("Could not get value");
	}
	mxSetField(m, 0, "VideoMode", tmp);

	/* GrabColorConversion */
	rhs[0] = mxCreateString("getpar");
	rhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
	px = mxGetPr(rhs[1]);
	px[0] = (U32)serialNumber;
	rhs[2] = mxCreateString("GrabColorConversion");
	mexCallMATLAB(1, lhs, 3, rhs, "plDevices");
	grabColorConversion = (U32)mxGetScalar(lhs[0]);

	switch (grabColorConversion)
	{
		case BAYER_2BY2_COLOR:			tmp = mxCreateString("BAYER_2BY2_COLOR");
										break;
		case BAYER_3BY3_COLOR:			tmp = mxCreateString("BAYER_3BY3_COLOR");
										break;
		case BAYER_3BY3GGRAD_COLOR:		tmp = mxCreateString("BAYER_3BY3GGRAD_COLOR");
										break;
		case BAYER_2PASSGRAD_COLOR:		tmp = mxCreateString("BAYER_2PASSGRAD_COLOR");
										break;
		case BAYER_2PASSADAPT_COLOR:	tmp = mxCreateString("BAYER_2PASSADAPT_COLOR");
										break;
		case BAYER_VARGRAD_COLOR:		tmp = mxCreateString("BAYER_VARGRAD_COLOR");
										break;
		case BAYER_2BY2_MONO:			tmp = mxCreateString("BAYER_2BY2_MONO");
										break;
		case BAYER_3BY3_MONO:			tmp = mxCreateString("BAYER_3BY3_MONO");
										break;
		case BAYER_ADAPT_MONO:			tmp = mxCreateString("BAYER_ADAPT_MONO");
										break;
		case BAYER_NO_CONVERSION:		tmp = mxCreateString("BAYER_NO_CONVERSION");
										break;
		default:						tmp = mxCreateString("Unknown value");
										break;
	}
	mxSetField(m, 0, "GrabColorConversion", tmp);

	/* GrabOutputType */
	rhs[0] = mxCreateString("getpar");
	rhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
	px = mxGetPr(rhs[1]);
	px[0] = (U32)serialNumber;
	rhs[2] = mxCreateString("GrabOutputType");
	mexCallMATLAB(1, lhs, 3, rhs, "plDevices");
	grabOutputType = (U32)mxGetScalar(lhs[0]);

	switch (grabOutputType)
	{
		case RAW:		tmp = mxCreateString("RAW");
										break;
		case IMAGE:		tmp = mxCreateString("IMAGE");
										break;
		case RGB24:		tmp = mxCreateString("RGB24");
										break;
		default:						tmp = mxCreateString("Unknown value");
										break;
	}
	mxSetField(m, 0, "GrabOutputType", tmp);

	/* return the device handle array */
	returnArray[0] = m;
	return;
}
