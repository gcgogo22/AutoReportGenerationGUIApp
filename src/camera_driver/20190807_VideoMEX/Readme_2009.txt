---------------------------------------------------------------------------------

----------------- CAMERA INPUT PACKAGE BY ERIC PFEIFFER -------------------------

---------------------------------------------------------------------------------



Part(1) - Compiler Instructions

Part(2) - Description of Video for Matlab 

Part(3) - Description of OpenCV library grabbing

Part(4) - Description of VideoInput library grabbing




=================================================================================
Part(1) - Compiler Instructions
=================================================================================




TESTED WITH MATLAB2007b AND Visual Studio 2005 C++ Express

---------------------------------------------------------------------
I want to compile the projects myself! Can I use Matlab-LCC compiler?
---------------------------------------------------------------------

No, this didn't work for me because of some problems with symbol exports of 
Video for Windows Interface library. Maybe you can do it - but it's much easier 
and comfortable (debugger!) to use the free Express Editions of Visual Studio.

It should be possible to open this project also with the newer versions - but 
this may also need a newer PSDK. 

If you have a professional version no SDK should be necessary.

********
Step (1)
********

Intall:

=> Visual Studio C++ 2005 Express 
=> Plattform SDK for Windows Server 2003 (R2) 
=> OpenCV v1.1 or newer

For minimal PSDK configuration see: 
"http://www.mathworks.com/matlabcentral/fx_files/13321/1/mex+MSVCExpress.pdf"
I also had to add WebWorkshop for some reason.

********
Step (2)
********

Modify (only for PSDK users!?):

=> atlwin.h at line 1753 (in function SetChainEntry):

   replace: 	for(i = 0; i < m_aChainEntry.GetSize(); i++)

   with:	// for(i = 0; i < m_aChainEntry.GetSize(); i++)
		for(int i = 0; i < m_aChainEntry.GetSize(); i++)


=> atlbase.h at line 290:

   replace:	#define AllocStdCallThunk() __AllocStdCallThunk()
		#define FreeStdCallThunk(p) __FreeStdCallThunk(p)
		#pragma comment(lib, "atlthunk.lib")
			
   with:	// #define AllocStdCallThunk() __AllocStdCallThunk()
		// #define AllocStdCallThunk() __AllocStdCallThunk()
		// #pragma comment(lib, "atlthunk.lib")
		#define AllocStdCallThunk() HeapAlloc(GetProcessHeap(),0, sizeof(_stdcallthunk))
		#define FreeStdCallThunk(p) HeapFree(GetProcessHeap(), 0, p)

********
Step (3)
********

Add PSDK, MATLAB-MEX AND OPENCV (only necessary for ocvgrab-project):

Recommended: Set as general paths in Menu->Tools->Properties->Projects->Folders

   => add to executables: 

<Your Folder>\Microsoft Platform SDK for Windows Server 2003 R2\Bin

   => add to includes: 

<Your Folder>\Microsoft Platform SDK for Windows Server 2003 R2\Include
<Your Folder>\Microsoft Platform SDK for Windows Server 2003 R2\Include\atl
<Your Folder>\Microsoft Platform SDK for Windows Server 2003 R2\Include\mfc
<Your Folder>\MATLAB\extern\include
<Your Folder>\OpenCV\cv\include
<Your Folder>\OpenCV\cvaux\include
<Your Folder>\OpenCV\cvcore\include
<Your Folder>\OpenCV\otherlibs\highgui
<Your Folder>\OpenCV\otherlibs\_graphics\include

   => add to libraries:

<Your Folder>\Microsoft Platform SDK for Windows Server 2003 R2\Lib
<Your Folder>\MATLAB\extern\lib\win32\microsoft
<Your Folder>\OpenCV\lib	

Or add these paths to the specific compiler/linker/ressource - configuration.


********
Step (4)
********

=> Select a desired configuration and compile.

For those who need/want to use old mex interface version there is also a Matlab 
R14 config version for each project. 

That's it - good luck.




=================================================================================
Part(2) - Description of Video for Matlab 
=================================================================================




This release is only a "quick and dirty" project file update for "vfm"-mexfile 
solution, which was programmed by Farzad Pezeshkpour for MATLAB v5 in 1998. All
information given in his "Readme.txt" and "license.txt" is still valid.

