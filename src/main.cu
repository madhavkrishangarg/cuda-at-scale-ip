#include <iostream>
#include <opencv2/opencv.hpp>
#include <cuda_runtime.h>

__global__ void rgbToGrayscale(unsigned char* d_input, unsigned char* d_output, int width, int height, int channels) {
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;
    int idx = (y * width + x) * channels;

    if (x < width && y < height) {
        unsigned char r = d_input[idx];
        unsigned char g = d_input[idx + 1];
        unsigned char b = d_input[idx + 2];
        d_output[y * width + x] = 0.299f * r + 0.587f * g + 0.114f * b;
    }
}

int main(int argc, char** argv) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <image_path>" << std::endl;
        return -1;
    }

    std::string imagePath = argv[1];
    cv::Mat image = cv::imread(imagePath, cv::IMREAD_COLOR);
    if (image.empty()) {
        std::cerr << "Error: Could not open or find the image!" << std::endl;
        return -1;
    }

    int width = image.cols;
    int height = image.rows;
    int channels = image.channels();

    cv::Mat grayImage(height, width, CV_8UC1);

    unsigned char *d_input, *d_output;
    size_t imageSize = width * height * channels * sizeof(unsigned char);
    size_t grayImageSize = width * height * sizeof(unsigned char);

    cudaMalloc(&d_input, imageSize);
    cudaMalloc(&d_output, grayImageSize);

    cudaMemcpy(d_input, image.data, imageSize, cudaMemcpyHostToDevice);

    dim3 blockSize(16, 16);
    dim3 gridSize((width + blockSize.x - 1) / blockSize.x, (height + blockSize.y - 1) / blockSize.y);

    rgbToGrayscale<<<gridSize, blockSize>>>(d_input, d_output, width, height, channels);

    cudaMemcpy(grayImage.data, d_output, grayImageSize, cudaMemcpyDeviceToHost);

    cv::imwrite("output.png", grayImage);

    cudaFree(d_input);
    cudaFree(d_output);

    return 0;
} 