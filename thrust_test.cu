#include <iostream>
#include <cuda.h>
#include <thrust/device_vector.h>
using namespace std; 

int main() {
    thrust::device_vector<int> a(1000, 0);
    for (int i = 0; i < 1000; i++) {
        a[i] = 10*i-90;
        cout<<i<<" "<<a[i]<<"\n";
    }
    thrust::device_ptr<int> ptr = a.data();
    cout<<thrust::min_element(ptr, ptr + 1000) - ptr;
    return 0;
}