Since 1998 some changes in mex-programming occured and for some reasons the 
.dll's are now named ".mexw__" depending on processors architecture. Here it's 
assumed to be 32bit - so project builds "vfm.mexw32". For 64bit you will have to 
include different libraries.  

The original source has not been touched - but in fact it would be necessary to
do so - suggestion: modification is necessary for the way the MexArray is 
allocated and released. In my case Matlab instantly shuts down when clearing the 
mex-file after taking some images. 

Nevertheless a very good vfw-interface by Mr. Pezeshkpour !

----------------------
Where is the mex-file?
----------------------

There are two compiled versions in 

<archive>\compiled\release\ and <archive>\compiled\debug\

.\vfm.mexw32
.\vfm.m

Copy the files from one folder to your matlab work path and call for example:

>> while (1) imagesc(vfm('grab',1)); drawnow; end;

This should bring up a figure with non-stop camera image stream. (Ctrl-C)

Consult the help instructions in vfm.m for specific functions.

>> help vfm

---------------------------------------------------------------
The matlab crashes are awful ! Are there alternative solutions?
---------------------------------------------------------------

Yes - for all those, who don't need so much configuration stuff and simply want 
to get images from multiple vfw-compatible cam's (most usb and firewire cams) as 
fast as possible -  see section "ocvgrab" or "vigrab"




=================================================================================
Part(3) - Description of OpenCV library grabbing
=================================================================================




The idea comes from an old mex-solution based on OpenCV library that I was using 
a couple of years ago - i think it was developed by a Mr. Seiffert from Germany. 
But since there was no source available and the old .dll didn't work anymore, i 
decided to start from scratch with an OpenCV-sample and bring it into Matlab.

So what is the benefit: 

The most important benefit is, that you can use all the highly efficient 
OpenCV algorithms directly on the camera images within the mex file. So you can 
use the project as starting point for some image processing research.

But there is also some overhead due to this - to execute the mex-file additional
libraries (highgui110.dll and cxcore110.dll) which provide the OpenCV-functions 
have to be placed into the work folder and a "tricky" difference in the memory 
organisation of OpenCV images and Matlab images has to be solved. [To get an 
OpenCV-image into correct Matlab format the color planes must be separated and 
the column/row structure must be flipped. Actually this is done using OpenCV 
functions itself, but adds some annoying handling overhead.]

I tried to make it multithreading for multiple cams - but it seems that OpenCV 
architecture is not very happy with this. You can decide to take the pictures 
synchron (waiting for a new image from each cam) or asynchron (just giving back
the last valid image from each cam).

There can be still some exceptions evoked by camera interface (for example if 
you try to access a virtual camera like livecam avatar). Finally i discovered, 
that OpenCV just uses the videoinput-library from Theodore Watson - so i thought
why using opencv if you don't need the functions? For the result see "vigrab"...

----------------------
Where is the mex-file?
----------------------

There are two compiled versions in 

<archive>\ocvgrab\release\ and <archive>\ocvgrab\debug\

.\ocvgrab.mexw32
.\ocvgrab.m

Copy the files from one folder together with

..\cxcore110.dll
..\highgui110.dll

to your matlab work path and call for example:

>> while (1) imagesc(ocvgrab(0)); drawnow; end;

This should bring up a figure with non-stop camera image stream. (Ctrl-C)

Consult the help instructions in ocvgrab.m for specific functions.

>> help ocvgrab




=================================================================================
Part(4) - Description of VideoInput library grabbing
=================================================================================



This grabbing-solution overcomes the need for additional .dll's and the memory 
reorganization by directly accessing the (modified) videoinput library by 
Theodore Watson. It seems to be more stable and less performance consuming in 
relation to ocvgrab.

----------------------
Where is the mex-file?
----------------------

There are two compiled versions in 

<archive>\vigrab\release\ and <archive>\vigrab\debug\

.\vigrab.mexw32
.\vigrab.m
.\videoinput_eric.lib is not needed (only to compile)...

Copy the files from one folder to your matlab work path and call for example:

>> while (1) imagesc(vigrab(0)); drawnow; end;

This should bring up a figure with non-stop camera image stream. (Ctrl-C)

Consult the help instructions in vigrab.m for specific functions.

>> help vigrab


----------------------------------------
Can i compile videoinput-library myself?
----------------------------------------

Yes you can - but you will have to install DirectX 9.0 SDK (Feb. 2005) and adjust
the include and library path in videoinput-project.


---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

For any questions please use Matlab Central comments area.


Eric Pfeiffer

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------