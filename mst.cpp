#include <bits/stdc++.h>
// #include <cuda.h>

using namespace std;

int main(){
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
    
    return 0;
}