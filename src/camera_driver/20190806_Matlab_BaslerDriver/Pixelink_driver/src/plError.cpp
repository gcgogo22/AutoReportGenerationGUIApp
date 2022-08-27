/************************************************************************/
/* Filename:	plError.cpp												*/
/* Description:	Source code for the error checking of the pl FGI		*/
/* Authors:		M.A.E.Bakker, L.I.Oei									*/
/*				maarten@panic.et.tudelft.nl, l.i.oei@its.tudelft.nl		*/
/* Date:		2002/08/02												*/
/* Updates:																*/
/************************************************************************/
/* plError translates a PixeLINK API status code into a useful error	*/
/* message.																*/
/************************************************************************/
/* Input:	(PXL_RETURN_CODE) the API's return code that should be		*/
/*			checked														*/
/*			(string) description when the possible fault occurred		*/
/* Output:	(int)	0 if no error										*/
/*				1 on an error that should be interpreted as a warning	*/
/*				2 on an error that should be interpreted as fatal		*/
/* Syntax:	i = plError(PXL_RETURN_CODE result, char* error);			*/
/************************************************************************/

#define WIN32_LEAN_AND_MEAN	/* Exclude rarely-used stuff from Windows */
#include <windows.h>
#include "Y:\soft95\matlab6\extern\include\mex.h"
#include "Y:\software\framegrab\pixelink\api\pimmegaapiuser.h"

int plError(PXL_RETURN_CODE result, char *error)
{
	char errorStr[49+33];
	strcpy(errorStr, "The device's API encountered a problem while ");
	strncat(errorStr, error, 33);
	strcat(errorStr, ":\n");
	if (result != ApiSuccess)
	{
		mexPrintf(errorStr);
	}
	switch (result)
	{
		case ApiSuccess:			return 0;
		case ApiNullHandleError:	mexPrintf("NULL-handle: the device was not sucessfully initialised.\n");
									return 2;
		case ApiNullPointerError:	mexPrintf("NULL-pointer: problem allocating required memory.\n");
									return 2;
		case ApiNoDeviceError:		mexPrintf("The camera may be disconnected.\n");
									return 1;
		case ApiCOMError:			mexPrintf("Windows COM object error.\n");
									return 2;
		case ApiIoctlError:			mexPrintf("I/O control error, API may be incompatible with driver.\n");
									return 2;
		case ApiFileOpenError:		mexPrintf("File I/O error.\n");
									return 1;
		case ApiInvalidParameterError:	mexPrintf("Invalid parameter.\n");
										return 2;
		case ApiImagerUnknownError:	mexPrintf("API doesn't recognize imager, should be PCS2112M_IMAGER or PCS2112C_IMAGER.\n");
									return 2;
		case ApiOutOfMemoryError:	mexPrintf("Unable to allocate required memory.\n");
									return 2;
		case ApiUnknownError:		mexPrintf("Error unknown to the API.\n");
									return 2;
		case ApiNoPreviewRunningError:	mexPrintf("The preview window is not open.\n");
										return 2;
		case ApiNotSupportedError:	mexPrintf("The camera does not support the requested functionality.\n");
									return 1;
		case ApiInvalidFunctionCallError:	mexPrintf("The function was called in an improper sequence.\n");
											return 2;
		case ApiHardwareError:		mexPrintf("Hardware error.\n");
									return 2;
		case ApiOSVersionError:		mexPrintf("Unsupported operating system version.\n");
									return 2;
		case ApiMaximumIterationsError:	mexPrintf("Too many internal iterations.\n");
										return 2;
		case ApiTimeoutError:		mexPrintf("Time limit exceeded, increasing the Timeout setting may solve the problem.\n");
									return 2;
		default:					mexPrintf("Error unknown to the FGI.\n");
									return 1;
	}
}
