#include <stdio.h>
#include "cv.h"
#include "highgui.h"
#include "gpu_grayscale.h"

int main( int argc, char** argv )
{
	IplImage  *frame, *new_frame;
	int key, i;
	unsigned char *pdata, *buffer;
	float elapsedtime;
		
	/* load the AVI file */
	CvCapture *capture = cvCaptureFromAVI( "out.avi" );
	
	if( !capture ) return 1;	
	
	int fps = ( int )cvGetCaptureProperty( capture, CV_CAP_PROP_FPS );
	
	/* display video */
	cvNamedWindow( "video", 0 );
	cvNamedWindow( "new_video", 0 );

	//cudaHostAlloc( (void **) &buffer, sizeof(unsigned char) * 240 * 320 * 4, cudaHostAllocDefault);
	buffer = new unsigned char[240*320*4]; 
	new_frame = cvCreateImage(cvSize(240,320),IPL_DEPTH_8U,1);
	
	while( key != 'q' ) {
		//////// get a frame //////////
		frame = cvQueryFrame( capture );
		
		/////// always check /////////
		if( !frame ) break;
	
		//printf(" %d ,%d ,%d , %d, ",frame->nSize,frame->width,frame->height,frame->nChannels);

		////////////// Padding the fourth byte ////////////		
		pdata = (unsigned char *)frame->imageData;
		for(i=0;i< 240*320 ;i++)
		{
			buffer[i * 4 + 0] = pdata[i * 3 + 0];
			buffer[i * 4 + 1] = pdata[i * 3 + 1];
			buffer[i * 4 + 2] = pdata[i * 3 + 2];
		}
		////////////// Call to CUDA function //////////////
		
		elapsedtime = tograyscale(buffer, (unsigned char *)new_frame->imageData);

		////////////// Creating a new frame /////////////////
		/*for(i=0;i<240*320;i++)
		{
		new_frame->imageData[i * 3 + 0] = buffer[i * 4 + 0]; 
		new_frame->imageData[i * 3 + 1] = buffer[i * 4 + 1];
		new_frame->imageData[i * 3 + 2] = buffer[i * 4 + 2];
		}*/	
		printf("Time taken is %f ",elapsedtime);
		
		//////// display frame /////////
		cvShowImage( "video", frame );
		cvShowImage( "new_video", new_frame );
		
		/// quit if user press 'q' /////
		key = cvWaitKey( 10 );
	}

	
	///////// Free memory ///////////
	cvReleaseCapture( &capture );
	cvDestroyWindow( "video" );
	cvDestroyWindow( "new_video" );

	return 0;
}
