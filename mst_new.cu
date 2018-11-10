#include <iostream>
#include <vector>
#include <cuda.h>
#include <thrust/device_vector.h>
#include <thrust/extrema.h>
#include <thrust/device_free.h>
#include <ctime>
using namespace std;

__global__ void weightUpdate(int *d_V, int *d_E, int *d_W, int *d_C, int * d_parent, int *d_weights, int *d_inMST) {
    int id = threadIdx.x + blockIdx.x * blockDim.x;
    if(id >= (d_V[d_C+1] - d_V[d_C]))
        return;
    int index = d_V[d_C] + id;
    int incoming_vertex = d_E[index];
    int edge_weight = d_W[d_V[index];
    if (d_weights[incoming_vertex] > edge_weight) {
        d_weights[incoming_vertex] = edge_weight;
        d_parent[incoming_vertex] = d_C;
    }
}
 
int main(){

    //freopen("graph.txt", "r", stdin);

    int nodes, edges;
    cin>>nodes>>edges;

    vector<vector<pair<int,int> > > adjacency_list(nodes);     
    for(int i = 0; i < edges; ++i){
        int node1, node2, weight;
        cin>>node1>>node2>>weight;
        
        adjacency_list[node1].push_back(make_pair(node2, weight));
        adjacency_list[node2].push_back(make_pair(node1, weight));
    }

    int * V = new int[nodes+1];
    int * E = new int[2 * edges];
    int * W = new int[2 * edges];

    int cumulative_sum = 0, limit;

    for(int i = 0; i < nodes; ++i){
        V[i] = cumulative_sum;
        limit = adjacency_list[i].size();
        for(int j = 0; j < limit; ++j){
            E[cumulative_sum + j] = adjacency_list[i][j].first;
            W[cumulative_sum + j] = adjacency_list[i][j].second;
        }
        cumulative_sum += limit;
    }
    V[nodes] = 2*edges;
    
    int *d_V, *d_E, *d_W;
    cudaMalloc((void **)&d_V, (nodes+1) * sizeof(int));
    cudaMalloc((void **)&d_E, 2 * edges * sizeof(int));
    cudaMalloc((void **)&d_W, 2 * edges * sizeof(bool));
    cudaMemcpy(d_V, V, nodes * sizeof(int),  cudaMemcpyHostToDevice);
    cudaMemcpy(d_E, E, 2 * edges * sizeof(int),  cudaMemcpyHostToDevice);
    cudaMemcpy(d_W, W, 2 * edges * sizeof(int),  cudaMemcpyHostToDevice);

    // for(int i = 0; i < nodes; i++)
    // {
    //     cout<<V[i]<<" ";
    // }
    // cout<<endl;
    // for(int i = 0; i < 2 * edges; i++)
    // {
    //     cout<<E[i]<<" "<<W[i]<<"\n";
    // }

    long long int ans = 0;
    int current = 0;
    int count = 0;

    int *parent = new int[nodes];
    int *weights = new int[nodes];
    bool *inMST = new bool[nodes];

    parent[0] = -1;
    for(int i = 0; i < nodes; ++i) {
        weights[i] = INT_MAX;
        inMST[i] = false;
    }

    int *d_parent, *d_weights, *d_inMST;
    cudaMalloc((void **)&d_parent, nodes * sizeof(int));
    cudaMalloc((void **)&d_weights, nodes * sizeof(int));
    cudaMalloc((void **)&d_inMST, nodes * sizeof(bool));

    
    cudaMemcpy(d_parent, parent, nodes * sizeof(int),  cudaMemcpyHostToDevice);
    cudaMemcpy(d_weights, weights, nodes * sizeof(int),  cudaMemcpyHostToDevice);
    cudaMemcpy(d_inMST, inMST, nodes * sizeof(bool),  cudaMemcpyHostToDevice);

    int C = 0;
    int *d_C;
    cudaMemcpy(d_C, &C, sizeof(int), cudaMemcpyHostToDevice);

    thrust::device_vector<int> device_weights(weights, weights + nodes);
    thrust::device_ptr<int> ptr = device_weights.data();

    clock_t begin = clock();
    // while all nodes are added to MST
    while(count < nodes-1){
        ++count;
        inMST[current] = true;


        // Find the mininum index
        int min_index = thrust::min_element(ptr, ptr + nodes) - ptr;
        // cout<<"Min Weight Index: "<<min_index<<endl;
        
        // update         
        parent[min_index] = current;
        ans += device_weights[min_index];
        device_weights[min_index] = INT_MAX;
        current = min_index;
    }
    clock_t end = clock();

    // print the parent
    for(int i = 0; i < nodes; ++i) {
        cout<<i<<"'s parent is "<<parent[i]<<endl;
    }
    // sum of all weights
    cout<<"Answer: "<<ans<<endl;

    // print the time
    double elapsed_time = double(end - begin) / CLOCKS_PER_SEC;
    cout<<"Execution time: "<<elapsed_time<<endl;

    // free all memory
    free(V); free(E); free(W);
    free(parent); free(weights); free(inMST); 

    return 0;
}

/*
9 14
0 1 4
0 7 8
1 7 11
1 2 8
2 8 2
2 3 7
2 5 4
7 8 7
7 6 1
6 8 6
6 5 2
3 5 14
3 4 9
4 5 10
*/