#include <iostream>
#include <vector>
#include <chrono>
#include <string>
#include <cuda_runtime.h>

/* Пирамидальная сортировка на CUDA */

void print(int arr[], int size) {
	for (int i = 0; i < size; i++) {
		std::cout << arr[i] << " ";
	}
	std::cout << "\n";
}

__device__ void swap(int &a, int &b) {
	int temp = a;
	a = b;
	b = temp;
}

__device__ void heapify(int arr[], int n, int root)
{
	int largest = root;
	int l = 2 * root + 1;
	int r = 2 * root + 2;

	if (l < n && arr[l] > arr[largest])
		largest = l;

	if (r < n && arr[r] > arr[largest])
		largest = r;

	if (largest != root)
	{
		//std::swap(arr[root], arr[largest]);
		swap(arr[root], arr[largest]);

		heapify(arr, n, largest);
	}
}

__global__ void sort(int arr[], int n)
{
	for (int i = n / 2 - 1; i >= 0; i--)
		heapify(arr, n, i);

	for (int i = n - 1; i >= 0; i--)
	{
		swap(arr[0], arr[i]);
		heapify(arr, i, 0);
	}
}

void fillArray(int arr[], int size)
{
	for (int i = 0; i < size; i++)
	{
		arr[i] = rand() % size;
	}
}

int main()
{
	long long int arrSize = 0;
	int N = 0;
	std::cout << "Enter array size: ";
	std::cin >> arrSize;
	std::cout << "Enter numbers of threads:";
	std::cin >> N;

	int* arr = new int[arrSize];
	fillArray(arr, arrSize);

	int* dev_arr;
	cudaMalloc((void**)&dev_arr, arrSize * sizeof(int));
	cudaMemcpy(dev_arr, arr, arrSize * sizeof(int), cudaMemcpyHostToDevice);

	auto start = std::chrono::high_resolution_clock::now();

	sort << <1, N >> > (dev_arr, arrSize);
	
	auto end = std::chrono::high_resolution_clock::now();
	std::chrono::duration<float> duration = end - start;

	cudaMemcpy(arr, dev_arr, arrSize * sizeof(int), cudaMemcpyDeviceToHost);
	cudaFree(dev_arr);
	
	std::cout << "Parallel Time in nano: " << duration.count() << std::endl;


	
	delete[] arr;

	return 0;
}
