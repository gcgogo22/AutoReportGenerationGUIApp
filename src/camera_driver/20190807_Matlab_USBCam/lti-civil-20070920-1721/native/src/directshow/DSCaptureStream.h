#include "CaptureStream.h"
#include "CaptureObserver.h"
#include "list"
class CMediaEventHandler;
struct CaptureInfo;

class DSCaptureStream: public CaptureStream
{
public:
	DSCaptureStream(CaptureInfo *pCaptureInfo);
	virtual ~DSCaptureStream();

	virtual void start();// throws CaptureException;
	virtual void stop();// throws CaptureException;
	virtual void threadMain();// throws CaptureException;
	virtual void dispose();// throws CaptureException;
	virtual void setObserver(CaptureObserver *_observer);
	virtual CaptureObserver *getObserver() {return m_pObserver;}
	virtual void enumVideoFormats(std::list<VideoFormat> &result); // throws CaptureException;
	virtual void setVideoFormat(VideoFormat &format); // throws CaptureException;
	virtual VideoFormat getVideoFormat(); // throws CaptureException;

	virtual int getBitsPerPixel()
	{
		return m_bitsPerPixel;
	}
private:
	void enumMyMediaTypes();

	CaptureObserver    *m_pObserver;
	CMediaEventHandler *m_pStreamEventHandler;	
	struct CaptureInfo *m_pCaptureInfo;
	AM_MEDIA_TYPE *m_pCurMediaType;

	VideoFormat m_format;
	int m_bitsPerPixel;
	bool m_bPaused;

	void getMediaInfo();

	bool nukeDownstream(IBaseFilter *pf,IGraphBuilder *pFilterGraph);
	
	// handle is separate from mt, in case mt is transient data, handle can be set to null.
	VideoFormat buildVideoFormat(AM_MEDIA_TYPE *mt, void *handle);

};
