/************************************************************************/
/* Filename:	plGetValue.cpp											*/
/* Description: Source code for plGetValue								*/
/* Authors:		M.A.E.Bakker, L.I.Oei									*/
/*				maarten@panic.et.tudelft.nl, l.i.oei@its.tudelft.nl		*/
/* Date:		2002/08/08												*/
/* Updates:																*/		
/************************************************************************/
/* plGetValue returns the value of a given parameter.					*/
/************************************************************************/
/* Input:	returnarray (mxArray)	mxArray for receiving the structure	*/
/*			serialNumber (U32)		serialNumber of the device			*/
/*			parametername (string)	name of the parameter				*/
/* Output:	-															*/
/* Syntax:	plGetValue(returnArray, serialNumber, parametername)		*/
/************************************************************************/

#include <windows.h>
#include "Y:\soft95\matlab6\extern\include\mex.h"
#include "Y:\software\framegrab\pixelink\api\pimmegaapiuser.h"

#include "plError.h"
#include "plTypes.h"

void plGetValue(mxArray *returnArray[], U32 serialNumber, char* parametername)
{	/* m = mxArray structure to be returned as device handle */
	/* lhs, rhs used to call plDevices */
	mxArray *m, *lhs[1], *rhs[3];
	double *px;
	HANDLE deviceId;

	/* variable for receiving the error codes the pixelink api functions return */
	PXL_RETURN_CODE nRetValue;	

	char *fieldnames[5];
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

	U32		grabColorConversionValue = -1;
	U32		grabOutputTypeValue = -1;

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
	/*          Get the value of the given parameter					*/
    /********************************************************************/

	if (!strcmp(parametername, "DeviceID"))
	{	/* DeviceID */
		m = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(m);
		tmppr[0] = (int)deviceId;
	}
	else if (!strcmp(parametername, "BlueGain"))
	{	/* Blue Gain */
		nRetValue = PimMegaGetBlueGain(deviceId, &blueGainValue);
		
		if (plError(nRetValue, "getting BlueGain value"))
		{
			mexErrMsgTxt("\n");
		}

		m = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(m);
		tmppr[0] = (U32)blueGainValue;
	}
	else if (!strcmp(parametername, "CurrentFrameRate"))
	{	/* Current Frame Rate */
		nRetValue = PimMegaGetCurrentFrameRate(deviceId, &currentFrameRateValue);

		if (plError(nRetValue, "getting CurrentFrameRate value"))
		{
			mexErrMsgTxt("\n");
		}

		m = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(m);
		tmppr[0] = currentFrameRateValue;
	}
	else if (!strcmp(parametername, "DataTransferSize"))
	{	/* Data Transfer Size */
		nRetValue = PimMegaGetDataTransferSize(deviceId, &dataTransferSizeValue);

		if (plError(nRetValue, "getting DataTransferSize value"))
		{
			mexErrMsgTxt("\n");
		}

		if (dataTransferSizeValue == DATA_8BIT_SIZE)
		{
			m = mxCreateString("DATA_8BIT_SIZE");
		}
		else if (dataTransferSizeValue == DATA_16BIT_SIZE)
		{
			m = mxCreateString("DATA_16BIT_SIZE");
		}
		else
		{
			m = mxCreateString("Unknown value");
		}
	}
	else if (!strcmp(parametername, "Exposure"))
	{	/* Exposure */
		nRetValue = PimMegaGetExposure(deviceId, &exposureValue);

		if (plError(nRetValue, "getting Exposure value"))
		{
			mexErrMsgTxt("\n");
		}

		m = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(m);
		tmppr[0] = (U32)exposureValue;
	}
	else if (!strcmp(parametername, "ExposureTime"))
	{	/* Exposure Time */
		nRetValue = PimMegaGetExposureTime(deviceId, &exposureTimeValue);

		if (plError(nRetValue, "getting ExposureTime value"))
		{
			mexErrMsgTxt("\n");
		}

		m = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(m);
		tmppr[0] = exposureTimeValue;
	}
	else if (!strcmp(parametername, "Gamma"))
	{	/* Gamma */
		nRetValue = PimMegaGetGamma(deviceId, &gammaValue);

		if (plError(nRetValue, "getting Gamma value"))
		{
			mexErrMsgTxt("\n");
		}

		m = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(m);
		tmppr[0] = gammaValue;
	}
	else if (!strcmp(parametername, "Gpo"))
	{	/* Gpo */
		nRetValue = PimMegaGetGpo(deviceId, &gpoValue);

		if (plError(nRetValue, "getting BlueGain value"))
		{
			mexErrMsgTxt("\n");
		}

		if (gpoValue == 0)
		{
			m = mxCreateString("Off");
		}
		else if (gpoValue == 1)
		{
			m = mxCreateString("On");
		}
		else
		{
			m = mxCreateString("Unknown value");
		}
	}
	else if (!strcmp(parametername, "GreenGain"))
	{	/* Green Gain */
		nRetValue = PimMegaGetGreenGain(deviceId, &greenGainValue);

		if (plError(nRetValue, "getting GreenGain value"))
		{
			mexErrMsgTxt("\n");
		}

		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)greenGainValue;
	}
	else if (!strcmp(parametername, "HardwareVersion"))
	{	/* Hardware Version */
		nRetValue = PimMegaGetHardwareVersion(deviceId, &hardwareVersionValue);

		if (plError(nRetValue, "getting HardwareVersion value"))
		{
			mexErrMsgTxt("\n");
		}

		tmp = mxCreateString((const char *)hardwareVersionValue.ProductID);
		tmp2 = mxCreateString((const char *)hardwareVersionValue.SerialNumber);
		tmp3 = mxCreateString((const char *)hardwareVersionValue.FirmwareVersion);
		tmp4 = mxCreateString((const char *)hardwareVersionValue.FpgaVersion);

		fieldnames[0] = "ProductID";
		fieldnames[1] = "SerialNumber";
		fieldnames[2] = "FirmwareVersion";
		fieldnames[3] = "FpgaVersion";
		m = mxCreateStructMatrix(1, 1, 4, (const char **)fieldnames);

		mxSetField(m, 0, "ProductID", tmp);
		mxSetField(m, 0, "SerialNumber", tmp2);
		mxSetField(m, 0, "FirmwareVersion", tmp3);
		mxSetField(m, 0, "FpgaVersion", tmp4);
	}
	else if (!strcmp(parametername, "ImagerChipId"))
	{	/* Imager Chip ID */
		nRetValue = PimMegaGetImagerChipId(deviceId, &imagerChipIdValue);

		if (plError(nRetValue, "getting ImagerChipId value"))
		{
			mexErrMsgTxt("\n");
		}

		m = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(m);
		tmppr[0] = (U32)imagerChipIdValue;
	}
	else if (!strcmp(parametername, "ImagerClocking"))
	{	/* Imager Clocking */
		nRetValue = PimMegaGetImagerClocking(deviceId, &imagerClockingValue);

		if (plError(nRetValue, "getting ImagerClocking value"))
		{
			mexErrMsgTxt("\n");
		}

		if (imagerClockingValue == 0x00)
		{
			m = mxCreateString("0x00\nOscilator type: External (16MHz)\nMax clock rate divided by: (no division)");
		}
		else if (imagerClockingValue == 0x01)
		{
			m = mxCreateString("0x01\nOscilator type: External (16MHz)\nMax clock rate divided by: 2");
		}
		else if (imagerClockingValue == 0x02)
		{
			m = mxCreateString("0x02\nOscilator type: External (16MHz)\nMax clock rate divided by: 4");
		}
		else if (imagerClockingValue == 0x80)
		{
			m = mxCreateString("0x80\nOscilator type: Internal (24MHz)\nMax clock rate divided by: (no division)");
		}
		else if (imagerClockingValue == 0x81)
		{
			m = mxCreateString("0x81\nOscilator type: Internal (24MHz)\nMax clock rate divided by: 2");
		}
		else if (imagerClockingValue == 0x82)
		{
			m = mxCreateString("0x82\nOscilator type: Internal (24MHz)\nMax clock rate divided by: 4");
		}
		else
		{
			m = mxCreateString("Unknown value");
		}
	}
	else if (!strcmp(parametername, "ImagerName"))
	{	/* Imager Name */
		imagerNameValue = (char *)mxCalloc(81, sizeof(char));

		nRetValue = PimMegaGetImagerName(deviceId, imagerNameValue);

		if (plError(nRetValue, "getting ImagerName value"))
		{
			mexErrMsgTxt("\n");
		}

		m = mxCreateString(imagerNameValue);
	}
	else if (!strcmp(parametername, "ImagerType"))
	{	/* Imager Type */
		nRetValue = PimMegaGetImagerType(deviceId, &imagerTypeValue);

		if (plError(nRetValue, "getting ImagerType value"))
		{
			mexErrMsgTxt("\n");
		}

		if (imagerTypeValue == PCS2112M_IMAGER)
		{
			m = mxCreateString("PCS2112M_IMAGER (Monochrome Camera)");
		}
		else if (imagerTypeValue == PCS2112C_IMAGER)
		{
			m = mxCreateString("PCS2112C_IMAGER (Color Camera)");
		}
		else
		{
			m = mxCreateString("Unknown value");
		}
	}
	else if (!strcmp(parametername, "MonoGain"))
	{	/* Mono Gain */
		nRetValue = PimMegaGetMonoGain(deviceId, &monoGainValue);

		if (plError(nRetValue, "getting MonoGain value"))
		{
			mexErrMsgTxt("\n");
		}

		m = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(m);
		tmppr[0] = (U32)monoGainValue;
	}
	else if (!strcmp(parametername, "PreviewWindowPos"))
	{	/* Preview Window Pos */
		nRetValue = PimMegaGetPreviewWindowPos(deviceId, &previewWindowPosLeftValue, &previewWindowPosTopValue);

		if (plError(nRetValue, "getting PreviewWindowPos value"))
		{
			mexErrMsgTxt("\n");
		}

		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (long)previewWindowPosLeftValue;
		tmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr2 = mxGetPr(tmp2);
		tmppr2[0] = (long)previewWindowPosTopValue;

		fieldnames[1] = "PreviewWindowPosLeft";
		fieldnames[0] = "PreviewWindowPosTop";
		m = mxCreateStructMatrix(1, 1, 2, (const char **)fieldnames);

		mxSetField(m, 0, "PreviewWindowPosLeft", tmp);
		mxSetField(m, 0, "PreviewWindowPosTop", tmp2);
	}
	else if (!strcmp(parametername, "PreviewWindowSize"))
	{	/* Preview Window Size */
		nRetValue = PimMegaGetPreviewWindowSize(deviceId, &previewWindowSizeWidthValue, &previewWindowSizeHeightValue);

		if (plError(nRetValue, "getting PreviewWindowSize value"))
		{
			mexErrMsgTxt("\n");
		}

		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)previewWindowSizeWidthValue;
		tmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr2 = mxGetPr(tmp2);
		tmppr2[0] = (U32)previewWindowSizeHeightValue;

		fieldnames[1] = "PreviewWindowSizeWidth";
		fieldnames[0] = "PreviewWindowSizeHeight";
		m = mxCreateStructMatrix(1, 1, 2, (const char **)fieldnames);

		mxSetField(m, 0, "PreviewWindowSizeWidth", tmp);
		mxSetField(m, 0, "PreviewWindowSizeHeight", tmp2);

	}
	else if (!strcmp(parametername, "RedGain"))
	{	/* Red Gain */
		nRetValue = PimMegaGetRedGain(deviceId, &redGainValue);

		if (plError(nRetValue, "getting RedGain value"))
		{
			mexErrMsgTxt("\n");
		}

		m = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(m);
		tmppr[0] = (U32)redGainValue;
	}
	else if (!strcmp(parametername, "Saturation"))
	{	/* Saturation */
		nRetValue = PimMegaGetSaturation(deviceId, &saturationValue);

		if (plError(nRetValue, "getting Saturation value"))
		{
			mexErrMsgTxt("\n");
		}

		m = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(m);
		tmppr[0] = (U32)saturationValue;
	}
	else if (!strcmp(parametername, "SerialNumber"))
	{	/* Serial Number */
		nRetValue = PimMegaGetSerialNumber(deviceId, &serialNumberValue);

		if (plError(nRetValue, "getting SerialNumber value"))
		{
			mexErrMsgTxt("\n");
		}

		m = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(m);
		tmppr[0] = (U32)serialNumberValue;
	}
	else if (!strcmp(parametername, "SoftwareVersion"))
	{	/* Software Version */
		nRetValue = PimMegaGetSoftwareVersion(deviceId, &softwareVersionValue);

		if (plError(nRetValue, "getting SoftwareVersion value"))
		{
			mexErrMsgTxt("\n");
		}

		m = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(m);
		tmppr[0] = (U32)softwareVersionValue;
	}
	else if (!strcmp(parametername, "SubWindow"))
	{	/* Sub Window */
		nRetValue = PimMegaGetSubWindow(deviceId, &subWindowDecimationValue, &subWindowStartColumnValue, &subWindowStartRowValue, &subWindowNumberColumnsValue, &subWindowNumberRowsValue);

		if (plError(nRetValue, "getting SubWindow value"))
		{
			mexErrMsgTxt("\n");
		}

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

		fieldnames[0] = "SubWindowDecimation";
		fieldnames[2] = "SubWindowStartColumn";
		fieldnames[1] = "SubWindowStartRow";
		fieldnames[4] = "SubWindowNumberColumns";
		fieldnames[3] = "SubWindowNumberRows";

		m = mxCreateStructMatrix(1, 1, 5, (const char **)fieldnames);

		mxSetField(m, 0, "SubWindowDecimation", tmp);
		mxSetField(m, 0, "SubWindowStartColumn", tmp2);
		mxSetField(m, 0, "SubWindowStartRow", tmp3);
		mxSetField(m, 0, "SubWindowNumberColumns", tmp4);
		mxSetField(m, 0, "SubWindowNumberRows", tmp5);
	}
	else if (!strcmp(parametername, "SubWindowPos"))
	{	/* Sub Window Pos */
		nRetValue = PimMegaGetSubWindowPos(deviceId, &subWindowPosStartColumnValue, &subWindowPosStartRowValue);

		if (plError(nRetValue, "getting SubWindowPos value"))
		{
			mexErrMsgTxt("\n");
		}

		tmp = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(tmp);
		tmppr[0] = (U32)subWindowPosStartColumnValue;
		tmp2 = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr2 = mxGetPr(tmp2);
		tmppr2[0] = (U32)subWindowPosStartRowValue;

		fieldnames[1] = "SubWindowPosStartColumn";
		fieldnames[0] = "SubWindowPosStartRow";
		m = mxCreateStructMatrix(1, 1, 2, (const char **)fieldnames);

		mxSetField(m, 0, "SubWindowPosStartColumn", tmp);
		mxSetField(m, 0, "SubWindowPosStartRow", tmp2);

	}
	else if (!strcmp(parametername, "SubWindowSize"))
	{	/* Sub Window Size */
		nRetValue = PimMegaGetSubWindowSize(deviceId, &subWindowSizeDecimationValue, &subWindowSizeWidthValue, &subWindowSizeHeightValue);

		if (plError(nRetValue, "getting SubWindowSize value"))
		{
			mexErrMsgTxt("\n");
		}

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

		fieldnames[0] = "SubWindowSizeDecimation";
		fieldnames[2] = "SubWindowSizeWidth";
		fieldnames[1] = "SubWindowSizeHeight";
		m = mxCreateStructMatrix(1, 1, 3, (const char **)fieldnames);

		mxSetField(m, 0, "SubWindowSizeDecimation", tmp);
		mxSetField(m, 0, "SubWindowSizeWidth", tmp2);
		mxSetField(m, 0, "SubWindowSizeHeight", tmp3);

	}
	else if (!strcmp(parametername, "Timeout"))
	{	/* Timeout */
		nRetValue = PimMegaGetTimeout(deviceId, &timeoutValue);

		if (plError(nRetValue, "getting Timeout value"))
		{
			mexErrMsgTxt("\n");
		}

		m = mxCreateDoubleMatrix(1, 1, mxREAL);
		tmppr = mxGetPr(m);
		tmppr[0] = (U32)timeoutValue;
	}
	else if (!strcmp(parametername, "VideoMode"))
	{	/* Video Mode */
		nRetValue = PimMegaGetVideoMode(deviceId, &videoModeValue);

		if (plError(nRetValue, "getting VideoMode value"))
		{
			mexErrMsgTxt("\n");
		}

		if (videoModeValue == STILL_MODE)
		{
			m = mxCreateString("STILL_MODE");
		}
		else if (videoModeValue == VIDEO_MODE)
		{
			m = mxCreateString("VIDEO_MODE");
		}
		else
		{
			m = mxCreateString("Unknown value");
		}
	}
	else if (!strcmp(parametername, "GrabColorConversion"))
	{	/* GrabColorConversion is kept in plDevices and used in plGrab */
		rhs[0] = mxCreateString("getpar");
		rhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
		px = mxGetPr(rhs[1]);
		px[0] = (U32)serialNumber;
		rhs[2] = mxCreateString("GrabColorConversion");
		
		mexCallMATLAB(1, lhs, 3, rhs, "plDevices");
		grabColorConversionValue = (U32)mxGetScalar(lhs[0]);

		switch (grabColorConversionValue)
		{
			case (BAYER_2BY2_COLOR):		m = mxCreateString("BAYER_2BY2_COLOR");
											break;
			case (BAYER_3BY3_COLOR):		m = mxCreateString("BAYER_3BY3_COLOR");
											break;
			case (BAYER_3BY3GGRAD_COLOR):	m = mxCreateString("BAYER_3BY3GGRAD_COLOR");
											break;
			case (BAYER_2PASSGRAD_COLOR):	m = mxCreateString("BAYER_2PASSGRAD_COLOR");
											break;
			case (BAYER_2PASSADAPT_COLOR):	m = mxCreateString("BAYER_2PASSADAPT_COLOR");
											break;
			case (BAYER_VARGRAD_COLOR):		m = mxCreateString("BAYER_VARGRAD_COLOR");
											break;
			case (BAYER_2BY2_MONO):			m = mxCreateString("BAYER_2BY2_MONO");
											break;
			case (BAYER_3BY3_MONO):			m = mxCreateString("BAYER_3BY3_MONO");
											break;
			case (BAYER_ADAPT_MONO):		m = mxCreateString("BAYER_ADAPT_MONO");
											break;
			case (BAYER_NO_CONVERSION):		m = mxCreateString("BAYER_NO_CONVERSION");
											break;
			default:						m = mxCreateString("Unknown value");
		}
	}
	else if (!strcmp(parametername, "GrabOutputType"))
	{	/* GrabOutputType is kept in plDevices and used in plGrab */
		rhs[0] = mxCreateString("getpar");
		rhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
		px = mxGetPr(rhs[1]);
		px[0] = (U32)serialNumber;
		rhs[2] = mxCreateString("GrabOutputType");
		
		mexCallMATLAB(1, lhs, 3, rhs, "plDevices");
		grabOutputTypeValue = (U32)mxGetScalar(lhs[0]);
		
		switch (grabOutputTypeValue)
		{
			case (RAW):		m = mxCreateString("RAW");
							break;
			case (IMAGE):	m = mxCreateString("IMAGE");
							break;
			case (RGB24):	m = mxCreateString("RGB24");
							break;
			default:		m = mxCreateString("Unknown value");
		}
	}
	else
	{
		mexPrintf("plGetValue: Unknown parameter.\n");
		mexPrintf("possible parameters are:\n");
		mexPrintf("DeviceID\n");
		mexPrintf("BlueGain\n");
		mexPrintf("CurrentFrameRate\n");
		mexPrintf("DataTransferSize\n");
		mexPrintf("Exposure\n");
		mexPrintf("ExposureTime\n");
		mexPrintf("Gamma\n");
		mexPrintf("Gpo\n");
		mexPrintf("GreenGain\n");
		mexPrintf("HardwareVersion\n");
		mexPrintf("ImagerChipId\n");
		mexPrintf("ImagerClocking\n");
		mexPrintf("ImagerName\n");
		mexPrintf("ImagerType\n");
		mexPrintf("MonoGain\n");
		mexPrintf("PreviewWindowPos\n");
		mexPrintf("PreviewWindowSize\n");
		mexPrintf("RedGain\n");
		mexPrintf("Saturation\n");
		mexPrintf("SerialNumber\n");
		mexPrintf("SoftwareVersion\n");
		mexPrintf("SubWindow\n");
		mexPrintf("SubWindowPos\n");
		mexPrintf("SubWindowSize\n");
		mexPrintf("Timeout\n");
		mexPrintf("VideoMode\n");
		mexPrintf("GrabColorConversion\n");
		mexPrintf("GrabOutputType\n");
		mexErrMsgTxt("\n");
	}

	returnArray[0] = m;
	return;
}
