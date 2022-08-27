#include "stdafx.h"
#include <dshow.h>
#include <Qedit.h>	// for ISampleGrabber

#include "VideoFormat.h"
#include "DSCaptureException.h"
#include "DSCaptureStream.h"
#include "DSCaptureInfo.h"
#include "Image.h"

#ifdef _DEBUG
#define new DEBUG_NEW
#endif

extern int ConnectFilters(IGraphBuilder* pGraph, IBaseFilter* pFilterUpstream, IBaseFilter* pFilterDownstream);

class CMediaEventHandler : public ISampleGrabberCB 
{
public:
	CMediaEventHandler(DSCaptureStream* pStream,CaptureObserver *pClient)
    {
		m_pStream = pStream;
		m_pClient = pClient;
		m_bytesPerPixel = -1;
		m_imagePtr = NULL;

		//m_bytesPerPixel = m_pStream->getBitsPerPixel() /8;
		//m_imageSize = m_pStream->getVideoFormat().getWidth() * m_pStream->getVideoFormat().getHeight() * m_bytesPerPixel;
		//m_imagePtr  = new unsigned char [m_imageSize];

		m_flipImage = true;
		m_bStop = false;
	    m_hStoppedEvent = CreateEvent(NULL,false,false,NULL);
		InitializeCriticalSection(&m_critSect);
   }
	~CMediaEventHandler()
	{
  	  delete [] m_imagePtr;
	  DeleteCriticalSection(&m_critSect);
	  CloseHandle(m_hStoppedEvent);
	}

    STDMETHODIMP_(ULONG) AddRef() { return 2; }
    STDMETHODIMP_(ULONG) Release() { return 1; }

    STDMETHODIMP QueryInterface(REFIID riid, void ** ppv)
    {
        if (riid == IID_ISampleGrabberCB || riid == IID_IUnknown) 
        {
            *ppv = (void *) static_cast<ISampleGrabberCB *>(this);
            return NOERROR;
        }    
        return E_NOINTERFACE;
    }

    STDMETHODIMP SampleCB( double SampleTime, IMediaSample * pSample )
    {
         BYTE *pBuffer;

		 EnterCriticalSection(&m_critSect);

		 if (m_bStop)
		 {
			 SetEvent(m_hStoppedEvent);
			 LeaveCriticalSection(&m_critSect);
			 return 0;
		 }

		 pSample->GetPointer(&pBuffer);

		if (m_bytesPerPixel < 0)
		{
			m_bytesPerPixel = m_pStream->getBitsPerPixel() /8;
			m_imageSize = m_pStream->getVideoFormat().getWidth() * m_pStream->getVideoFormat().getHeight() * m_bytesPerPixel;
			m_imagePtr  = new unsigned char [m_imageSize];
		}

        int width = m_pStream->getVideoFormat().getWidth();
        int height = m_pStream->getVideoFormat().getHeight();
		int actualLen=pSample->GetActualDataLength();

		for (long row=0;row < height;row++)
		{
			if (m_flipImage)
			{
				memcpy((m_imagePtr+row*width*m_bytesPerPixel), pBuffer + (height-1-row)*width*m_bytesPerPixel,width*m_bytesPerPixel);
			}
			else
			{
				memcpy((m_imagePtr+row*width*m_bytesPerPixel), pBuffer + row*width*m_bytesPerPixel,width*m_bytesPerPixel);
			}
		}

		Image image(m_pStream->getVideoFormat(), m_imagePtr , pSample->GetActualDataLength());

		//CString msg;
		//msg.Format("onNewImage: format= %d width = %d height = %d ptr=0x%x size = %d\n",format,m_pStream->getVideoFormat().getWidth(),m_pStream->getVideoFormat().getHeight(), m_imagePtr , pSample->GetActualDataLength());
		//OutputDebugString(msg);

		m_pClient->onNewImage(m_pStream,&image);

		LeaveCriticalSection(&m_critSect);
        return 0;
    }

    STDMETHODIMP BufferCB( double SampleTime, BYTE * pBuffer, long BufferLen )
    {
        return 0;
    }

