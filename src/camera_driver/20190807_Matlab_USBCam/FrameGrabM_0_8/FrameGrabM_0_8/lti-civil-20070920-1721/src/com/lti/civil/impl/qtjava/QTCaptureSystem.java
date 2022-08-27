/*
 * Created on May 27, 2005
 */
package com.lti.civil.impl.qtjava;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Logger;

import quicktime.QTException;
import quicktime.QTSession;

import com.lti.civil.CaptureException;
import com.lti.civil.CaptureStream;
import com.lti.civil.CaptureSystem;
import com.lti.civil.impl.common.CaptureDeviceInfoImpl;

/**
 * 
 * @author Ken Larson
 */
public class QTCaptureSystem implements CaptureSystem
{
	private static final Logger logger = Logger.global;

	public QTCaptureSystem()
	{
		super();
	}
	public void init() throws CaptureException
	{
		try 
		{
			logger.fine("Initializing quicktime");
			QTSession.open();
		} 
		catch (QTException e) 
		{
			throw new CaptureException(e);
		}

	}
	public void dispose() throws CaptureException
	{
		QTSession.close();
	}
	

	
	public List getCaptureDeviceInfoList() throws CaptureException
	{	
        
        final List result = new ArrayList();
  			// TODO: description.  TODO: migrate Native info.
			result.add(new CaptureDeviceInfoImpl("?", "?"));

		
		return result;
	}
	public CaptureStream openCaptureDeviceStream(final String deviceId) throws CaptureException
	{	

		try 
		{
			return new QTCaptureStream();
		} 
		catch (QTException e) 
		{
			throw new CaptureException(e);
		}

	}

}
