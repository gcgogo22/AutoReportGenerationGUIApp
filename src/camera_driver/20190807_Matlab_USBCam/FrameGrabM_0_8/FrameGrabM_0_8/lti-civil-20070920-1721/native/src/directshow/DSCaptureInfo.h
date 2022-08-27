#pragma once

   
struct CaptureInfo
{
	IGraphBuilder *m_pGraph;
	ICaptureGraphBuilder2 *m_pBuild;
	ISampleGrabber *m_pSampleGrabber;
	IMediaControl *m_pMediaControl;    // Store pointer to interface
	IMediaEvent *m_pMediaEvent;    // Store pointer to interface
	IBaseFilter *m_pBaseFilter;
	IBaseFilter *m_pRenderer;
	IBaseFilter* m_pGrabberBaseFilter;
	std::list<AM_MEDIA_TYPE *> m_mediaTypes;
};