	void Stop()
	{
	    EnterCriticalSection(&m_critSect);
		m_bStop = true;
	    LeaveCriticalSection(&m_critSect);
		DWORD waitResult=WaitForSingleObject(m_hStoppedEvent,10000);
	}

	void Run()
	{
		m_bStop = false;
	}

private:
  CaptureObserver  *m_pClient;
  DSCaptureStream    *m_pStream;
  int m_imageSize;
  int m_bytesPerPixel;
  unsigned char * m_imagePtr;
  bool m_flipImage;
  bool m_bStop;
  CRITICAL_SECTION m_critSect;
  HANDLE m_hStoppedEvent;
};

//  Free an existing media type (ie free resources it holds)

void WINAPI FreeMediaType(AM_MEDIA_TYPE& mt)
{
    if (mt.cbFormat != 0) {
        CoTaskMemFree((PVOID)mt.pbFormat);

        // Strictly unnecessary but tidier
        mt.cbFormat = 0;
        mt.pbFormat = NULL;
    }
    if (mt.pUnk != NULL) {
        mt.pUnk->Release();
        mt.pUnk = NULL;
    }
}

// general purpose function to delete a heap allocated AM_MEDIA_TYPE structure
// which is useful when calling IEnumMediaTypes::Next as the interface
// implementation allocates the structures which you must later delete
// the format block may also be a pointer to an interface to release

void WINAPI DeleteMediaType(AM_MEDIA_TYPE *pmt)
{
    // allow NULL pointers for coding simplicity

    if (pmt == NULL) {
        return;
    }

    FreeMediaType(*pmt);
    CoTaskMemFree((PVOID)pmt);
}

DSCaptureStream::DSCaptureStream(CaptureInfo *pCaptureInfo)
{

	m_pCaptureInfo = new struct CaptureInfo;
	*m_pCaptureInfo = *pCaptureInfo;
	m_pStreamEventHandler = NULL;
	m_format = VideoFormat();
	m_bitsPerPixel = 0;
	m_pCurMediaType = NULL;
	m_bPaused = false;
	enumMyMediaTypes();
}

DSCaptureStream::~DSCaptureStream()
{
	for (unsigned i=0;i<m_pCaptureInfo->m_mediaTypes.size();i++)
	{
		DeleteMediaType(m_pCaptureInfo->m_mediaTypes.front());
		m_pCaptureInfo->m_mediaTypes.pop_front();
	}
	delete m_pCaptureInfo;
}

#define USE_RESUMABLE_STOP 1

void DSCaptureStream::start()// throws CaptureException;
{
	HRESULT hr;

	hr = m_pCaptureInfo->m_pSampleGrabber->SetCallback(m_pStreamEventHandler,0);
	DSCaptureException::CheckForFailure("pSampleGrabber->SetBufferSamples(TRUE) failed", hr);
	
	hr = m_pCaptureInfo->m_pSampleGrabber->SetBufferSamples(true);
	DSCaptureException::CheckForFailure("pSampleGrabber->SetBufferSamples(TRUE) failed", hr);
 	hr = m_pCaptureInfo->m_pSampleGrabber->SetOneShot(false); 
	DSCaptureException::CheckForFailure("pSampleGrabber->SetOneShot(TRUE) failed", hr);

	if (!USE_RESUMABLE_STOP || !m_bPaused)
	{		
		if (m_pCurMediaType)
		{
	        IAMStreamConfig     *pSC;
	
	        // Retrieve a pointer to the IAMStreamConfig interface
	        m_pCaptureInfo->m_pBuild->FindInterface(&PIN_CATEGORY_CAPTURE,
	                                  &MEDIATYPE_Video,
	                                  m_pCaptureInfo->m_pBaseFilter,
	                                  IID_IAMStreamConfig, (void **)&pSC);
	
	        hr=pSC->SetFormat(m_pCurMediaType);
	        if (FAILED(hr)) 
	        {
	            pSC->Release();
	            return ;
	        }
	        pSC->Release();
		}
	
		
		hr = ConnectFilters(m_pCaptureInfo->m_pGraph, m_pCaptureInfo->m_pBaseFilter, m_pCaptureInfo->m_pGrabberBaseFilter);
		DSCaptureException::CheckForFailure("ConnectFilters", hr);
		hr = ConnectFilters(m_pCaptureInfo->m_pGraph, m_pCaptureInfo->m_pGrabberBaseFilter,m_pCaptureInfo->m_pRenderer);
		DSCaptureException::CheckForFailure("ConnectFilters NULL renderer Failed", hr);
	
		getMediaInfo();
		//Step 4: Now we run the graph and collects the data from the sample grabber.
	}
	
	if (m_pStreamEventHandler)
	{
		m_pStreamEventHandler->Run();
	}


	hr = m_pCaptureInfo->m_pMediaControl->Run();
	DSCaptureException::CheckForFailure("pMediaControl->Run() failed", hr);
	m_bPaused = false;
}


