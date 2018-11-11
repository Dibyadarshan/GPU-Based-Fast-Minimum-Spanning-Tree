#include <iostream>
#include <vector>
#include <cuda.h>
#include <thrust/device_vector.h>
#include <thrust/extrema.h>
#include <thrust/device_free.h>
#include <ctime>
using namespace std;

int main(){

    //freopen("graph.txt", "r", stdin);

    // ======================== Input and Adj list formation ====================================
    // Input nodes and edges
    int nodes, edges;
    cin>>nodes>>edges;

    // create the adjancency list
    vector<vector<pair<int,int> > > adjacency_list(nodes); 
    for(int i = 0; i < edges; ++i){
        int node1, node2, weight;
        cin>>node1>>node2>>weight;
        adjacency_list[node1].push_back(make_pair(node2, weight));
        adjacency_list[node2].push_back(make_pair(node1, weight));
    }

    // create compressed adjancency list
    int * V = new int[nodes];
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
    // Check 
    // for(int i = 0; i < nodes; i++)
    // {
    //     cout<<V[i]<<" ";
    // }
    // cout<<endl;
    // for(int i = 0; i < 2 * edges; i++)
    // {
    //     cout<<E[i]<<" "<<W[i]<<"\n";
    // }


    // ======================== Variables init ====================================
    // sum of edge weights in MST 
    long long int edge_sum = 0;
    // current vertex under consideration
    int current = 0;
    // count of vertex added to MST
    int count = 0;

    int *parent = new int[nodes];
    vector<int> weights(nodes);
    bool *inMST = new bool[nodes];
    // init parents, weight and inMST array 
    parent[0] = -1;
    for(int i = 0; i < nodes; ++i) {
        weights[i] = INT_MAX;
        inMST[i] = false;
    }

    // device vector for the weights array
    thrust::device_vector<int> device_weights(weights.begin(), weights.end());
    thrust::device_ptr<int> ptr = device_weights.data();


    // ======================== Main code ====================================
    clock_t begin = clock();

    while(count < nodes-1){
        // add current vertex to MST
        ++count;
        inMST[current] = true;

        // update weights and parent arrays as per the current vertex in consideration
        int len = adjacency_list[current].size();
        for(int i = 0; i < len; ++i) {
            int incoming_vertex = adjacency_list[current][i].first;
            if(!inMST[incoming_vertex]) {
                if(weights[incoming_vertex] > adjacency_list[current][i].second) {
                    weights[incoming_vertex] = adjacency_list[current][i].second;
                    parent[incoming_vertex] = current;
                }
            }
        }

        // move/copy the host array to device
        device_weights = weights;
        
        // get the min index
        int min_index = thrust::min_element(ptr, ptr + nodes) - ptr;
        // cout<<"Min Weight Index: "<<min_index<<endl;
        
        // add the least edge weight found outto answer 
        parent[min_index] = current;
        edge_sum += weights[min_index];
        // reset weight to INT_MAX for this vertex as it is already considered in MST
        weights[min_index] = INT_MAX;
        // new current 
        current = min_index;      
    }
    clock_t end = clock();


    // ======================== Results ====================================
    // Print parent of nodes in MST
    // for(int i = 0; i < nodes; ++i) {
    //     cout<<i<<"'s parent is "<<parent[i]<<endl;
    // }
    // Print the sum of edges in MST
    cout<<"Sum of Edges in MST: "<<edge_sum<<endl;

    // Print the time for execution
    double elapsed_time = double(end - begin) / CLOCKS_PER_SEC;
    cout<<"Execution time: "<<elapsed_time<<endl;


    // ======================== Memory Deallocation ====================================
    // thrust::device_free(ptr); 	
    // device_weights.clear();
    // thrust::device_vector<int>().swap(device_weights);
    free(V); free(E); free(W);
    free(parent); free(inMST); 

    return 0;
}


// Sample Input
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