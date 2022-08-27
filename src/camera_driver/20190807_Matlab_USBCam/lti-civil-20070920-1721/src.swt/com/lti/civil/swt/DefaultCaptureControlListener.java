/*
 * Created on Jun 1, 2005
 */
package com.lti.civil.swt;

import java.io.FileOutputStream;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

import com.lti.civil.awt.AWTImageConverter;
import com.sun.image.codec.jpeg.JPEGCodec;
import com.sun.image.codec.jpeg.JPEGImageEncoder;

/**
 * Saves snapshot to a file.
 * @author Ken Larson
 */
public class DefaultCaptureControlListener implements CaptureControlListener
{
	private static final Logger logger = Logger.global;

	private String outputPath = "out.jpg";
	
	public void onSnap(com.lti.civil.Image image)
	{
//		 Encode as a JPEG
		if (image == null)
			return;
		try
		{
			FileOutputStream fos = new FileOutputStream(outputPath);
			JPEGImageEncoder jpeg = JPEGCodec.createJPEGEncoder(fos);
			jpeg.encode(AWTImageConverter.toBufferedImage(image));
			fos.close();
		}
		catch (IOException e)
		{	logger.log(Level.WARNING, "" + e, e);
		}		
	}

}