void DSCaptureStream::stop()// throws CaptureException;
{
	HRESULT hr;

	if (m_pStreamEventHandler)
	{
		printf("DSCaptureStream::stop, stopping...\n"); fflush(stdout);
		m_pStreamEventHandler->Stop();
		printf("DSCaptureStream::stop, stopped.\n"); fflush(stdout);

		hr = m_pCaptureInfo->m_pSampleGrabber->SetCallback(NULL,0);
		DSCaptureException::CheckForFailure("pSampleGrabber->SetBufferSamples(TRUE) failed", hr);
	}

	if (m_pCaptureInfo)
	{
		hr = m_pCaptureInfo->m_pMediaControl->Stop();
		DSCaptureException::CheckForFailure("m_pCaptureInfo->m_pMediaControl->Stop failed", hr);
	}
	
#if USE_RESUMABLE_STOP	
	m_bPaused = true;
#endif


}
void DSCaptureStream::setObserver(CaptureObserver *_observer)
{
	m_pObserver = _observer;
	if (m_pStreamEventHandler)
	{
		delete m_pStreamEventHandler;
	}
	m_pStreamEventHandler = new CMediaEventHandler(this,m_pObserver);
}

//-----------------------------------------------------------------------------------------
// Tear down everything downstream of a given filter
bool DSCaptureStream::nukeDownstream(IBaseFilter *pf,IGraphBuilder *pFilterGraph)
{
    IPin        *pP, *pTo;
    ULONG       u;
    IEnumPins   *pins = NULL;
    PIN_INFO    pininfo;
    HRESULT     hr;
    ULONG       uRefCount;

    hr = pf->EnumPins(&pins);

    pins->Reset();
    while (hr == NOERROR) 
    {
        hr = pins->Next(1, &pP, &u);
        if (hr == S_OK && pP) 
        {
            pP->ConnectedTo(&pTo);
            if (pTo) 
            {
                hr = pTo->QueryPinInfo(&pininfo);
                if (hr == NOERROR) 
                {
                    if (pininfo.dir == PINDIR_INPUT) 
                    {
                        nukeDownstream(pininfo.pFilter,pFilterGraph);
                        pFilterGraph->Disconnect(pTo);
                        pFilterGraph->Disconnect(pP);
                        pFilterGraph->RemoveFilter(pininfo.pFilter);
                    }
                    uRefCount = pininfo.pFilter->Release();
                }
                pTo->Release();
            }
            pP->Release();
        } 
    }
    if (pins)
        pins->Release();
    return true;
}

void DSCaptureStream::dispose()// throws CaptureException;
{
 	HRESULT     hr;

	if (m_pCaptureInfo)
	{
		if (m_pCaptureInfo->m_pGraph != NULL && m_pCaptureInfo->m_pBaseFilter != NULL)
		{	nukeDownstream(m_pCaptureInfo->m_pBaseFilter, m_pCaptureInfo->m_pGraph);
			m_pCaptureInfo->m_pGraph->Release();
		}
	}
}

