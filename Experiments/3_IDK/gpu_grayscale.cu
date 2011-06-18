#include "cuda.h"

/////////////// Grayscale Cuda Fucntion ////////////////////
__global__ void convert(int width, int height, uchar4 *gpu_in)
{
	
	int tx = threadIdx.x + (blockIdx.x * blockDim.x);
	int ty = threadIdx.y + (blockIdx.y * blockDim.y);
	int offset = tx + ty * blockDim.x*gridDim.x;

	if(tx >= 240 || ty >= 320)
        return;	
		/*float color = 0.3 * (gpu_in[offset].x) + 0.6 * (gpu_in[offset].y) + 0.1 * (gpu_in[offset].z);
		gpu_in[offset].x = color;
		gpu_in[offset].y = color;
		gpu_in[offset].z = color;
		gpu_in[offset].w = 0;*/

	int offset4 = offset * 4;
		int c = *(unsigned int*)(&gpu_in[offset4]);
		int c1 = c / 16777216;
		int c2 = (c - (c1 * 16777216)) / 65536;
		int c3 = (c - (c1 * 16777216) - (c2 * 65536)) / 256;
		float color = 0.3f * c1 + 0.6f * c2 + 0.1f * c3;

		gpu_in[offset].x = (unsigned)color;
		gpu_in[offset].y = (unsigned)color;
		gpu_in[offset].z = (unsigned)color;
		gpu_in[offset].w = 0;
		
	
}
///////////////// CUDA function call wrapper /////////////////
float gpu_grayscale(int width, int height, unsigned char *in)
{
	uchar4 *gpu_in;
	float elapsedtime;
	cudaMalloc((void **)&gpu_in, (width * height * 4 * sizeof(unsigned char)));
	cudaMemcpy(gpu_in, in, (width * height * 4 * sizeof(unsigned char)), cudaMemcpyHostToDevice);
	cudaEvent_t start, stop;
	cudaEventCreate(&start);
	cudaEventCreate(&stop);
	cudaEventRecord(start,0);
	
	////////////////////////// Time consuming Task //////////////////////////////////	
	

	dim3 grid(18,18);
	dim3 block(16,16);
	convert<<<grid,block>>>(width, height, gpu_in);


	/////////////////////////////////////////////////////////////////////////////////

	cudaEventRecord(stop,0);
	cudaEventSynchronize(stop);
	cudaEventElapsedTime(&elapsedtime,start,stop);
		cudaMemcpy( in, gpu_in, (width * height * 4 * sizeof(unsigned char)), cudaMemcpyDeviceToHost);
	cudaFree(gpu_in);
	cudaEventDestroy(start);
	cudaEventDestroy(stop);
	return elapsedtime;
	
}

