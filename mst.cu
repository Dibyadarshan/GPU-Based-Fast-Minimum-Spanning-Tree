#include <iostream>
#include <vector>
#include <cuda.h>
#include <thrust/device_vector.h>
#include <thrust/extrema.h>
#include <ctime>
using namespace std;

int main(){

    freopen("graph.txt", "r", stdin);

    int nodes, edges;
    cin>>nodes>>edges;

    vector<vector<pair<int,int> > > adjacency_list(nodes); 
    
    for(int i = 0; i < edges; ++i){
        int node1, node2, weight;
        cin>>node1>>node2>>weight;
        
        adjacency_list[node1].push_back(make_pair(node2, weight));
        adjacency_list[node2].push_back(make_pair(node1, weight));
    }

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

    clock_t begin = clock();

    thrust::device_vector<int> device_weights(weights, weights + nodes);
    thrust::device_ptr<int> ptr = device_weights.data();

    while(count < nodes-1){
        ++count;
        inMST[current] = true;

        for(int i = 0; i < adjacency_list[current].size(); ++i) {
            int incoming_vertex = adjacency_list[current][i].first;
            if(!inMST[incoming_vertex]) {
                if(device_weights[incoming_vertex] > adjacency_list[current][i].second) {
                    device_weights[incoming_vertex] = adjacency_list[current][i].second;
                    parent[incoming_vertex] = current;
                }
            }
        }

        int min_index = thrust::min_element(ptr, ptr + nodes) - ptr;
        cout<<"Min Weight Index: "<<min_index<<endl;
        
        parent[min_index] = current;
        ans += device_weights[min_index];
        device_weights[min_index] = INT_MAX;
        current = min_index;
    }
    
    clock_t end = clock();

    cout<<"Answer: "<<ans<<endl;

    for(int i = 0; i < nodes; ++i) {
        cout<<i<<"'s parent is "<<parent[i]<<endl;
    }

    double elapsed_time = double(end - begin) / CLOCKS_PER_SEC;
    cout<<"Execution time: "<<elapsed_time<<endl;

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