void DSCaptureStream::threadMain()// throws CaptureException;
{	// called from another thread, this method is allowed to never return until dispose is called.
	// this saves us the trouble of creating our own thread.  Use of this method to do anything is optional.
}

void DSCaptureStream::getMediaInfo()
{
	IAMStreamConfig *pStreamCtrl= NULL;
	AM_MEDIA_TYPE mediaType;
	VIDEOINFOHEADER *pInfo;

    // Get the camera supported formats
	HRESULT hr = m_pCaptureInfo->m_pSampleGrabber->GetConnectedMediaType(&mediaType);
	DSCaptureException::CheckForFailure("m_pCaptureInfo->m_pSampleGrabber->GetConnectedMediaType() failed", hr);

	pInfo = reinterpret_cast<VIDEOINFOHEADER*> (mediaType.pbFormat);
	m_format = buildVideoFormat(&mediaType, NULL);
  	m_bitsPerPixel = pInfo->bmiHeader.biBitCount;

}

void DSCaptureStream::enumMyMediaTypes()
{
	IPin        *pPin;
	HRESULT hr = m_pCaptureInfo->m_pBuild->FindPin(m_pCaptureInfo->m_pBaseFilter,PINDIR_OUTPUT,&PIN_CATEGORY_CAPTURE, NULL, false, 0, &pPin);
	if (SUCCEEDED(hr))
	{
		IEnumMediaTypes *pEnum;
		pPin->EnumMediaTypes(&pEnum);
		if (pEnum)
		{	ULONG c=1;
			AM_MEDIA_TYPE *mt;
			bool bFirst = true;
			while (c > 0)
			{
				pEnum->Next(1, &mt, &c);
				if (c)
				{
					m_pCaptureInfo->m_mediaTypes.push_back(mt);
					if (bFirst)
					{
						// assume first reported format is the default
						bFirst = false;
						VIDEOINFOHEADER *pInfo = reinterpret_cast<VIDEOINFOHEADER*> (mt->pbFormat);
						m_format = buildVideoFormat(mt, NULL);
					  	m_bitsPerPixel = pInfo->bmiHeader.biBitCount;
					}
				}
			}
		}
	}
}
void DSCaptureStream::enumVideoFormats(std::list<VideoFormat> &result)
{
	std::list<AM_MEDIA_TYPE *>::iterator iter = m_pCaptureInfo->m_mediaTypes.begin();
   
	for (unsigned i=0;i<m_pCaptureInfo->m_mediaTypes.size();i++)
	{
		AM_MEDIA_TYPE *mt = *iter;
		result.push_back(buildVideoFormat(mt, mt));
		iter++;
	}
}

VideoFormat DSCaptureStream::getVideoFormat() // throws CaptureException;
{
	return m_format;
}

VideoFormat DSCaptureStream::buildVideoFormat(AM_MEDIA_TYPE *mt, void *handle)
{
	VIDEOINFOHEADER *pInfo = reinterpret_cast<VIDEOINFOHEADER*> (mt->pbFormat);
	float fps = 1.0f/(pInfo->AvgTimePerFrame * 100e-9f);
		
	return VideoFormat(handle,
							pInfo->bmiHeader.biBitCount == 32 ? RGB32 : RGB24, // TODO: we always convert to one of these, but we should make sure all the bases are covered.
							pInfo->bmiHeader.biWidth,
							pInfo->bmiHeader.biHeight,
							fps);
}

void DSCaptureStream::setVideoFormat(VideoFormat &format)
{
	AM_MEDIA_TYPE *mt = (AM_MEDIA_TYPE*)format.handle;
	if (mt == NULL)
		throw new DSCaptureException("cannot set format: null handle");
	if (mt->lSampleSize == 0)
		throw new DSCaptureException("cannot set format: lSampleSize == 0");
	
	m_pCurMediaType = mt;

	VIDEOINFOHEADER *pInfo = reinterpret_cast<VIDEOINFOHEADER*> (m_pCurMediaType->pbFormat);
	m_format = buildVideoFormat(m_pCurMediaType, NULL);
	m_bitsPerPixel = pInfo->bmiHeader.biBitCount;
}
